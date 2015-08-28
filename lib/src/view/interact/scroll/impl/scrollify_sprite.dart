part of stagexl_commons;


/**
 * @author Nils Doehring (nilsdoehring@gmail.com)
 */
class ScrollifySprite extends BehaveSprite with MScroll, MSlider {

  //Sprites
  Sprite _view;

  Sprite get view => _view;

  Scrollbar _hScrollbar;
  Scrollbar _vScrollbar;

  // Zoom States
  bool _viewZoomed = false;
  num _normalizedValueH = 0;
  num _normalizedValueV = 0;

  // Touch States
  bool _touching = false;
  num _mouseOffsetX = 0;
  num _mouseOffsetY = 0;

  // Scroll States
  String _orientation;
  bool _interaction = false;
  bool _changing = false;
  bool _interactionH = false;
  bool _changingH = false;
  bool _interactionV = false;
  bool _changingV = false;

  ScrollifySprite(Sprite view, Scrollbar hScrollbar, Scrollbar vScrollbar) {


    _view = view;
    if (_view.parent == null) {
      addChild(_view);
    }
    _hScrollbar = hScrollbar;
    _vScrollbar = vScrollbar;

    _addScrollbars();

    mouseWheelEnabled = ContextTool.MOBILE ? false : true;
    touchable = ContextTool.MOBILE ? true : false;
  }

  @override
  void refresh() {
    _hScrollbar.y = spanHeight - _hScrollbar.height;
    _vScrollbar.x = spanWidth - _vScrollbar.width;

    if (maskEnabled) {
      _view.mask = new Mask.rectangle(0, 0, spanWidth, spanHeight)
        ..relativeToParent = true;
    }

    super.refresh();

    updateScrollbars();

    GraphicsUtil.rectangle(0, 0, spanWidth, spanHeight, color: 0x00FF0000, sprite: view.parent);
  }


  /// ---------- SCROLL BARS

  void _addScrollbars() {
    // H
    _hScrollbar.inheritSpan = true;
    _hScrollbar.horizontalScrollBehavior = true;
    _hScrollbar.mouseWheelSensitivity = 10;
    _hScrollbar.addEventListener(SliderEvent.VALUE_CHANGE, _onHScrollbarChange, useCapture: false, priority: 0);
    _hScrollbar.addEventListener(SliderEvent.INTERACTION_START, _onScrollbarInteractionStart, useCapture: false, priority: 0);
    _hScrollbar.addEventListener(SliderEvent.INTERACTION_END, _onScrollbarInteractionEnd, useCapture: false, priority: 0);
    _hScrollbar.addEventListener(SliderEvent.CHANGE_START, _onScrollbarChangeStart, useCapture: false, priority: 0);
    _hScrollbar.addEventListener(SliderEvent.CHANGE_END, _onScrollbarChangeEnd, useCapture: false, priority: 0);
    _view.parent.addChildAt(_hScrollbar, _view.parent.numChildren);

    //V
    _vScrollbar.inheritSpan = true;
    _vScrollbar.mouseWheelSensitivity = 10;
    _vScrollbar.addEventListener(SliderEvent.VALUE_CHANGE, _onVScrollbarChange, useCapture: false, priority: 0);
    _vScrollbar.addEventListener(SliderEvent.INTERACTION_START, _onScrollbarInteractionStart, useCapture: false, priority: 0);
    _vScrollbar.addEventListener(SliderEvent.INTERACTION_END, _onScrollbarInteractionEnd, useCapture: false, priority: 0);
    _vScrollbar.addEventListener(SliderEvent.CHANGE_START, _onScrollbarChangeStart, useCapture: false, priority: 0);
    _vScrollbar.addEventListener(SliderEvent.CHANGE_END, _onScrollbarChangeEnd, useCapture: false, priority: 0);
    _view.parent.addChildAt(_vScrollbar, _view.parent.numChildren);

  }

  void _onScrollbarInteractionStart(SliderEvent event) {
    if (event.target == _hScrollbar) _interactionH = true; else _interactionV = true;
    interactionStart();
  }

  void _onScrollbarInteractionEnd(SliderEvent event) {
    if (event.target == _hScrollbar) _interactionH = false; else _interactionV = false;
    if (!_interactionH && !_interactionV) interactionEnd();
  }

