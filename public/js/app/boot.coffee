window.Illuminate or= {}

(($) ->
	$template = $("#template")

	Illuminate.Router = Backbone.Router.extend
		routes:
			"": "home"

		home: ->
			view = new Illuminate.View
				template: $template.html()

			$("#content").html view.render().$el

	new Illuminate.Router

	Backbone.history.start()

	$template.hide()

)(window.$ or window.jQuery)
