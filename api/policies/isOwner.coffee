_ = require 'lodash'

module.exports = (req, res, next) ->
  req.options.where = req.options.where || {}
  _.extend req.options.where, createdBy: req.user
  next()
