window.Illuminate or= {}

class Illuminate.View extends Backbone.View
	initialize: (options) ->
		@model = new Illuminate.Model
		@template = options.template

		@listenTo @model, "change:color", @_setColor
		@listenTo @model, "change:azimuth", @_positionSun
		@listenTo @model, "change:sunrise change:sunset", @_positionTransitMarkers

		@$BODY = $(document.body)
		@$sun = @$sunlight = null

	render: ->
		@$el.html @template

		@$sun = @$("#sun")
		@$sunlight = @$("#sunlight")

		setInterval =>
			@_updateTimestamp()
		, 1000

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

			if elevation > -18
				sun_top = $(window).height() * (elevation_pct / 100)
				height_pct = elevation
				height = $(window).height() * (height_pct / 100)

				width_pct = 90 - elevation
				left_pct = azimuth_pct - (width_pct / 2)

				@$sunlight.show().css
					height: "#{height_pct}%"
					left: "#{left_pct}%"
					top: sun_top - (height / 2)
					width: "#{width_pct}%"
			else
				@$sunlight.hide()

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
			coords = position.coords
			for coord in ["lat", "long"]
				@model.set coord, coords["#{coord}itude"]

			lat_pct = 100 * (-coords.latitude / 180) + 50
			lng_pct = 100 * (coords.longitude / 360) + 50

			@$("#me").css
				left: "#{lng_pct}%"
				top: "#{lat_pct}%"

		navigator.geolocation.getCurrentPosition cb

	_setColor: (model) ->
		@$BODY.toggleClass "day", model.get("elevation") >= 0

		bg_color = @model.get "color"

		@$BODY.css { backgroundColor: bg_color }

		azimuth = @model.get "azimuth"
		elevation = @model.get "elevation"

		if azimuth and elevation
			lum = new CIELuminance @model.get("lng"), @model.get("lat"), azimuth, elevation
			ratio = lum.getLuminanceRatio()

			bg_colors = new Chromath(bg_color).toRGBArray()
			sun_colors = bg_colors.map (c) -> Math.min Math.round(c * ratio), 255
			sun_hex = new Chromath.rgb(sun_colors).toHexString()
			gradient = "-webkit-radial-gradient(#{sun_hex}, rgba(0, 0, 0, 0) 70%)"

			@$sunlight.css { backgroundImage: gradient }

	_updateTimestamp: ->
		now = @model.get "timestamp"

		@model.set "timestamp", new Date()
