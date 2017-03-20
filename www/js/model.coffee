env = require './env.coffee'
require 'PageableAR'

angular.module 'starter.model', ['PageableAR']

  .factory 'resource', (pageableAR, $filter, $http) ->

    class User extends pageableAR.Model
      $urlRoot: "api/user/"

      _me = null

      @me: ->
        _me ?= new User username: 'me'

    class Hotspot extends pageableAR.Model
      $idAttribute: 'id'

      $urlRoot: "api/hotspot/"

      $parse: (data, opts) ->
        tag = if _.includes env.tag.split(","), data.tag?[0]?.name then data.tag?[0]?.name else "unknown"
		ret = super(data, opts)
        ret['options'] = {title: "#{ret['name']}", icon: "img/#{tag}.png"}
        return ret

      info: ->
        ret = _.pick @, 'name'
        ret = _.extend ret, @extra
        JSON.stringify ret

    class HotspotList extends pageableAR.PageableCollection
      model: Hotspot

      $urlRoot: "api/hotspot/"

      # split loaded models into 2 sets {inside: [...], outside: [...]}
      split: (bounds) ->
        ret = _.groupBy @models, (hotspot) ->
          loc = hotspot.coordinates
          if bounds.contains new google.maps.LatLng loc[1], loc[0]
            'inside'
          else
            'outside'
        _.defaults ret, {inside: [], outside: []}

      inside: (bounds) ->
        @split(bounds).inside

      outside: (bounds) ->
        @split(bounds).outside

    class Tag extends pageableAR.Model
      $urlRoot: "api/tag/"

    class TagList extends pageableAR.PageableCollection
      model: Tag

      $urlRoot = "api/tag/"

    User: User
    Hotspot: Hotspot
    HotspotList: HotspotList
    Tag: Tag
    TagList: TagList
