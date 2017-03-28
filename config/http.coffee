csp = require 'helmet-csp'

module.exports =
  http:
    middleware:
      unknownpng: (req, res, next) ->
        regexp = /^[\/]img[\/][0-9a-zA-Z\^\&\'\@\{\}\[\]\$\=\!\-\#\(\)\.\%\?\+\~\_ ]+\.(png)$/
        match = regexp.exec(req.url)
        if match != null
          if !(fs.existsSync("www/" + match[0]))
            req.url = "/img/unknown.png"
         
        next()    
      csp: (req, res, next) ->
        host = req.headers['x-forwarded-host'] || req.headers['host']
        src = [
          "'self'"
          "data:"
          "http://#{host}"
          "https://#{host}"
          "https://*.googleapis.com"
          "https://*.gstatic.com"
          "https://cdn.rawgit.com"
          "http://cdn.rawgit.com"
        ]
        ret = csp
          directives:
            defaultSrc: src
            styleSrc: ["'unsafe-inline'"].concat src
            scriptSrc: [
                "'unsafe-inline'"
                "'unsafe-eval'"
              ].concat src
        ret req, res, next
      order: [
        'bodyParser'
        'compress'
        'methodOverride'
        'csp'
        'router'
        'unknownpng'
        'www'
        'favicon'
        '404'
        '500'
      ]
