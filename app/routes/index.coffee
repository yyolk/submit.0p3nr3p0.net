module.exports = (app) ->
  # Index
  app.get '/', app.ApplicationController.index

  # Error handling (No previous route found. Assuming it’s a 404)
  app.get '/*', (req, res) ->
    NotFound res

  app.post '/submit', app.ApplicationController.submit

  NotFound = (res) ->
    res.render '404', status: 404, view: 'four-o-four'
