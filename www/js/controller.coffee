_ = require 'lodash'
env = require './env.coffee'
require './event.coffee'

angular

  .module 'starter.controller', [
    'starter.model'
    'starter.event'
  ]

  .controller 'MenuCtrl', ($scope) ->
       return

  .controller 'MapCtrl', ($scope, pos, resource, $log, $ionicPopup, $ionicActionSheet, $http) ->

    collection = new resource.HotspotList()

    get = (box) ->
      collection
        .$fetch params: _.extend limit: 100, box.toJSON()
        .then ->
           if collection.state.count > collection.inside(box).length
             get box

    _.extend $scope,
      mouseUp: false
      collection: collection
      loadTags: ($query, taglist) ->
        searchTag = $query.trim()
        r = new RegExp(searchTag, 'i')
        return _.filter taglist, (item) ->
          r.test(item?.name)
              
      showPopUpdate: (model) ->
        $scope.model = model
        if _.isEmpty model.extra
           $scope.model.extra = ""
        else	
           $scope.model.extra.toString = ->
             return JSON.stringify @
        popup = $ionicPopup.show({
           templateUrl: (if model.options.draggable then 'templates/hotspot/updateDrag.html' else 'templates/hotspot/update.html'),
           title: 'Update Hotspot',
           scope: $scope,
           buttons: [
             {
                text: 'Cancel',
                onTap: ->
                  model.options = _.pick model.options, 'title', 'icon'
                  $http.get "api/hotspot/#{model.id}" 
                      .then (res) ->
                         model.coordinates = res.data.coordinates
                         #$scope.collection.$refetch
                         #_.each $scope.collection.models, (instance) ->
                         #    if instance.id == model.id
                         #       instance.coordinates = res.data.coordinates
             },
             {
                text: 'Save',
                type: 'button-positive'
                onTap: ->
                  $scope.model.$save()
                    .then (s) ->
                      $scope.map.center = s.coordinates
                    .catch (err) ->
                      $log.error err.data.message
                  return
             }
           ]
        })
                  
      showPopup: ->
        popup = $ionicPopup.show({
           templateUrl: 'templates/hotspot/create.html',
           title: 'Create Hotspot',
           scope: $scope,
           buttons: [
             {
                text: 'Cancel',
                onTap: ->
                  _.remove $scope.collection.models, (model) ->
                    model.id == 'unknown'
                  $scope.collection.length = $scope.collection.models.length
             },
             {
                text: 'Save',
                type: 'button-positive'
                onTap: ->
                  $scope.model.tag = [{name: $scope.tags[0].text}]
                  delete $scope.model['id']
                  $scope.model.$save()
                    .then (s) ->
                      $scope.map.center = s.coordinates
                    .catch (err) ->
                      $log.error err.data.message
                  return
                  
             }
           ]
        })
        
      map:
        center: _.pick pos, 'latitude', 'longitude'
        zoom: env.map.zoom
        window:
          options:
            pixelOffset:
              height: -25
              width: 0
          show: false
          close: ->
            @show = false
        markerControl: {}
        events:
          idle: (viewport) ->
            collection.state.skip = 0
            get viewport.getBounds()
          tapHold: (map, event, loc) ->
            $scope.model = new resource.Hotspot coordinates:[loc[0].lng(), loc[0].lat()], type:'Point', id:'unknown'
            $scope.tags = []
            $scope.taglist = []
            $http.get "api/tag"
              .then (res) =>
                taglist = res.data.results
                _.each taglist, (tag) ->
                  _.extend tag,
                    text: tag.name
                $scope.taglist = taglist
            
            $scope.showPopup()
        markersEvents:
          click: (marker, eventName, model) ->
            $scope.map.window.model = model
            $scope.map.window.show = true
          mousedown: (marker, eventName, model) ->
            $scope.mouseUp = false
            cb = ->
              if $scope.mouseUp == false && model.options.draggable != true 
                $ionicActionSheet.show
                   buttons: [
                     { text: 'Drag & Drop', cmd: 'drag'}
                     { text: 'Update', cmd: 'up'}
                   ]
                   buttonClicked: (index, button) ->
                     if button.cmd =='drag'
                       _.extend model.options,
                          draggable: true
                          labelContent: "DRAG ME!"
                          labelAnchor: "25 0"
                     else
                       $scope.showPopUpdate model
                     return true 
            setTimeout cb, 1000
          mouseup: ->
            $scope.mouseUp = true
          dragend: (marker, eventName, model) ->
            $scope.showPopUpdate model

  .controller 'HotspotCtrl', ($scope, model, $location) ->
    return

  .controller 'HotspotListCtrl', ($scope, collection, $location, model) ->
    return

  .filter 'HotspotFilter', ->
    (hotspots, search) ->
      return
