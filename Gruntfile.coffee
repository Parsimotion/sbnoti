"use strict"

require("coffee-script/register")
#[^] last version of coffee

module.exports = (grunt) ->
  #-------
  #Plugins
  #-------
  require("load-grunt-tasks") grunt
  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-mocha-test"
  grunt.loadNpmTasks "grunt-bump"

  #-----
  #Tasks
  #-----
  grunt.registerTask "default", "mochaTest"
  grunt.registerTask "test", "mochaTest"
  grunt.registerTask "build", ["clean:build", "coffee", "clean:specs"]
  # grunt bump: increase version, commit, create tag

  #------
  #Config
  #------
  grunt.initConfig
    #Clean build directory
    clean:
      build: src: "lib"
      specs: src: "lib/*.spec.js"

    #Compile coffee
    coffee:
      compile:
        expand: true
        cwd: "#{__dirname}/src"
        src: ["**/{,*/}*.coffee"]
        dest: "lib/"
        rename: (dest, src) ->
          dest + "/" + src.replace(/\.coffee$/, ".js")

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
