part of mb;

class ToolBar {

  static final int SELECT = 1;
  static final int BOX = 2;
  static final int LINE = 3;

  final Board board;

  int _onTool;
  int _fixedTool;

  ButtonElement selectButton;
  ButtonElement boxButton;
  ButtonElement lineButton;

  ToolBar(this.board) {
    selectButton = document.query('#select');
    boxButton = document.query('#box');
    lineButton = document.query('#line');

    // Tool bar events.
    selectButton.onClick.listen((MouseEvent e) {
      onTool(SELECT);
    });
    selectButton.onDoubleClick.listen((MouseEvent e) {
      onTool(SELECT);
      _fixedTool = SELECT;
    });

    boxButton.onClick.listen((MouseEvent e) {
      onTool(BOX);
    });
    boxButton.onDoubleClick.listen((MouseEvent e) {
      onTool(BOX);
      _fixedTool = BOX;
    });

    lineButton.onClick.listen((MouseEvent e) {
      onTool(LINE);
    });
    lineButton.onDoubleClick.listen((MouseEvent e) {
      onTool(LINE);
      _fixedTool = LINE;
    });

    onTool(SELECT);
    _fixedTool = SELECT;
  }

  onTool(int tool) {
    _onTool = tool;
    if (_onTool == SELECT) {
      selectButton.style.borderColor = "#000000"; // black
      boxButton.style.borderColor = "#808080"; // grey
      lineButton.style.borderColor = "#808080"; // grey
    } else if (_onTool == BOX) {
      selectButton.style.borderColor = "#808080"; // grey
      boxButton.style.borderColor = "#000000"; // black
      lineButton.style.borderColor = "#808080"; // grey
    } else if (_onTool == LINE) {
      selectButton.style.borderColor = "#808080"; // grey
      boxButton.style.borderColor = "#808080"; // grey
      lineButton.style.borderColor = "#000000"; // black
    }
  }

  bool isSelectToolOn() {
    if (_onTool == SELECT) {
      return true;
    }
    return false;
  }

  bool isBoxToolOn() {
    if (_onTool == BOX) {
      return true;
    }
    return false;
  }

  bool isLineToolOn() {
    if (_onTool == LINE) {
      return true;
    }
    return false;
  }

  void backToFixedTool()  {
      onTool(_fixedTool);
  }

  void backToSelectAsFixedTool()  {
    onTool(SELECT);
    _fixedTool = SELECT;
  }

}
