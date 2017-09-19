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
      document.addEventListener 'mouseup', onDragDrop, if passiveSupported then { passive: true } else false
      document.addEventListener 'mousemove', onDragging, if passiveSupported then { passive: true } else false
      document.addEventListener 'touchend', onDragDrop, if passiveSupported then { passive: true } else false
      document.addEventListener 'touchmove', onDragging, if passiveSupported then { passive: true } else false

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

      data.handle.classList.add 'rf-dragging'

    onDragging = (e) ->
      offset = data.initialPos - getElementPos e
      switch scope.rfDirection
        when 'top'    then setFlexBasis data.initialHeight + offset
        when 'bottom' then setFlexBasis data.initialHeight - offset
        when 'right'  then setFlexBasis data.initialWidth - offset
        when 'left'   then setFlexBasis data.initialWidth + offset

    onDragDrop = ->
      unbindListeners()
      data.handle.classList.remove 'rf-dragging'
      if scope.rfCallback then scope.rfCallback rfObj: { name: scope.rfName, size: getFlexBasis() }

    passiveSupported = false
    passiveSupportCheck = ->
      try
        options = Object.defineProperty({}, "passive", {
          get: () => passiveSupported = true;
        });

        window.addEventListener("test", null, options);
      catch error

    instantiateHandle = ->
      # Create handle element
      data.handle = document.createElement 'div'
      data.handle.setAttribute 'class', 'rf-' + scope.rfDirection
      data.handle.innerHTML = if scope.rfHandle then scope.rfHandle else '<span></span>'
      element[0].appendChild data.handle

      # Register start events
      data.handle.addEventListener 'mousedown', onDragStart, if passiveSupported then { passive: true } else false
      data.handle.addEventListener 'touchstart', onDragStart, if passiveSupported then { passive: true } else false

    init = ->
      if scope.rfInitCb then setFlexBasis scope.rfInitCb rfObj: { name: scope.rfName }
      passiveSupportCheck()
      instantiateHandle()

    init()

    scope.$on '$destroy', ->
      unbindListeners()
      data.handle.removeEventListener 'mousedown', onDragStart
      data.handle.removeEventListener 'touchstart', onDragStart
