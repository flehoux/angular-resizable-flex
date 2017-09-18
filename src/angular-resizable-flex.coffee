(require 'angular')
.module 'angularResizableFlex', []

.directive 'resizableFlex', ->
  restrict: 'A'
  scope:
    rfName: '@'
    rfDirection: '@'
    rfSize: '='
    rfHandle: '='
    rfDisabled: '='
    rfInitCb: '&'
    rfCallback: '&'

  link: (scope, element) ->
    data =
     style: window.getComputedStyle element[0], null

    # Update FlexBasis with dynamic size
    scope.$watch 'rfSize', (size) -> if size? then setFlexBasis size

    getFlexBasis = -> element[0].style['flexBasis'].replace 'px', ''
    setFlexBasis = (size) -> element[0].style['flexBasis'] = size + 'px'

    getElementPos = (e) ->
      attr = if (scope.rfDirection is 'left' || scope.rfDirection is 'right') then 'clientX' else 'clientY'
      if e.touches? then e.touches[0][attr] else e[attr]

    bindListeners = ->
      document.addEventListener 'mouseup', onDragDrop
      document.addEventListener 'mousemove', onDragging
      document.addEventListener 'touchend', onDragDrop, { passive: true }
      document.addEventListener 'touchmove', onDragging, { passive: true }

    unbindListeners = ->
      document.removeEventListener 'mouseup', onDragDrop
      document.removeEventListener 'mousemove', onDragging
      document.removeEventListener 'touchend', onDragDrop
      document.removeEventListener 'touchmove', onDragging

    # Event handlers
    onDragStart = (e) ->
      return unless !scope.rfDisabled || (e.which is 1 || e.touches)
      bindListeners()

      data.initialWidth = parseInt data.style.getPropertyValue 'width'
      data.initialHeight = parseInt data.style.getPropertyValue 'height'
      data.initialPos = getElementPos e

      data.handle.classList.toggle 'rf-dragging', true

      if e.stopPropagation then e.stopPropagation()
      if e.preventDefault then e.preventDefault()

    onDragging = (e) ->
      offset = data.initialPos - getElementPos e
      switch scope.rfDirection
        when 'top'    then setFlexBasis data.initialHeight + offset
        when 'bottom' then setFlexBasis data.initialHeight - offset
        when 'right'  then setFlexBasis data.initialWidth - offset
        when 'left'   then setFlexBasis data.initialWidth + offset

    onDragDrop = ->
      unbindListeners()
      data.handle.classList.toggle 'rf-dragging', false
      if scope.rfCallback then scope.rfCallback rfObj: { name: scope.rfName, size: getFlexBasis() }

    instantiateHandle = ->
      # Create handle element
      data.handle = document.createElement 'div'
      data.handle.setAttribute 'class', 'rf-' + scope.rfDirection
      data.handle.innerHTML = if scope.rfHandle then scope.rfHandle else '<span></span>'
      element[0].appendChild data.handle

      # Register start events
      data.handle.addEventListener 'mousedown', onDragStart
      data.handle.addEventListener 'touchstart', onDragStart, { passive: true }

    init = ->
      if scope.rfInitCb then setFlexBasis scope.rfInitCb rfObj: { name: scope.rfName }
      instantiateHandle()  

    init()

    scope.$on '$destroy', ->
      unbindListeners()
      data.handle.removeEventListener 'mousedown', onDragStart
      data.handle.removeEventListener 'touchstart', onDragStart
