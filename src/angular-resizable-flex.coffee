(require 'angular')
.module 'angularResizableFlex', []

.directive 'resizableFlex', ->
  restrict: 'A'
  scope:
    rfName: '@'
    rfDirection: '@'
    rfSize: '='
    rfHandle: '@'
    rfDisabled: '='
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
      document.addEventListener 'mouseup', onDragDrop, false
      document.addEventListener 'mousemove', onDragging, false
      document.addEventListener 'touchend', onDragDrop, false
      document.addEventListener 'touchmove', onDragging, false

    unbindListeners = ->
      document.removeEventListener 'mouseup', onDragDrop, false
      document.removeEventListener 'mousemove', onDragging, false
      document.removeEventListener 'touchend', onDragDrop, false
      document.removeEventListener 'touchmove', onDragging, false

    # Event handlers
    onDragStart = (e) ->
      return unless !scope.rfDisabled || (e.which is 1 || e.touches)
      bindListeners()

      data.initialWidth = parseInt data.style.getPropertyValue 'width'
      data.initialHeight = parseInt data.style.getPropertyValue 'height'
      data.initialPos = getElementPos e

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
      if scope.rfCallback then scope.rfCallback rfObj: { name: scope.rfName, size: getFlexBasis() }

    instantiateHandle = ->
      # Create handle element
      data.handle = document.createElement 'div'
      data.handle.setAttribute 'class', 'rf-' + scope.rfDirection
      data.handle.innerHTML = if scope.rfHandle then scope.rfHandle else '<span></span>'
      element[0].appendChild data.handle

      # Register start events
      data.handle.addEventListener 'mousedown', onDragStart, false
      data.handle.addEventListener 'touchstart', onDragStart, false

    instantiateHandle()
