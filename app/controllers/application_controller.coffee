module.exports = (app) ->
  class app.ApplicationController

    # GET /
    @index = (req, res) ->
      # console.log app.helpers.md5.digest_s('abc')
      res.render 'index',
        view: 'index'

    @closed = (req, res) ->
      # close submissions
      res.render 'closed'
    @submit = (req, res) ->
      # return res.redirect('closed')
      d = new Date()
      # return res.send(req.body)
      v = app.helpers.validator
      doc = req.body
      #first check if everything is filled out
      empty_fields = true in [v.isNull(x) for x in [doc.email, doc.url, doc.title, doc.author, doc.homepage_url, doc.description]][0]
      errors = []
      validate = () ->
        if empty_fields
          errors = ['Fill in all fields']
          if v.isNull(doc.description)
            errors.push 'Please provide a description'
          if v.isNull(doc.author)
            errors.push 'Please provide an author'
          if v.isNull(doc.tags)
            errors.push 'Please provide some tags (separated by spaces)'
          doc.errors = errors
          return res.render 'index', doc

        if not v.isEmail(doc.email)
          errors.push 'Invalid email'
        if not v.isURL doc.url, {require_protocol: true}
          errors.push 'Invalid URL. (Did you remember "http://" ?)'
        if not v.isURL doc.homepage_url, {require_protocol: true}
          errors.push 'Invalid Homepage URL. (Did you remember "http://" ?)'
      do validate if app.get('env') is 'production'

      if errors.length
        doc.errors = errors
        return res.render 'index', doc

      doc.created_at = d
      doc.multipass = app.helpers.md5.digest_s(d)
      doc.tags = doc.tags.split(' ')
      doc._id = app.helpers.md5.digest_s(doc.url)
      # return res.send(doc)
      unless app.get('env') is 'development'
        app.db.insert doc, (err, body) ->
          if err
            if err.status_code is 409
              doc.errors = ['That link is already in the repo!']
              return res.render 'index', doc
            return res.render 'error', {errors: v.toString(err)}
          if not err
            console.log body
            # return res.send(body)

            res.locals.doc = doc
            res.locals.entry = body
            # return res.redirect "http://gli.tc/h/0P3NR3P0_sample_gallery/email.php?email=#{doc.email}&author=#{doc.author}&multipass=#{doc.multipass}&title=#{doc.title}&url=#{doc.url}&docid=#{body.id}&irlshow=#{doc.show}"
            return email_on_success(req, res)
      else
        # console.log body
        doc =
          email: 'joe@yolk.cc'
          author: 'Joseph Yølk Chiocchi'
        res.locals.doc = doc
        return email_on_success(req, res)
    send_message = (message, cb) ->
      app.mandrill 'messages/send', {
        message: message
      }, (err, response) ->
        if err
          console.log JSON.stringify err
        console.log response
        cb(err, response)
    email_on_success = (req, res) ->
      doc = res.locals.doc
      entry = res.locals.entry
      success_template = 'app/templates/success_email.jade'
      edit_message =
        to: [{
          email: doc.email,
          name: doc.author
          }]
        # from_email: process.env.MANDRILL_USERNAME
        html: app.jrenderFile success_template, 
          openrepo_edit_url: "http://0p3nr3p0.net/edit/#{entry.id}?multipass=#{doc.multipass}"
          openrepo_permalink: "http://0p3nr3p0.net/piece/#{entry.id}"
        from_email: 'no-reply@0p3nr3p0.net'
        from_name: '0P3NR3P0'
        subject: 'Your 0P3NR3P0 Edit URL'
        auto_text: true
      edit_cb = (err, response, cb) ->
        new_entry_email req, res
      send_message edit_message, edit_cb
  
    new_entry_email = (req, res) ->
      doc = res.locals.doc
      entry = res.locals.entry
      doc.permalink = "http://0p3nr3p0.net/piece/#{entry.id}"
      new_entry_template = 'app/templates/new_entry_email.jade'
      new_entry_message = 
        to: 
          [
            {
              email: 'joe@yolk.cc',
              name: 'Joseph Chiocchi'
            }
            {
              email: 'nickbriz@gmail.com',
              name: 'Nick Briz'
            }
          ]
        html: app.jrenderFile new_entry_template,
          doc
        from_email: 'no-reply@0p3nr3p0.net'
        from_name: '0P3NR3P0',
        subject: 'New 0P3NR3P0 Entry!',
        auto_text: true
      console.log doc
      new_entry_cb = (err, response, cb) ->
        entry = res.locals.entry
        unless cb
          # return res.send 
          #   doc: doc
          #   response: response
          #   err: err
          #   message: edit_message
          return res.render 'thankyou.jade', {id: entry.id}
        else
          do cb
      send_message new_entry_message, new_entry_cb
