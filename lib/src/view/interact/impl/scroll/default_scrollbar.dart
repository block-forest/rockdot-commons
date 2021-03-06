part of acanvas_commons;

/**
 * @author Nils Doehring (nilsdoehring@gmail.com)
 */
class DefaultScrollbar extends Scrollbar {
  int color;

  DefaultScrollbar({this.color: MdColor.BLACK}) : super() {
    background = AcGraphics.rectangle(0, 0, 10, 10, color: MdColor.TRANSPARENT);
    thumb = AcGraphics.rectangle(0, 0, 8, 8, color: color);
  }

  @override
  void refresh() {
    if (horizontalScrollBehavior) {
      AcGraphics.rectangle(0, 0, spanSize, 10,
          color: MdColor.TRANSPARENT, sprite: background);
      thumb.y = 1;
    } else {
      AcGraphics.rectangle(0, 0, 10, spanSize,
          color: MdColor.TRANSPARENT, sprite: background);
      thumb.x = 1;
    }

    super.refresh();
  }
}
