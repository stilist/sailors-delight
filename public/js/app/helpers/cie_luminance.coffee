# Partial implementation of [CIE General Sky Standard Defining Luminance Distributions][1].
#
#   [1]: http://www.ustarch.sav.sk/ustarch/download/Darula_Kittler_Proc_Conf_eSim_2002.pdf

abs = Math.abs
acos = Math.acos
asin = Math.asin
cos = Math.cos
exp = Math.exp
# unsigned integer division
floor = (n) -> ~~n
pow = Math.pow
sin = Math.sin
tan = Math.tan
π = Math.PI

sky_types =
	# CIE Standard Overcast Sky
	"I.1":   {}
	"I.2":   {}
	"II.1":  {}
	"II.2":  {}
	# uniform luminance
	"III.1": {}
	"III.2": {}
	"III.3": {}
	"III.4": {}
	"IV.2":  {}
	"IV.3":  {}
	"IV.4":  {}
	# CIE Standard Clear Sky
	"V.4":   {}
	# CIE Standard Clear Sky
	"V.5":   {}
	"VI.5":  {}
	"VI.6":  {}

gradations =
	# a: cloud cover?
	# b: ?
	"I":   { a:  4.0, b: -0.70 } # overcast, steep luminance gradient
	"II":  { a:  1.1, b: -0.80 } # overcast, moderate luminance gradient
	"III": { a:  0.0, b: -1.00 } # partly cloudy, no luminance gradient
	"IV":  { a: -1.0, b: -0.55 } # partly cloudy
	"V":   { a: -1.0, b: -0.32 } # clear sky
	"VI":  { a: -1.0, b: -0.15 } # cloudless sky

indicatrices =
	# c: turbidity?
	# d: solar corona?
	# e: ?
	1: { c:  0, d: -1.0, e: 0.00 } # uniform azimuth
	2: { c:  2, d: -1.5, e: 0.15 } # slight brightening toward sun
	3: { c:  5, d: -2.5, e: 0.30 } # brighter circumsolar region
	4: { c: 10, d: -3.0, e: 0.45 } # distinct solar corona
	5: { c: 16, d: -3.0, e: 0.30 } # low luminance turbidity
	6: { c: 24, d: -2.8, e: 0.15 } # turbid sky

for k,v of sky_types
	split = k.split /\./

	g_k = split[0]
	_.extend v, gradations[g_k]

	i_k = split[1]
	_.extend v, indicatrices[i_k]

class window.CIELuminance
	constructor: (@α, @γ, @α_s, @γ_s) ->
		@sky_type = @getSkyType "IV.4"

		@ζ = @getζ @γ
		@ζ_s = @getζ @γ_s
		@χ = @getχ()

CIELuminance::getSkyType = (type) -> sky_types[type]

# Equation 1: sky element’s great-circle distance from sun (radians)
CIELuminance::getχ = ->
	Δα = abs(@α - @α_s).deg2rad()

	acos(cos(@ζ_s) * cos(@ζ) + sin(@ζ_s) * sin(@ζ) * cos(Δα))

# Equation 2 & 3: zenith angle of given γ
CIELuminance::getζ = (γ) -> (90 - γ).deg2rad()

# Equation 4: luminance ratio, sky element:zenith
CIELuminance::getLuminanceRatio = -> (@f(@χ) * @getφ(@ζ)) / (@f(@ζ_s) * @getφ(0))

# Equation 5 & 6: luminance gradation
#
# constraints:
# * 0 ≤ ζ ≤ (π / 2)
# * φ(0) = 1 + a exp b
# * φ(π / 2) = 1
CIELuminance::getφ = (ζ) ->
	a = @sky_type.a
	b = @sky_type.b

	# zenith
	if ζ <= 0
		1 + a * exp(b)
	# horizon
	else if ζ >= (π / 2)
		1
	else
		1 + a * exp(b / cos(ζ))

# Equation 7 & 8: scattering indicatrix given angular distance sun
CIELuminance::f = (angle) ->
	c = @sky_type.c
	d = @sky_type.d
	e = @sky_type.e

	1 + c * (exp(d * angle) - exp(d * (π / 2))) + e * pow(cos(angle), 2)
