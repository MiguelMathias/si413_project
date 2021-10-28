import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'ui/loading.dart';
import 'ui/todo_app.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final _firebaseInit = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firebaseInit,
      builder: (context, snapshot) {
        //if(snapshot.hasError)
        if (snapshot.connectionState == ConnectionState.done) {
          return const TodoApp();
        }
        return const Loading();
      },
    );
  }
}
