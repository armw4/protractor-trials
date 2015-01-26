module.exports = (config) ->
  config.set
    frameworks: ['jasmine']
    reporters: 'progress'
    port: 9876
    colors: true
    logLevel: config.LOG_INFO
    autoWatch: true
    browsers: ['PhantomJS']
    reportSlowerThan: 500
    plugins: [
      'karma-jasmine',
      'karma-phantomjs-launcher',
      'karma-chrome-launcher'
    ]