  void _onScrollbarChangeStart(SliderEvent event) {
    if (event.target == _hScrollbar) _changingH = true; else _changingV = true;
    changeStart();
  }

  void _onScrollbarChangeEnd(SliderEvent event) {
    if (event.target == _hScrollbar) _changingH = false; else _changingV = false;
    if (!_changingH && !_changingV) changeEnd();
  }

  void interactionStart() {
    if (!_interaction) {
      _interaction = true;
      dispatchEvent(new ScrollifyEvent(ScrollifyEvent.INTERACTION_START));
    }
  }

  void interactionEnd() {
    if (_interaction) {
      _interaction = false;
      dispatchEvent(new ScrollifyEvent(ScrollifyEvent.INTERACTION_END));
    }
  }

  void changeStart() {
    if (!_changing) {
      _changing = true;
      if (autoHideScrollbars) {
        if (_hScrollbar.enabled) ContextTool.JUGGLER.addTween(_hScrollbar, 0.1)
          ..animate.alpha.to(1);
        if (_vScrollbar.enabled) ContextTool.JUGGLER.addTween(_vScrollbar, 0.1)
          ..animate.alpha.to(1);
      }
      dispatchEvent(new ScrollifyEvent(ScrollifyEvent.CHANGE_START));
    }
  }

  void changeEnd() {
    if (_changing) {
      _changing = false;
      if (autoHideScrollbars) {
        if (_hScrollbar.enabled) ContextTool.JUGGLER.addTween(_hScrollbar, 0.8)
          ..animate.alpha.to(0);
        if (_vScrollbar.enabled) ContextTool.JUGGLER.addTween(_vScrollbar, 0.8)
          ..animate.alpha.to(0);
      }
      dispatchEvent(new ScrollifyEvent(ScrollifyEvent.CHANGE_END));
    }
  }

  void updateScrollbars() {
    num w = useNativeWidth || !(_view is MBox) ? _view.width : (_view as MBox).spanWidth;
    num h = useNativeHeight || !(_view is MBox) ? _view.height : (_view as MBox).spanHeight;

    _hScrollbar.enabled = w > spanWidth;
    _hScrollbar.valueMax = w - spanWidth;

    _vScrollbar.enabled = h > spanHeight;
    _vScrollbar.valueMax = h - spanHeight;

    if (_hScrollbar.enabled || _vScrollbar.enabled) {
      mouseWheelEnabled = true;
    }

    _updateThumbs();
  }

  void _updateThumbs() {
    num w = useNativeWidth || !(_view is MBox) ? _view.width : (_view as MBox).spanWidth;
    num h = useNativeHeight || !(_view is MBox) ? _view.height : (_view as MBox).spanHeight;
    if (spanWidth > 0) {
      _hScrollbar.pageCount = w / spanWidth;
    }
    if (spanHeight > 0) {
      _vScrollbar.pageCount = h / spanHeight;
    }
  }


  /// ---------- KEYBOARD

