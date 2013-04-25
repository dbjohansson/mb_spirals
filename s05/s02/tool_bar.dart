part of mb;

class ToolBar {

  static final int SELECT = 1;
  static final int BOX = 2;

  final Board board;

  int _onTool = SELECT;
  bool _boxToolDblClicked = false;

  ToolBar(this.board) {
    ButtonElement selectButton = document.query('#select');
    ButtonElement boxButton = document.query('#box');

    // Tool bar events.
    selectButton.onClick.listen((MouseEvent e) {
      _onTool = SELECT;
    });
    selectButton.onDoubleClick.listen((MouseEvent e) {
      _onTool = SELECT;
      _boxToolDblClicked = false;
    });
    boxButton.onClick.listen((MouseEvent e) {
      _onTool = BOX;
    });
    boxButton.onDoubleClick.listen((MouseEvent e) {
      _onTool = BOX;
      _boxToolDblClicked = true;
    });
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

  void selectToolOn()  {
    if (!_boxToolDblClicked) {
      _onTool = SELECT;
    }
  }

}
