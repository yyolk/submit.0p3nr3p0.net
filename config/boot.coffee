module.exports = (app) ->
  # Helpers
  app.helpers = require "#{__dirname}/../app/helpers"

  # Lib
  app.helpers.autoload "#{__dirname}/../lib", app

  # Controllers
  app.helpers.autoload "#{__dirname}/../app/controllers", app

  nano = require('nano')('http://192.241.178.102:5984')
  mandrill = require('node-mandrill')(process.env.MANDRILL_APIKEY)
  jade = require 'jade'
  app.jrenderFile = jade.renderFile
  db_name = 'openrepo'
  app.db = nano.use(db_name)
  app.mandrill = mandrill