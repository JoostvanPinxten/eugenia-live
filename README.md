Installation
============

1. Install NPM (by [installing Node.js](http://nodejs.org/)).
2. Clone this Git repository.
3. Install hem: `sudo npm install -g hem`
4. Launch the development server: `hem server -d` or `./server.sh`

The server can also be started without the "-d" option, but this means that the Javascript will be minified on each request and therefore cannot be easily debugged. Another side-effect is that the minifaction of the javascript takes quite long, as several libraries are included.

Development Dependencies
========================

To be able to run the acceptance tests:

1. `brew update && brew install phantomjs`
2. Install Ruby via RVM
3. Install bundler: `gem install bundler`
4. Install Ruby dependencies: `bundle install`

Run the acceptance tests with `bundle exec cucumber`


Deploying to Heroku
===================

Ensure that Heroku knows that this is a Javascript (and not a Ruby) app: `heroku config:set BUILDPACK_URL=https://github.com/heroku/heroku-buildpack-nodejs`