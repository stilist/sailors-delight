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

		if elevation >= 0
			color = "#dbe9ff"
		else if elevation <= -18
			color = "#1f252d"
		else
			if -6 < elevation < 0
				bottom = "#dbe9ff"
				top = "#87a4d3"
				base = 0
			else if -12 < elevation < -6
				bottom = "#4773bb"
				top = "#263e66"
				base = -6
			else if -18 < elevation < -12
				bottom = "#263e66"
				top = "#1f252d"
				base = -12

			pct = (elevation - base) / (base - 6)
			color = Chromath.towards(bottom, top, pct).toHexString()

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
