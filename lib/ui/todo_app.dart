import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'main_page.dart';

///The todo app widget.
class TodoApp extends StatefulWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  @override
  Widget build(BuildContext context) => const MediaQuery(
      //Return a Cupertino App wrapped in a MediaQuery (the MediaQuery is providing metadata about the device to its descendants)
      data: MediaQueryData(),
      child: CupertinoApp(
        title: 'SI413 ToDo',
        home: MainPage(),
        debugShowCheckedModeBanner: false,
      ));
}
