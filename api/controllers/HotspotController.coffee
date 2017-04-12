_ = require 'lodash'
actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'
Promise = require 'bluebird'

module.exports =
  find: (req, res) ->
    box = [
      [parseFloat(req.query.west), parseFloat(req.query.south)]
      [parseFloat(req.query.east), parseFloat(req.query.north)]
    ]
    req.query = _.omit req.query, 'east', 'south', 'west', 'north'
    where = actionUtil.parseCriteria req
    skip = actionUtil.parseSkip req
    limit = actionUtil.parseLimit req
    sails.models.hotspot
      .findByBox box, where, skip, limit
      .then res.ok
      .catch res.serverError

  create: (req, res) ->
    data = actionUtil.parseValues(req)
    tag = req.body.tag[0].name
    email = req.user.email
    
    newUser = email: email
    newTag = name: tag
        
    Promise
      .all [
        sails.models.user.findOrCreate newUser, newUser
        sails.models.tag.findOrCreate newTag, newTag
      ]
      .then (res) ->
        data = _.extend data,
          tag: [tag]          
        sails.log.debug "create hotspot: #{JSON.stringify data}"
        sails.models.hotspot
          .create data  
          .then res.ok
          .catch res.serverError
