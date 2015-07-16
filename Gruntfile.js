'use strict';
module.exports = function (grunt) {
  require('time-grunt')(grunt);
  require('load-grunt-tasks')(grunt);

  var gconf = {
    src: {
      root: 'src',
      scripts: 'src/scripts'
    },
    spec: {
      root: 'spec',
      scripts: 'spec/scripts'
    },
    test: {
      root: 'test',
      scripts: 'test/scripts'
    },
    dist: {
      root: 'dist',
      scripts: 'dist/scripts'
    }
  };

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    gconf: gconf,
    clean: {
      dist: ['<%= gconf.dist.root %>', '<%= gconf.test.root %>']
    },
    coffee: {
      test: {
        files: {
          '<%= gconf.test.scripts %>/app.spec.js': ['<%= gconf.spec.scripts %>/**/*.coffee']
        }
      }
    },
    coffeelint: {
      options: {
        configFile: 'coffeelint.json'
      },
      test: ['<%= gconf.spec.scripts %>/**/*.coffee']
    },
    jshint: {
      options: {
        jshintrc: '.jshintrc',
        reporter: require('jshint-stylish')
      },
      all: [
        'Gruntfile.js',
        '<%= gconf.src.scripts %>/**/*.js'
      ]
    },
    uglify: {
      options: {
        compress: true,
        expand: true,
        dot: true,
        mangle: {
          except: ['_', 'jQuery', 'Backbone']
        }
      },
      libs: {
        files: {
          '<%= gconf.dist.scripts %>/lib.min.js': [
            'bower_components/jquery/dist/jquery.min.js',
            'bower_components/underscore/underscore-min.js',
            'bower_components/backbone/backbone.js'
          ]
        }
      },
      dist: {
        files: {
          '<%= gconf.dist.scripts %>/app.min.js': [
            '<%= gconf.src.scripts %>/backbone/**/*.js'
          ]
        }
      }
    },
    jasmine: {
      test: {
        options: {
          specs: '<%= gconf.test.scripts %>/app.spec.js',
          vendor: '<%= gconf.dist.scripts %>/lib.min.js'
        },
        src: '<%= gconf.dist.scripts %>/app.min.js'
      }
    },
    watch: {
      gruntfile: {
        files: ['Gruntfile.js'],
        tasks: ['js', 'co', 'jasmine']
      },
      js: {
        files: ['<%= gconf.src.scripts %>/**/*.js'],
        tasks: ['js', 'jasmine'],
        options: {
          livereload: true
        }
      },
      coffee: {
        files: ['<%= gconf.spec.scripts %>/**/*.coffee'],
        tasks: ['co', 'jasmine'],
        options: {
          livereload: true
        }
      }
    }
  });

  grunt.registerTask('co', ['coffeelint', 'coffee']);
  grunt.registerTask('js', ['jshint', 'uglify']);
  grunt.registerTask('test', ['build', 'jasmine']);
  grunt.registerTask('build', ['clean', 'js', 'co']);
  grunt.registerTask('serve', ['test', 'watch']);
  grunt.registerTask('default', ['build']);
};
