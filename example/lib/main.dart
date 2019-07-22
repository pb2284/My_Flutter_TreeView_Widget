import 'package:flutter/material.dart';
import 'package:tree_view/tree_view.dart';

enum MenuOptions { add, delete }

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<TreeNode> forest = [];
  final List<Color> colours = [
    Colors.green.shade100,
    Colors.yellow.shade100,
    Colors.blue.shade100
  ];

  _HomeState() {
    forest.add(TreeNode("Asset Class", _rootBuilder)
      ..addChild(TreeNode("Equity", _branchBuilder))
      ..addChild(TreeNode("Bonds", _branchBuilder)
        ..addChild(TreeNode("Corporate", _branchBuilder))
        ..addChild(TreeNode("Government", _branchBuilder)))
      ..addChild(TreeNode("Property", _branchBuilder)));
    forest.add(TreeNode("Investment Type", _rootBuilder)
      ..addChild(TreeNode("Active", _branchBuilder))
      ..addChild(TreeNode("Passive", _branchBuilder)));
    forest.add(TreeNode("Region", _rootBuilder)
      ..addChild(TreeNode("Australia", _branchBuilder))
      ..addChild(TreeNode("USA", _branchBuilder))
      ..addChild(TreeNode("Global", _branchBuilder)));
  }

  Widget _rootBuilder(BuildContext context, TreeNode node) {
    return ListTile(
      title: Text(node.name),
      trailing: IconButton(
        icon: Icon(Icons.add),
      ),
    );
  }

  Widget _branchBuilder(BuildContext context, TreeNode node) {
    return ListTile(
        title: Text(
          node.name,
          softWrap: false,
        ),
        trailing: PopupMenuButton<MenuOptions>(
          itemBuilder: (_) {
            return <PopupMenuItem<MenuOptions>>[
              PopupMenuItem<MenuOptions>(
                value: MenuOptions.add,
                child: Icon(Icons.add),
              ),
              PopupMenuItem<MenuOptions>(
                value: MenuOptions.delete,
                child: Icon(Icons.delete),
              )
            ];
          },
          onSelected: (MenuOptions choice) async {
            switch (choice) {
              case MenuOptions.add:
                GlobalKey<FormState> formKey = GlobalKey<FormState>();
                TextEditingController inputController = TextEditingController();

                String newName = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Add Category"),
                        content: Form(
                          key: formKey,
                          child: TextFormField(
                            autofocus: true,
                            decoration: InputDecoration(
                                labelText: "Enter the category name:"),
                            controller: inputController,
                            validator: (value) {
                              if (value.isEmpty) return "Please enter a name";
                            },
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Cancel"),
                            onPressed: () => Navigator.pop(context, null),
                          ),
                          FlatButton(
                              child: Text("Add"),
                              onPressed: () async {
                                if (!formKey.currentState.validate()) return;
                                Navigator.pop(context, inputController.text);
                              })
                        ],
                      );
                    });
                if (newName != null) {
                  setState(() {
                    node.addChild(TreeNode(newName, _branchBuilder));
                    node.expanded = true;
                  });
                }
                break;
              case MenuOptions.delete:
                TreeNode parent = node.parent;
                setState(() {
                  parent.removeChild(node);
                });
                break;
            }
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test"),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(border: Border.all()),
          padding: EdgeInsets.all(10.0),
          child: Container(
              child: TreeView(
                forest,
                tileColours: colours,
              )),
        ),
      ),
    );
  }
}
