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
     Model = actionUtil.parseModel(req)
     data = actionUtil.parseValues(req)
     newTag = name: req.body.tag[0].name
     data = _.extend data,
       tag: req.body.tag[0].name
     sails.models.tag.findOrCreate newTag, newTag
       .then (tag) ->
         Model.create(data)
           .then (model) ->
             res.created(model)
       .catch res.serverError
