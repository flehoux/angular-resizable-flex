var gulp = require('gulp');
var coffee = require('gulp-coffee');
var uglify = require('gulp-uglify');
 
gulp.task('coffee', function() {
  gulp.src('./src/*.coffee')
    .pipe(coffee())
    .pipe(uglify())
    .pipe(gulp.dest('./'));
});

gulp.task('default', ['coffee']);
