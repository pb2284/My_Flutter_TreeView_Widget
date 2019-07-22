library tree_view;

import "package:flutter/material.dart";

typedef TreeNodeTileBuilder = Widget Function(BuildContext,TreeNode);

/// A TreeNode stores properties of a category in a TreeView.
/// It holds a reference to its parent, if there is one.
/// It contains a list of children.
class TreeNode {

  final String name;
  final TreeNodeTileBuilder tileBuilder;

  bool expanded;

  TreeNode _parentNode;
  List<TreeNode> _children = [];
  int _nodeDepth = 0;

  TreeNode(this.name, this.tileBuilder, {this.expanded = false});

  List<TreeNode> get children => _children;

  int get depth => _nodeDepth;
  set _depth(int newDepth) {
    _nodeDepth = newDepth;
    _updateChildDepths(newDepth+1);
  }

  TreeNode get parent => _parentNode;
  set _parent(TreeNode node) {
    _parentNode = node;
    _depth = node.depth + 1;
  }

  TreeNode getChildAt(int index) => _children[index];
  void addChild(TreeNode child) {
    child._parent = this;
    _children.add(child);
  }
  void removeChild(TreeNode child) {
    _children.remove(child);
  }
  int get howManyChildren => _children.length;
  bool get hasChildren => _children.length>0;

  void _updateChildDepths(int childDepth) {
    for(TreeNode child in _children)
      child._depth = childDepth;
  }

  List<String> get namesOfChildren {
    List<String> names = [];
    for(TreeNode node in _children)
      names.add(node.name);
    return names;
  }
}

/// A container class for TreeNodes
class Forest with ChangeNotifier {

  List<TreeNode> _forest = [];

  Forest();
  Forest.fill(List<TreeNode> nodeList) {
    _forest = List.from(nodeList);
  }

  List<TreeNode> get forest => _forest;

  int get numberOfTrees => _forest.length;

  TreeNode getRootNodeAt(int index) => _forest[index];

  List<String> get rootNames {
    List<String> names = [];
    for(TreeNode root in _forest)
      names.add(root.name);
    return names;
  }

  void addRoot(TreeNode node) {
    _forest.add(node);
    notifyListeners();
  }

  void removeRoot(TreeNode root) {
    if(!_forest.contains(root))
      return;
    _forest.remove(root);
    notifyListeners();
  }
}

/// A TreeView widget.
/// The TreeView returns a list view with a nested structure.
/// Tiles corresponding to nodes with children can be expanded and collapsed.
/// The appearance can be customised in various ways:
///   * indentPerLevel specifies how much the left-side inset increases with
/// each level of nesting.
///   * if tileColours is specified, then each level of categories will be shown
///   inside a box filled with one of the colours. Colours are selected by
///   nested depth % number of colours provided.
///   * categoryBorder can be used to provide a border around the box for each level
///   * finally, the user supplies a TreeNodeTileBuilder callback with each
///   TreeNode. This builder is used to construct the content of the tile.
class TreeView extends StatefulWidget {
  final List<TreeNode> roots;
  final double indentPerLevel;
  final List<Color> tileColours;
  final Border categoryBorder;

  const TreeView(this.roots,
      {Key key,
        this.indentPerLevel = 25.0,
        this.tileColours,
        this.categoryBorder})
      : super(key: key);

  @override
  _TreeViewState createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.roots.length,
        itemBuilder: (BuildContext context, int index) {
          TreeNode root = widget.roots[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildTree(root),
          );
        });
  }

  List<Widget> _buildTree(TreeNode node) {
    List<Widget> tiles = [];
    Color colour = widget.tileColours == null
        ? null
        : widget.tileColours[node.depth % widget.tileColours.length];
    tiles.add(Flexible(
        fit: FlexFit.loose,
        child: Container(
          decoration: BoxDecoration(color: colour),
          child: _buildNodeTile(node),
        )));

    List<Widget> children = [];
    if (node.expanded) {
      for (int index = 0; index < node.howManyChildren; index++) {
        children.addAll(_buildTree(node.getChildAt(index)));
      }
    }
    BorderSide borderSide = BorderSide(color: Colors.grey, width: 1.0);
    colour = widget.tileColours == null
        ? null
        : widget.tileColours[(node.depth + 1) % widget.tileColours.length];
    tiles.add(Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: widget.indentPerLevel),
        ),
        Flexible(
          fit: FlexFit.loose,
          child: Container(
            decoration: BoxDecoration(border: widget.categoryBorder),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
      ],
    ));

    return tiles;
  }

  Widget _buildNodeTile(TreeNode node) {
    Icon expansionIcon =
    Icon(node.expanded ? Icons.expand_less : Icons.expand_more);
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
      leading: node.hasChildren
          ? IconButton(
          icon: expansionIcon,
          onPressed: () {
            setState(() {
              node.expanded = !node.expanded;
            });
          })
          : Container(
        padding: EdgeInsets.only(left: 18.0, right: 6.0),
        child: Icon(
          Icons.subdirectory_arrow_right,
          size: 22.0,
        ),
      ),
      title: node.tileBuilder(this.context, node),
    );
  }
}