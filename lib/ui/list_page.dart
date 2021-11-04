import 'package:cupertino_list_tile/cupertino_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import '../model/todo.dart';

class ListPage extends StatefulWidget {
  final ListItem listItem;

  const ListPage({Key? key, required this.listItem}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          previousPageTitle: 'Lists',
          middle: Text(widget.listItem.name),
        ),
        child: ListView(
            children: widget.listItem.items
                .map((todoItem) => CupertinoListTile(
                      title: Text(todoItem.title),
                    ))
                .toList()),
      );
}
