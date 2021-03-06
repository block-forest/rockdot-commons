part of acanvas_commons;

class MdTabs extends BoxSprite {
  int bgColor;
  int highlightColor;
  int strokeColor;
  bool distributeTabs;

  Sprite _bg;
  Sprite _slideBar;

  Flow tabBox;

  int _activeButtonIndex = 0;

  MdTabs(
      {this.highlightColor: MdColor.WHITE,
      this.strokeColor: MdColor.WHITE,
      this.bgColor: MdColor.BLACK,
      this.distributeTabs: true})
      : super() {
    _bg = new Sprite();
    addChild(_bg);

    tabBox = new Flow()
      ..spacing = 0
      ..flowOrientation = FlowOrientation.HORIZONTAL;
    addChild(tabBox);

    _slideBar = new Sprite();
    addChild(_slideBar);
  }

  void addTab(Button btn) {
    btn.submitCallback = _onTabClick;
    btn.submitCallbackParams = <dynamic>[btn, tabBox.numChildren];
    tabBox.addChild(btn);
  }

  void activateTabByUrl(String url) {
    for (int i = 0; i < tabBox.numChildren; i++) {
      if ((tabBox.getChildAt(i) as Button).submitEvent.data == url) {
        _onTabClick(tabBox.getChildAt(i) as Button, i);
      }
    }
  }

  void _onTabClick(Button btn, int index) {
    _activeButtonIndex = index;
    Ac.JUGGLER.addTween(_slideBar, .3, Transition.easeOutCubic).animate
      ..x.to(btn.x);
    _slideBar.width = btn.spanWidth;
  }

  @override
  void refresh() {
    AcGraphics.rectangle(0, 0, spanWidth, spanHeight,
        sprite: _bg, color: bgColor);

    tabBox.x = 0;

    if (tabBox.numChildren > 0) {
      if (distributeTabs) {
        for (int i = 0; i < tabBox.numChildren; i++) {
          Button btn = tabBox.getChildAt(i) as Button;
          btn.span(((spanWidth) / tabBox.numChildren), 0);
        }
        tabBox.refresh();
      }

      tabBox.y = spanHeight - tabBox.height;

      AcGraphics.line(
          (tabBox.getChildAt(_activeButtonIndex) as Button).spanWidth, 0,
          strength: 2, sprite: _slideBar, color: strokeColor);

      _slideBar.x = tabBox.getChildAt(_activeButtonIndex).x;
      _slideBar.y = spanHeight - 1;
    } else {
      _slideBar.visible = false;
    }
    super.refresh();
  }

  ///addresses a sizing bug with Graphics tool
  num get width => super.width;

  num get spanWidth => super.spanWidth;
}
