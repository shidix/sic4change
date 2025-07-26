import 'package:flutter/material.dart';
import 'package:sic4change/services/models_rrhh.dart';

class TreeNode extends StatefulWidget {
  final dynamic item;
  final dynamic label;
  int level;
  bool expanded = true;
  bool visible = true;
  ValueChanged<TreeNode> onSelected;
  // ValueChanged<TreeNode> onMainSelected;
  // ValueChanged<TreeNode> onEdit;
  // ValueChanged<TreeNode>? onDelete;

  TreeNode({
    required this.item,
    required this.label,
    required this.level,
    required this.onSelected,
    // required this.onMainSelected,
    // required this.onEdit,
    // required this.onDelete,
    this.expanded = true,
    this.visible = true,
  });

  @override
  _TreeNodeState createState() => _TreeNodeState();

  static TreeNode createTreeNode(Department item,
      {int level = 0,
      Function? onSelected,
      Function? onMainSelected,
      Function? onEdit,
      Function? onDelete,
      dynamic? mylabel}) {
    //Typecaste the item to the expected type

    TreeNode node = TreeNode(
        item: item,
        label: mylabel ?? item.name,
        level: level,
        onSelected: onSelected != null
            ? (node) {
                onSelected(node);
              }
            : (node) {
                // Default action if not provided
              },
        expanded: true, // Default to expanded
        visible: true // Default to visible
        );
    return node;
  }
}

class _TreeNodeState extends State<TreeNode> {
  dynamic get label => widget.label;
  int get level => widget.level;
  bool get expanded => widget.expanded;

  set expanded(bool value) {
    widget.expanded = value;
    // (value) ? expand() : collapse();
    if (mounted) {
      setState(() {});
      widget.onSelected(widget);
    }
  }

  set visible(bool value) {
    widget.visible = value;
    // if (widget.expanded) expand();
    setState(() {});
  }

  void toggle() {
    expanded = !expanded;
  }

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      Colors.green[50]!,
      Colors.green[100]!,
      Colors.green[200]!,
      Colors.green[300]!,
      Colors.green[400]!
    ];

    final GlobalKey _nodeKey = GlobalKey();
    Widget nodeLayout = Container(
      key: _nodeKey,
      decoration: (level > 0)
          ? const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey,
                  width: 2.0,
                ),
              ),
            )
          : const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.grey, // No border for level 0
                  width: 2.0,
                ),
                top: BorderSide(
                  color: Colors.black87, // No border for level 0
                  width: 2.0,
                ),
              ),
            ),
      child: ListTile(
        title: (label is String) ? Text(label) : label as Widget,
        onTap: () {
          widget.onSelected(widget);
        },
        tileColor: colors[(level) % colors.length],
        trailing: null,
      ),
    );

    List<Widget> identations = [];

    for (int i = 0; i < level; i++) {
      identations.add(
        Expanded(
          flex: 1,
          child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.grey, // No border for identation
                    width: 2.0,
                  ),
                ),
              ),
              child: ListTile(
                title: const Column(children: [
                  Text(' ', style: TextStyle(fontSize: 16)),
                  Text(' ', style: TextStyle(fontSize: 14)),
                  Text(' ', style: TextStyle(fontSize: 12)),
                ]), // Empty container for identation
                tileColor: colors[i % colors.length],
                onTap: () {
                  // Do nothing, just for the identation
                },
              )),
        ),
      );
    }
    return (widget.visible)
        ? Row(
            children: [
              ...identations,
              Expanded(flex: (14 - level), child: nodeLayout),
            ],
          )
        : Container();
  }
}
