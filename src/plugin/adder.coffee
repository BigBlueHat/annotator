BackboneEvents = require('backbone-events-standalone')
Util = require('../util')
$ = Util.$
_t = Util.TranslationString

ADDER_NS = 'annotator-adder'
ADDER_HIDE_CLASS = 'annotator-hide'
ADDER_HTML = """
             <div class="annotator-adder #{ADDER_HIDE_CLASS}">
               <button type="button">#{_t('Annotate')}</button>
             </div>
             """

# Public: Provide an adder button to use for creating annotations
class Adder

  constructor: (element) ->
    @element = element
    @ignoreMouseup = false

  configure: ({@core}) ->

  pluginInit: ->
    if @element.ownerDocument?
      @document = @element.ownerDocument
      $(@document.body).on("mouseup.#{ADDER_NS}", this._onMouseup)
      @adder = $(ADDER_HTML).appendTo(@document.body)[0]
      $(@adder)
      .on("click.#{ADDER_NS}", 'button', this._onClick)
      .on("mousedown.#{ADDER_NS}", 'button', this._onMousedown)

      this.listenTo(@core, 'selection', @onSelection)

    else
      console.warn("You created an instance of the Adder on an element that
                    doesn't have an ownerDocument. This won't work! Please
                    ensure the element is added to the DOM before the plugin is
                    configured:", @element)

  onSelection: (annotationSkeleton) =>
    if annotationSkeleton # Did we get any data?
      # We have received a prepared annotation skeleton.
      @selectedSkeleton = annotationSkeleton
      @show()
    else
      # No data means that this was a failed selection.
      # Hide the adder.
      @hide()

  destroy: ->
    this.stopListening()
    $(@adder)
    .off(".#{ADDER_NS}")
    .remove()
    $(@document.body).off(".#{ADDER_NS}")

  # Public: Show the adder.
  #
  # Returns nothing.
  show: =>
    if @core.interactionPoint?
      $(@adder).css({
        top: @core.interactionPoint.top,
        left: @core.interactionPoint.left
      })
    $(@adder).removeClass(ADDER_HIDE_CLASS)

  # Public: Hide the adder.
  #
  # Returns nothing.
  hide: =>
    $(@adder).addClass(ADDER_HIDE_CLASS)

  # Public: Returns true if the adder is currently displayed, false otherwise.
  #
  # Examples
  #
  #   adder.show()
  #   adder.isShown() # => true
  #
  #   adder.hide()
  #   adder.isShown() # => false
  #
  # Returns true if the adder is visible.
  isShown: ->
    not $(@adder).hasClass(ADDER_HIDE_CLASS)

  # Event callback: called when the mouse button is depressed on the adder.
  #
  # event - A mousedown Event object
  #
  # Returns nothing.
  _onMousedown: (event) =>
    # Do nothing for right-clicks, middle-clicks, etc.
    if event.which != 1
      return

    event?.preventDefault()
    # Prevent the selection code from firing when the mouse button is released
    @ignoreMouseup = true

  # Event callback: called when the mouse button is released
  #
  # event - A mouseup Event object
  #
  # Returns nothing.
  _onMouseup: (event) =>
    # Do nothing for right-clicks, middle-clicks, etc.
    if event.which != 1
      return

    # Prevent the selection code from firing when the ignoreMouseup flag is set
    if @ignoreMouseup
      event.stopImmediatePropagation()


  # Event callback: called when the adder is clicked. The click event is used as
  # well as the mousedown so that we get the :active state on the @adder when
  # clicked.
  #
  # event - A mousedown Event object
  #
  # Returns nothing.
  _onClick: (event) =>
    # Do nothing for right-clicks, middle-clicks, etc.
    if event.which != 1
      return

    event?.preventDefault()

    # Hide the adder
    this.hide()
    @ignoreMouseup = false

    # Create a new annotation
    @core.annotations.create(@selectedSkeleton)

BackboneEvents.mixin(Adder.prototype)

# This is a core plugin (registered by default with Annotator), so we don't
# register here. If you're writing a plugin of your own, please refer to a
# non-core plugin (such as Document or Store) to see how to register your plugin
# with Annotator.

module.exports = Adder
