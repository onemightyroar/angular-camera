'use strict';

module.exports = function(grunt) {
  // load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);
  grunt.initConfig({
    clean: {
      dist: {
        files: [{
          dot: true,
          src: ['.tmp', 'dist/*', '!dist/.git*']
        }]
      }
    },
    coffee: {
      dev: {
        options: {
          sourceMap: false
        },
        files: [{
          expand: true,
          cwd: 'src/directives',
          src: '{,*/}*.coffee',
          dest: 'src/directives',
          ext: '.js'
        }]
      }
    },
    concat: {
      src: {
        src: ['src/directives/angular-camera.js'],
        dest: 'dist/angular-camera.js'
      }
    },
    ngmin: {
      src: {
        src: '<%= concat.src.src %>',
        dest: '<%= concat.src.dest %>'
      }
    },
    uglify: {
      src: {
        files: {
          'dist/angular-camera.min.js': '<%= concat.src.dest %>'
        }
      }
    }
  });

  grunt.registerTask('build', ['dev', 'clean:dist', 'concat', 'ngmin', 'uglify']);
  grunt.registerTask('dev', ['coffee:dev']);
  grunt.registerTask('default', ['build']);
};
