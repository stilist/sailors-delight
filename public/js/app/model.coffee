window.Illuminate or= {}

class Illuminate.Model extends Backbone.Model
	defaults:
		# Portland, OR
		lat: 45.52
		lng: -122.681944

	initialize: ->
		@set "timestamp", new Date()

		@on "change:elevation", @_setColor
		@on "change:lat change:lng change:timestamp", @_setAzimuthAndElevation
		@on "change:lat change:lng change:timestamp", @_setSolarNoon
		@on "change:lat change:lng change:timestamp", @_setSunrise
		@on "change:lat change:lng change:timestamp", @_setSunset

	_setAzimuthAndElevation: ->
		time = @get "timestamp"
		[az, el] = time.getAzimuthAndElevation @get("lat"), @get("lng")

		@set "azimuth", az
		@set "elevation", el

	_setColor: ->
		elevation = @get "elevation"

		color = if elevation >= 0 then "#dbe9ff"
		else if -6 < elevation < 0 then "#87a4d3"
		else if -12 < elevation < -6 then "#4773bb"
		else if -18 < elevation < -12 then "#263e66"
		else "#1f252d"

		@set "color", color

	_setSolarNoon: ->
		time = @get "timestamp"
		solar_noon = time.getSolarNoon @get("lat"), @get("lng")

		@set "solar_noon", solar_noon

	_setSunrise: ->
		time = @get "timestamp"
		sunrise = time.getSolarTransit true, @get("lat"), @get("lng")

		@set "sunrise", sunrise

	_setSunset: ->
		time = @get "timestamp"
		sunset = time.getSolarTransit false, @get("lat"), @get("lng")

		@set "sunset", sunset
