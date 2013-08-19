# Utility
if ( typeof Object.create isnt 'function' )
	Object.create = (obj) ->
		F = ->
		F.prototype = obj
		new F()

# The plugin
;(($, window, document) ->
	'use strict'

	Twitter =
		init: (options, elem)->
			self = this
			self.elem = elem
			self.$elem = $(elem)
			self.url = 'http://api.twitter.com/1.1/search/tweets.json'

			# user may pass into a string or an object
			if ( typeof options is 'string' )
				self.search = options
			else
				# an object was passed
				self.earch = options.search
			
			self.options = $.extend({}, $.fn.queryTwitter.options, options)

			self.refresh(1)

		# refresh() call everything, it's gonna fetch, display, almost like a controller
		refresh: (length )->
			self = this

			setTimeout( ->
				self.fetch().done( (results)->
					results = self.limit( results.results, self.options.limit )
					self.buildFrag(results)
					self.display()
					# if user pass in a callback function, then call it
					if (typeof self.options.onComplete is 'function')
						self.options.onComplete.apply( self.elem, arguments )

					if( self.options.refresh() )
						self.refresh()
					# explanation: the first time, the tweets will show in 'length' milliseconds
					# when refresh, this time 'length' variable is not pass, it's undefined, then self.options.refresh will take effect
				)
			, length || self.options.refresh )

		# get tweets
		fetch: ->
			return $.ajax
				url: this.url
				data: {q: this.search}
				dataType: 'jsonp'

		# wrap the each result in HTML tag
		buildFrag: (results)->
			self = this

			self.tweets = $.map( results, (obj, i) ->
				$( self.options.wrapEachWith ).append(obj.text)[0] # use [0] to get to the node
			)

		# display tweets
		display: ->
			self = this # cache

			# if user don't want transition effect
			if ( self.options.transition is 'none' || !self.options.transition)
				self.$elem.html( self.tweets ) # tweets is available?
			else
				self.$elem[ self.options.transition ]( 500, ->
					$(this).html(self.tweets)[ self.options.transition ](500)
				)

		# limit the tweet show on page each time
		limit: ( obj, count ) ->
			obj.slice(0, count)


	$.fn.queryTwitter = (options)->
		# Note: this inside 'fn' is wrap in jQuery object
		return this.each( ->
			twitter = Object.create( Twitter )
			twitter.init( options, this ) # this is refer to the node that is call on, not wrapped in jQuery

			# save a copy of instance, just in case the user want to modify it
			$.data( this, 'queryTwitter', twitter)
		)

	$.fn.queryTwitter.options =
		search: '@tuspremium'
		wrapEachWith: '<li></li>'
		limit: 10
		refresh: null
		onComplete: null
		transition: 'fadeToggle'

)(jQuery, window, document) 

# ideally, after query, you may save result to a database...
