part of mb;

class Box {

  static final num DEFAULT_WIDTH = 120;
  static final num DEFAULT_HEIGHT = 120;
  static final num DEFAULT_INCREMENT = 20;

  static final num SSS = 6; // selection square size
  static final num TBH = 20; // title box height
  static final num TOS = 4; // text offset size
  static final num IOS = TBH - TOS; // item offset size

  final Board board;

  String _name = 'Box';
  num x;
  num y;
  num width;
  num height;

  List<Item> items;

  bool _selected = false;
  bool _hidden = false;
  bool _mouseDown = false;

  String textFontSize = '12';
  num defaultLineWidth;

  Box(this.board, this.x, this.y, this.width, this.height) {
    defaultLineWidth = board.context.lineWidth;

    items = new List();

    draw();
    // Box events (actually, canvas events).
    document.query('#canvas').onMouseDown.listen(onMouseDown);
    document.query('#canvas').onMouseUp.listen(onMouseUp);
    document.query('#canvas').onMouseMove.listen(onMouseMove);
  }

  void draw() {
    if (!isHidden()) {
      board.context.beginPath();
      board.context.clearRect(x, y, width, height);
      board.context.rect(x, y, width, height);
      board.context.moveTo(x, y + TBH);
      board.context.lineTo(x + width, y + TBH);
      board.context.font = 'bold ${textFontSize}px sans-serif';
      board.context.textAlign = 'start';
      board.context.textBaseline = 'top';
      board.context.fillText(title, x + TOS, y + TOS, width - TOS);
      num i = 0;
      for (Item item in items) {
        if (item.category == 'attribute') {
          board.context.font = '${textFontSize}px sans-serif';
          board.context.fillText(item.name, x + TOS, y + TOS + TBH + i * IOS,
            width - TOS);
        } else if (item.category == 'guid') {
          board.context.font = 'italic ${textFontSize}px sans-serif';
          board.context.fillText(item.name, x + TOS, y + TOS + TBH + i * IOS,
            width - TOS);
        } else if (item.category == 'identifier') {
          board.context.font = 'bold italic ${textFontSize}px sans-serif';
          board.context.fillText(item.name, x + TOS, y + TOS + TBH + i * IOS,
            width - TOS);
        } else if (item.category == 'required') {
          board.context.font = 'bold ${textFontSize}px sans-serif';
          board.context.fillText(item.name, x + TOS, y + TOS + TBH + i * IOS,
            width - TOS);
        }
        i++;
      }
      if (isSelected()) {
        board.context.rect(x, y, SSS, SSS);
        board.context.rect(x + width - SSS, y, SSS, SSS);
        board.context.rect(x + width - SSS, y + height - SSS, SSS, SSS);
        board.context.rect(x, y + height - SSS, SSS, SSS);
      }
      board.context.lineWidth = defaultLineWidth;
      board.context.closePath();
      board.context.stroke();
    }
  }

  void select() {
    _selected = true;
    board.lastBoxSelected = this;
  }

  void deselect() {
    _selected = false;
    board.lastBoxSelected = null;
  }

  void toggleSelection() {
    _selected = !_selected;
    if (_selected) {
      board.lastBoxSelected = this;
    } else {
      board.lastBoxSelected = null;
    }
  }

  bool isSelected() => _selected;

  hide() => _hidden = true;
  show() => _hidden = false;
  bool isHidden() => _hidden;

  void set title(String name) {
    _name = name;
  }

  String get title {
    return _name;
  }

  Item findItem(String name) {
    for (Item item in items) {
      if (item.name == name) {
        return item;
      }
    }
    return null;
  }

  bool removeItem(Item item) {
    if (item != null) {
      num index = items.indexOf(item, 0);
      if (index >= 0) {
        items.removeRange(index, 1);
        return true;
      }
    }
    return false;
  }

  String toString() => '$title ($x, $y)';

  Point center() {
    num centerX = x + width / 2;
    num centerY = y + height / 2;
    return new Point(centerX, centerY);
  }

  bool contains(num pointX, num pointY) {
    if ((pointX > x && pointX < x + width)
        && (pointY > y && pointY < y + height)) {
      return true;
    }
    else {
      return false;
    }
  }

  /**
   * Return the intersection point of the line between the begin <x1,y1>
   * and end <x2,y2> points with this box;
   * <x1,y1> is inside the box, <x2,y2> may be inside or outside.
   * Fast algorithm.
   */
  Point getIntersectionPoint(Point lineBeginPoint, Point lineEndPoint) {
    num x1 = lineBeginPoint.x;
    num y1 = lineBeginPoint.y;
    num x2 = lineEndPoint.x;
    num y2 = lineEndPoint.y;
    if (x2 == x1) { /* vertical line */
      return new Point(x2, (y2 < y1 ? y : y + height));
    }
    if (y2 == y1) { /* horizontal line */
      return new Point((x2 < x1 ? x : x + width), y2);
    }

    num m = (y2 - y1) / (x2 - x1);
    num xx = (x2 < x1 ? x : x + width);
    num fy = m * (xx - x2) + y2;
    num yy;
    /* float comparison, because fy may be bigger than the biggest integer */
    if (fy >= y && fy <= y + height) {
      //yy = fy.toInt();
      yy = fy;
    } else {
      yy = (y2 < y1 ? y : y + height);
      xx = (fy - y2) ~/ m + x2;
    }
    return new Point(xx, yy);
  }

  void onMouseDown(MouseEvent e) {
    _mouseDown = true;
    if (board.toolBar.isSelectToolOn() && contains(e.offsetX, e.offsetY)) {
      toggleSelection();
    }
    if (contains(e.offsetX, e.offsetY)) {
      if (board.lastBoxClicked != null && board.lastBoxClicked != this) {
        board.beforeLastBoxClicked = board.lastBoxClicked;
      }
      board.lastBoxClicked = this;
    }
  }

  void onMouseUp(MouseEvent e) {
    _mouseDown = false;
  }

  /** Change a position of the box with mouse mouvements. */
  void onMouseMove(MouseEvent e) {
    if (contains(e.offsetX, e.offsetY) && isSelected() && _mouseDown &&
        board.countSelectedBoxesContain(e.offsetX, e.offsetY) < 2) {
      x =  e.offsetX - width / 2;
      if (x < 0) {
        x = 1;
      }
      if (x > board.width - width) {
        x = board.width - width - 1;
      }
      y = e.offsetY - height / 2;
      if (y < 0) {
        y = 1;
      }
      if (y > board.height - height) {
        y = board.height - height - 1;
      }
    }
  }

}
