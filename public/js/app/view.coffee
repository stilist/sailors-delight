window.Illuminate or= {}

class Illuminate.View extends Backbone.View
	initialize: (options) ->
		@model = new Illuminate.Model
		@template = options.template

		@listenTo @model, "change:color", @_setColor
		@listenTo @model, "change:azimuth", @_positionSun
		@listenTo @model, "change:sunrise change:sunset", @_positionTransitMarkers

		@$sun = null

	render: ->
		@$el.html @template

		@$sun = @$("#sun")

		setInterval =>
			@model.set "timestamp", new Date()
		, (1000 * 5)
		@model.set "timestamp", new Date()

		@_getGeolocation()

		@

	_positionSun: (model) ->
		azimuth = @model.get "azimuth"
		elevation = @model.get "elevation"

		if azimuth and elevation
			azimuth_pct = (azimuth / 360) * 100
			elevation_pct = 100 * (-elevation / 360) + 50

			position =
				left: "#{azimuth_pct}%"
				top: "#{elevation_pct}%"

			@$sun.css position

			$past_sun = $("<span class='past_sun'></span>")
			@$el.append $past_sun
			$past_sun.css position

	_positionTransitMarkers: (model) ->
		time = model.get "timestamp"
		start = moment(time).startOf "day"

		dst_difference = time.getNonDSTTimezoneOffset() - time.getTimezoneOffset()

		for point in ["sunrise", "sunset"]
			$marker = @$("##{point}_marker")
			transition = model.get point
			transition_moment = moment(transition)
			transition_moment.subtract "minutes", dst_difference
			pct = -100 * (start.diff transition_moment, "days", true)

			$marker.css { left: "#{pct}%" }

	_getGeolocation: ->
		cb = (position) =>
			for coord in ["lat", "long"]
				@model.set coord, position.coords["#{coord}itude"]

		navigator.geolocation.getCurrentPosition cb

	_setColor: (model) -> $(document.body).css { backgroundColor: model.get("color") }
