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

  .controller 'MapCtrl', ($scope, pos, resource, $log, $ionicPopup) ->

    collection = new resource.HotspotList()

    get = (box) ->
      collection
        .$fetch params: _.extend limit: 100, box.toJSON()
        .then ->
           if collection.state.count > collection.inside(box).length
             get box

    _.extend $scope,
      collection: collection
      showPopup: ->
        popup = $ionicPopup.show({
           template: '<input type="text" ng-model="model.name" placeHolder="Hotspot name"><br><input type="text" ng-model="model.tag" placeHolder="Tag">',
           title: 'Create Hotspot',
           scope: $scope,
           buttons: [
             { text: 'Cancel'},
             {
                text: '<b>Save</b>',
                type: 'button-positive'
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
            $scope.collection.add new resource.Hotspot tag:[{name:'unknown'}], coordinates:[loc[0].lng(), loc[0].lat()], name:'unknown', type:'Point', id:'unknown'
            $scope.$apply 'collection'
            $scope.showPopup()
        markersEvents:
          click: (marker, eventName, model) ->
            $scope.map.window.model = model
            $scope.map.window.show = true

  .controller 'HotspotCtrl', ($scope, model, $location) ->
    return

  .controller 'HotspotListCtrl', ($scope, collection, $location, model) ->
    return

  .filter 'HotspotFilter', ->
    (hotspots, search) ->
      return
