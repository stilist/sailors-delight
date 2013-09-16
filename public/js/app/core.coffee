(($) ->
	opts =
		# sky element azimuth
		α: 130
		# solar azimuth
		αs: 293.38
		# sky element altitude
		γ: 10
		# solar altitude
		γs: -17.38
		sky_code: "ⅠⅤ.4"
		# IDMP Bratislava (placeholder)
		zenith_luminance: 4404

	# $out.html(relative_luminance(opts) + " cd/m<sup>2</sup>");

)(window.$ || window.jQuery)