  @override
  void set keyboardEnabled(bool value) {
    if (keyboardEnabled == value) return;
    super.keyboardEnabled = value;
    if (keyboardEnabled) {
      addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown, useCapture: false, priority: 0);
      ContextTool.ContextTool.STAGE.focus = this;
    }
    else removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
  }

  void _onKeyDown(KeyboardEvent event) {
    switch (event.keyCode) {
      case KeyCode.UP:
        if (_vScrollbar.enabled) {
          clearMomentum();
          _vScrollbar.interactionStart(true, false);
          _vScrollbar.value -= scrollStep;
          _vScrollbar.interactionEnd();
        }
        break;
      case KeyCode.DOWN:
        if (_vScrollbar.enabled) {
          clearMomentum();
          _vScrollbar.interactionStart(true, false);
          _vScrollbar.value += scrollStep;
          _vScrollbar.interactionEnd();
        }
        break;
      case KeyCode.LEFT:
        if (_hScrollbar.enabled) {
          clearMomentum();
          _hScrollbar.interactionStart(true, false);
          _hScrollbar.value -= scrollStep;
          _hScrollbar.interactionEnd();
        }
        break;
      case KeyCode.RIGHT:
        if (_hScrollbar.enabled) {
          clearMomentum();
          _hScrollbar.interactionStart(true, false);
          _hScrollbar.value += scrollStep;
          _hScrollbar.interactionEnd();
        }
        break;
      case KeyCode.SPACE:
        if (_vScrollbar.enabled) {
          clearMomentum();
          if (!event.shiftKey) _vScrollbar.pageDown(); else _vScrollbar.pageUp();
        }
        break;
      case KeyCode.PAGE_DOWN:
        if (_vScrollbar.enabled) {
          clearMomentum();
          _vScrollbar.pageDown();
        }
        break;
      case KeyCode.PAGE_UP:
        if (_vScrollbar.enabled) {
          clearMomentum();
          _vScrollbar.pageUp();
        }
        break;
      case KeyCode.HOME:
        Scrollbar scroller = horizontalScrollBehavior ? _hScrollbar : _vScrollbar;
        if (scroller.enabled) {
          scroller.killPageTween();
          clearMomentum();
          scroller.scrollToPage(0);
        }
        break;
      case KeyCode.END:
        Scrollbar scroller = horizontalScrollBehavior ? _hScrollbar : _vScrollbar;
        if (scroller.enabled) {
          scroller.killPageTween();
          clearMomentum();
          scroller.scrollToPage(scroller.pageCount, 0, true);
        }
        break;
      default:
    }
  }


  /// ---------- MOUSE WHEEL
  @override void set mouseWheelEnabled(bool value) {
    if (_mouseWheelEnabled == value) {
      return;
    }
    _mouseWheelEnabled = value;
    if (_mouseWheelEnabled) _view.parent.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel, useCapture: false, priority: 0);
    else _view.parent.removeEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
  }

  void _onMouseWheel(MouseEvent event) {
    clearMomentum();
    if (event.shiftKey) {
      if (_hScrollbar.enabled) _hScrollbar._onMouseWheel(event); else if (_vScrollbar.enabled) _vScrollbar._onMouseWheel(event);
    } else {
      if (_vScrollbar.enabled) _vScrollbar._onMouseWheel(event); else if (_hScrollbar.enabled) _hScrollbar._onMouseWheel(event);
    }
    event.stopImmediatePropagation();
  }

  void _onHScrollbarChange(SliderEvent event) {
    ContextTool.MATERIALIZE_REQUIRED = true;
    _view.x = -event.value;
  }

  void _onVScrollbarChange(SliderEvent event) {
    ContextTool.MATERIALIZE_REQUIRED = true;
    _view.y = -event.value;
  }

  @override
  void set bounce(bool value) {
    if (value != _bounce) _bounce = _hScrollbar.bounce = _vScrollbar.bounce = value;
  }

  @override
  void set snapToPages(bool value) {
    if (value != snapToPages) super.snapToPages = _hScrollbar.snapToPages = _vScrollbar.snapToPages = value;
  }

  @override
  void set doubleClickToZoom(bool value) {
    _doubleClickToZoom = value;
    if (_doubleClickToZoom) {
      _view.addEventListener(MouseEvent.DOUBLE_CLICK, _onViewDoubleClick, useCapture: false, priority: 0);
    }
    else {
      _view.removeEventListener(MouseEvent.DOUBLE_CLICK, _onViewDoubleClick);
    }
  }

  void _onViewDoubleClick(MouseEvent event) {
    zoom(_viewZoomed ? _zoomOutValue : _zoomInValue, event.localX, event.localY);
    _viewZoomed = !_viewZoomed;
  }

  void zoom(num scale, num xPos, num yPos) {
    if (_hScrollbar.enabled) _normalizedValueH = _hScrollbar.value / _hScrollbar.valueMax;
    if (_vScrollbar.enabled) _normalizedValueV = _vScrollbar.value / _vScrollbar.valueMax;

    interactionStart();
    changeStart();

    _normalizedValueH = (xPos - spanWidth / (2 * scale)) / ((_view.width / _view.scaleX) - spanWidth / scale);
    _normalizedValueV = (yPos - spanHeight / (2 * scale)) / ((_view.height / _view.scaleY) - spanHeight / scale);


    ContextTool.JUGGLER.addTween(_view, 0.3)
      ..animate.scaleX.to(scale)
      ..animate.scaleY.to(scale)
      ..onUpdate = (() => _keepPos)
      ..onComplete = (() => _onZoomConplete);


    interactionEnd();
  }

  void _keepPos() {
    updateScrollbars();

    int valH = _normalizedValueH * _hScrollbar.valueMax;
    if (valH < 0) valH = 0; else if (valH > _hScrollbar.valueMax) valH = _hScrollbar.valueMax;

    int valV = _normalizedValueV * _vScrollbar.valueMax;
    if (valV < 0) valV = 0; else if (valV > _vScrollbar.valueMax) valV = _vScrollbar.valueMax;

    _hScrollbar.value = valH;
    _vScrollbar.value = valV;
  }

  void _onZoomConplete() {
    changeEnd();
  }

  @override
  void set touchable(bool value) {
    super.touchable = value;

    _hScrollbar.momentumEnabled = touchable;
    _vScrollbar.momentumEnabled = touchable;
    if (touchable) {
      if (ContextTool.TOUCH) {
        _view.parent.addEventListener(TouchEvent.TOUCH_BEGIN, _onViewMouseDown, useCapture: false, priority: 0);
      }
      else {
        _view.parent.addEventListener(MouseEvent.MOUSE_DOWN, _onViewMouseDown, useCapture: false, priority: 0);
      }
    }
    else {
      if (ContextTool.TOUCH) {
        _view.parent.removeEventListener(TouchEvent.TOUCH_BEGIN, _onViewMouseDown);
      }
      else {
        _view.parent.removeEventListener(MouseEvent.MOUSE_DOWN, _onViewMouseDown);
      }
    }
  }

  void _onViewMouseDown(InputEvent event) {
    print("Touch down");
    _touching = true;
    if (_hScrollbar.enabled) _hScrollbar.interactionStart(false, false);
    if (_vScrollbar.enabled) _vScrollbar.interactionStart(false, false);
    _mouseOffsetX = event.stageX - _view.x;
    _mouseOffsetY = event.stageY - _view.y;
    if (ContextTool.TOUCH) {
      ContextTool.STAGE.addEventListener(TouchEvent.TOUCH_END, _onStageMouseUp, useCapture: false, priority: 0);
      ContextTool.STAGE.addEventListener(TouchEvent.TOUCH_MOVE, _onStageMouseMove, useCapture: false, priority: 0);
    }
    else {
      ContextTool.STAGE.addEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp, useCapture: false, priority: 0);
      ContextTool.STAGE.addEventListener(MouseEvent.MOUSE_MOVE, _onStageMouseMove, useCapture: false, priority: 0);
    }
  }

  void _onStageMouseUp(InputEvent event) {
    print("Touch up");
    _touching = false;
    if (_hScrollbar.enabled) _hScrollbar.interactionEnd();
    if (_vScrollbar.enabled) _vScrollbar.interactionEnd();
      if (ContextTool.TOUCH) {
        ContextTool.STAGE.removeEventListener(TouchEvent.TOUCH_END, _onStageMouseUp);
        ContextTool.STAGE.removeEventListener(TouchEvent.TOUCH_MOVE, _onStageMouseMove);
      }
      else {
        ContextTool.STAGE.removeEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);
        ContextTool.STAGE.removeEventListener(MouseEvent.MOUSE_MOVE, _onStageMouseMove);
      }
  }

  void clearMomentum() {
    _hScrollbar.clearMomentum();
    _vScrollbar.clearMomentum();
  }

  void _onStageMouseMove(InputEvent event) {
    print("Touch move");
    if (_hScrollbar.enabled) _hScrollbar.value = _mouseOffsetX - event.stageX;
    if (_vScrollbar.enabled) _vScrollbar.value = _mouseOffsetY - event.stageY;
    // event.updateAfterEvent();
  }

  @override
  void set autoHideScrollbars(bool value) {
    super.autoHideScrollbars = value;
    if (_hScrollbar.enabled) {
      ContextTool.JUGGLER.addTween(_hScrollbar, 0.2)
        ..animate.alpha.to(autoHideScrollbars ? 0 : 1);
    }
    if (_vScrollbar.enabled) {
      ContextTool.JUGGLER.addTween(_vScrollbar, 0.2)
        ..animate.alpha.to(autoHideScrollbars ? 0 : 1);
    }
  }
}