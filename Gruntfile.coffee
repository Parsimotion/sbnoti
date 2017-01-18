"use strict"

require("coffee-script/register")
#[^] last version of coffee

module.exports = (grunt) ->
  #-------
  #Plugins
  #-------
  require("load-grunt-tasks") grunt

  #-----
  #Tasks
  #-----
  grunt.registerTask "default", "test"
  grunt.registerTask "test", "mochaTest"
  # grunt bump: increase version, commit, create tag

  #------
  #Config
  #------
  grunt.initConfig
    # Run tests
    mochaTest:
      options:
        reporter: "spec"
      src: ["test/**/*.spec.coffee"]

    # Upgrade the version of the package
    bump:
      options:
        files: ["package.json"]
        commit: true
        commitMessage: "Release v%VERSION%"
        commitFiles: ["-a"]
        createTag: true
        tagName: "%VERSION%"
        tagMessage: "Version %VERSION%"
        push: false
