var gulp  = require('gulp');
var shell = require('gulp-shell');
var prompt = require("gulp-prompt");
var gulpif = require('gulp-if');
var minimist = require('minimist');
var path = require('path');

var headlessTemplate = 'gnustep-headless-debian-8-x64.json';
var guiTemplate = 'gnustep-gui-debian-8-x64.json';


var knownOptions = {
  string: [ 'docker-hub-email' ],
  boolean: [ 'parallel', 'noninteractive' ],
  default: {
    'docker-hub-email': process.env.DOCKER_HUB_EMAIL || '',
    parallel: false,
    noninteractive: false
  }
};

var options = minimist(process.argv.slice(2), knownOptions);
var parallelOpt = '';

if (!options.parallel) {
  parallelOpt = '-parallel=false'
}


var shellParameters = {
  maxBuffer: (64 * 1024 * 1024),
  templateData: {
    parallelOpt: parallelOpt,
    dockerHubEmail: options['docker-hub-email']
  }
}

process.env.TMPDIR = path.join(process.cwd(), '.tmp');


gulp.task('docker_cfg', function() {
    return gulp.src(headlessTemplate, {read: false})
        .pipe(gulpif((!options.noninteractive && !process.env.DOCKER_HUB_PASSWORD),
           prompt.prompt([{
          type: 'password',
          name: 'pass',
          message: 'Please enter your docker hub password'
        }], function (r) { process.env.DOCKER_HUB_PASSWORD = r.pass; })))
});

gulp.task('headless_dev', ['docker_cfg'], function() {
  return gulp.src(headlessTemplate, { read: false })
             .pipe(shell('packer build -force <%= parallelOpt %> -var \'docker_hub_email=<%= dockerHubEmail %>\' -var \'container_flavour=dev\' <%= file.path %>',
             shellParameters
           ))
});

gulp.task('headless_docker_rt', ['headless_dev'], function() {
  return gulp.src(headlessTemplate, { read: false })
             .pipe(shell('packer build -force <%= parallelOpt %> -var \'docker_hub_email=<%= dockerHubEmail %>\' -var \'container_flavour=rt\'  -only=docker <%= file.path %>',
             shellParameters
           ))
});

gulp.task('headless', ['headless_docker_rt']);

gulp.task('gui', [ 'headless_dev' ], function() {
  return gulp.src(guiTemplate, { read: false })
             .pipe(shell('packer build <%= parallelOpt %>  <%= file.path %>',
             shellParameters
           ))
});

gulp.task('default', ['gui', 'headless']);
