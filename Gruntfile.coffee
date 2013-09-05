class Helper

module.exports = (grunt) ->

  grunt.initConfig
    
    clean:
      unit: ['test/unit/*.js']
      functional: ['test/functional/*.js']
      integration: ['test/integration/*.js']
      lib: ["./lib/**/*.*"]


    coffee:
      unit:
        expand: true,
        flatten: true,
        cwd: './test/unit_src/',
        src: ['**/*.coffee'],
        dest: './test/unit/',
        ext: '.js'        

      functional:
        expand: true,
        flatten: true,
        cwd: './test/functional_src/',
        src: ['**/*.coffee'],
        dest: './test/functional/',
        ext: '.js'

      integration:
        expand: true,
        flatten: true,
        cwd: './test/integration_src/',
        src: ['**/*.coffee'],
        dest: './test/integration/',
        ext: '.js'

      src:
        expand: true,
        flatten: false,
        cwd: './src',
        src: ['**/*.coffee'],
        dest: './lib',
        ext: '.js'

    mochaTest:
      unit:
        options:
          reporter: 'spec'
        src: ['test/unit/*.js']

      functional:
        options:
          reporter: 'spec'
        src: ['test/functional/*.js']
        
      integration:
        options:
          reporter: 'spec'
        src: ['test/integration/*.js']

    watch:
      unit:
        files: ["./test/unit_src/**/*.coffee"]
        tasks: ["clean:unit","coffee", "mochaTest:unit"]

      functional:
        files: ["./test/functional_src/**/*.coffee"]
        tasks: ["clean:functional","coffee", "mochaTest:functional"]

      unit_inverse:
        files: ["./test/functional_src/**/*.coffee", "./src/**/*.coffee"]
        tasks: ["clean:unit","coffee", "mochaTest:unit"]
        
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-mocha-test');
  grunt.loadNpmTasks('grunt-s3');

  grunt.registerTask('test', ["clean",'coffee',"mochaTest"]);   
  grunt.registerTask('test_unit', ["clean:unit",'coffee',"mochaTest:unit"]);   
  grunt.registerTask('watch_unit', ["watch:unit"]);   
  grunt.registerTask('watch_unit_inverse', ["watch:unit_inverse"]);   
  grunt.registerTask('test_functional', ["clean:functional",'coffee',"mochaTest:functional"]);  
  grunt.registerTask('test_integration', ["clean:integration",'coffee',"mochaTest:integration"]);  
   
