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
  final Forest forest = Forest();
  final List<Color> colours = [
    Colors.green.shade100,
    Colors.yellow.shade100,
    Colors.blue.shade100
  ];

  _HomeState() {
    forest.addRoot(TreeNode("Asset Class",)
      ..addChild(TreeNode("Equity",))
      ..addChild(TreeNode("Bonds", )
        ..addChild(TreeNode("Corporate",))
        ..addChild(TreeNode("Government",)))
      ..addChild(TreeNode("Property", )));
    forest.addRoot(TreeNode("Investment Type", )
      ..addChild(TreeNode("Active", ))
      ..addChild(TreeNode("Passive", )));
    forest.addRoot(TreeNode("Region", )
      ..addChild(TreeNode("Australia", ))
      ..addChild(TreeNode("USA", ))
      ..addChild(TreeNode("Global", )));
  }

  Widget _rootBuilder(BuildContext context, TreeNode node) {
    return ListTile(
      title: Text(node.name),
      trailing: IconButton(
        icon: Icon(Icons.add),
        onPressed: () async {
          String name =
              await showNameEntryDialog(context, "Enter the Category Name");
          if (name == null) return;
          setState(() {
            node.addChild(TreeNode(name,));
            node.expanded = true;
          });
        },
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
                String newName =
                    await showNameEntryDialog(context, "Add a Category");
                if (newName != null) {
                  setState(() {
                    node.addChild(TreeNode(newName,));
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

  Future<String> showNameEntryDialog(BuildContext context, String title) async {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController inputController = TextEditingController();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Form(
              key: formKey,
              child: TextFormField(
                autofocus: true,
                decoration: InputDecoration(labelText: "Enter the name:"),
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
            builder: _tileBuilder,
            tileColours: colours,
          )),
        ),
      ),
    );
  }

  Widget _tileBuilder(BuildContext context, TreeNode node) {
    return node.parent == null
        ? _rootBuilder(context, node)
        : _branchBuilder(context, node);
  }
}
