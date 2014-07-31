module.exports = (app) ->
  class app.ApplicationController

    # GET /
    @index = (req, res) ->
      console.log app.helpers()
      res.render 'index',
        view: 'index'

    @submit = (req, res) ->
      app.db.insert({
        created_at: new Date()
        # multipass: app.helpers.
      }, (err, body) ->
        if not err
          console.log body
          #res.redirect "http://gli.tc/h/0P3NR3P0_sample_gallery/email.php?email="+body.email+"&multipass="+body.multipass+"&author="+body.author+"&title="+body.title+"&url="+uurl+"&docid="+body._id
          #res.redirect('http://0p3nr3p0.net/submit/thankyou.html')
      )