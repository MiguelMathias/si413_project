import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'main_page.dart';

class TodoApp extends StatefulWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  @override
  Widget build(BuildContext context) => const MediaQuery(
      data: MediaQueryData(),
      child: CupertinoApp(title: 'SI413 ToDo', home: MainPage()));
}
