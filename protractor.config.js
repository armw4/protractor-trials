// An example configuration file.
exports.config = {
  directConnect: true,

  // Capabilities to be passed to the webdriver instance.
  capabilities: {
    browserName: 'chrome'
  },

  framework: 'jasmine',

  // Options to be passed to Jasmine-node.
  jasmineNodeOpts: {
    showColors: true,

    defaultTimeoutInterval: 10000,

    includeStackTrace: true
  },

  seleniumServerJar: './node_modules/protractor/selenium/selenium-server-standalone-2.44.0.jar',

  baseUrl: '127.0.0.1:3000'

};
