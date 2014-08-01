module.exports = (app) ->
  class app.ApplicationController

    # GET /
    @index = (req, res) ->
      # console.log app.helpers.md5.digest_s('abc')
      res.render 'index',
        view: 'index'

    @submit = (req, res) ->
      d = new Date()
      # return res.send(req.body)
      v = app.helpers.validator
      doc = req.body
      #first check if everything is filled out
      empty_fields = true in [v.isNull(x) for x in [doc.email, doc.url, doc.title, doc.author, doc.homepage_url, doc.description]][0]
      errors = []
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

      if errors.length
        doc.errors = errors
        return res.render 'index', doc

      doc.created_at = d
      doc.multipass = app.helpers.md5.digest_s(d)
      doc.tags = doc.tags.split(' ')
      doc._id = app.helpers.md5.digest_s(doc.url)
      # return res.send(doc)
      app.db.insert doc, (err, body) ->
        if err
          if err.status_code is 409
            doc.errors = ['That link is already in the repo!']
            return res.render 'index', doc
          return res.render 'error', {errors: v.toString(err)}
        if not err
          console.log body
          # return res.send(body)
          return res.redirect "http://gli.tc/h/0P3NR3P0_sample_gallery/email.php?email=#{doc.email}&author=#{doc.author}&multipass=#{doc.multipass}&title=#{doc.title}&url=#{doc.url}&docid=#{body.id}&irlshow=#{doc.show}"
