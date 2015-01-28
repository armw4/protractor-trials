gulp       = require 'gulp'
jade       = require 'gulp-jade'
coffee     = require 'gulp-coffee'
bower      = require 'gulp-bower-files'
inject     = require 'gulp-inject'
less       = require 'gulp-less'
es         = require 'event-stream'
angular    = require 'gulp-angular-filesort'
karma      = require 'gulp-karma'
filter     = require 'gulp-filter'
ngmin      = require 'gulp-ngmin'
rimraf     = require 'rimraf'
html2js    = require 'gulp-ng-html2js'
cache      = require 'gulp-cached'
remember   = require 'gulp-remember'
protractor = require('gulp-protractor').protractor

specs = ->
  gulp
  # spec.cofee OR directive.spec.coffee
  .src 'client/**/{spec.coffee,*.spec.coffee}'
  .pipe cache 'specs'
  .pipe coffee()
  .pipe remember 'specs'
  .pipe gulp.dest 'build/specs/'

e2e = ->
  gulp
  # e2e.coffee OR app.e2e.coffee
  .src 'client/**/{e2e.coffee,*.e2e.coffee}'
  .pipe cache 'e2e'
  .pipe coffee()
  .pipe remember 'e2e'
  .pipe gulp.dest 'build/e2e/'

fixtures = ->
  gulp
  .src 'client/**/*.e2e.json'
  .pipe cache 'e2e:json'
  .pipe remember 'e2e:json'
  .pipe gulp.dest 'build/e2e'

scripts = ->
  scriptFiles = ['client/**/*.js']

  coffeeScriptFiles =
  [
    'client/**/*.coffee',
    # ignore all spec and e2e files (production code only)
    '!client/**/spec.coffee',
    '!client/**/*.spec.coffee',
    '!client/**/e2e.coffee',
    '!client/**/*.e2e.coffee'
  ]

  nativeScriptStream =
    gulp
    .src scriptFiles
    .pipe cache 'native-scripts'
    .pipe remember 'native-scripts'

  coffeeScriptStream =
    gulp
    .src coffeeScriptFiles
    .pipe cache 'coffee-scripts'
    .pipe coffee()
    .pipe remember 'coffee-scripts'

  es.merge nativeScriptStream, coffeeScriptStream
  .pipe angular()
  .pipe ngmin()
  .pipe gulp.dest 'build/scripts/'

bowerAssets = ->
  bower read: false
  .pipe cache 'vendor'
  .pipe remember 'vendor'

stylesheets = ->
  gulp
  .src 'client/**/*.less'
  .pipe cache 'stylesheets'
  .pipe less()
  .pipe remember 'stylesheets'
  .pipe gulp.dest 'build/stylesheets/'

views = ->
  gulp
  # skip the main index file since it will be passed to inject
  .src ['server/views/**/*.jade', '!server/views/index.jade']
  .pipe jade pretty: true
  .pipe gulp.dest 'build/views'

# convert jade views to angular templates and store them in the template cache
templates = ->
  gulp.src 'client/**/*.jade'
  .pipe cache 'templates'
  .pipe jade pretty: true
  .pipe html2js moduleName: 'templates', prefix: 'templates/'
  .pipe remember 'templates'
  .pipe gulp.dest 'build/templates'

sources = ->
  # skip angular mocks file (it's for testing purposes....production code only)
  bowerAppAssets = bowerAssets().pipe filter '!**/*-mocks.js'

  es.merge  bowerAssets(), templates(), scripts(), stylesheets()

testSuite = ->
  # scripts only since bower will literally give us ALL files of ALL extensions
  # bootstrap fonts, stylesheets, etc.
  vendor = bowerAssets().pipe filter '**/*.js'

  es.merge vendor, templates(), scripts(), specs()

index = ->
  # index file only
  # will inject all scripts at the bottom of index.html
  # boosts performance (browsers blocks rendering when it encounters scripts)
  # this will load scripts last and allow rendering to begin
  # caveat here is that rendering cannot begin until angular is loaded..which
  # is kind of catch-22-ish. can get away but will need ng-cloak.
  #
  # http://stackoverflow.com/a/15550667.
  gulp
  .src 'server/views/index.jade'
  .pipe jade pretty: true
  .pipe inject sources(), ignorePath: ['bower_components', 'build']
  .pipe gulp.dest 'build/views'

gulp.task 'clean', (cb) ->
  rimraf 'build/', cb

gulp.task 'build', ['files:templates', 'files:scripts', 'files:specs',
                    'files:stylesheets', 'files:views', 'files:index']

gulp.task 'default', ['build']

gulp.task 'files:specs', ['clean'], ->
  specs()

gulp.task 'files:e2e', ['clean'], ->
  e2e()

gulp.task 'files:e2e:fixtures', ['clean'], ->
  fixtures()

gulp.task 'files:templates', ['clean'], ->
  templates()

gulp.task 'files:scripts', ['clean'],  ->
  scripts()

gulp.task 'files:stylesheets', ['clean'], ->
  stylesheets()

gulp.task 'files:views', ['clean'], ->
  views()

gulp.task 'files:index', ['clean'], ->
  index()

gulp.task 'karma', ['files:templates', 'files:scripts', 'files:specs'], ->
  testSuite()
  .pipe karma configFile: 'karma.conf.coffee', action: 'run'
  # Make sure failed tests cause gulp to exit non-zero
  .on 'error', (e) -> throw e

gulp.task 'protractor', ['files:e2e', 'files:e2e:fixtures', 'build'], ->
  e2e()
  .pipe protractor configFile: 'protractor.config.js'
  .on 'error', (e) -> throw e
