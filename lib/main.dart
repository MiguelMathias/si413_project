import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: () async {
        final firebaseInit = Firebase.initializeApp();
        if (kIsWeb) {
          await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
          await FirebaseFirestore.instance.enablePersistence();
        } else {
          FirebaseFirestore.instance.settings = const Settings(
              persistenceEnabled: true,
              cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
        }
        //Disable network
        //await FirebaseFirestore.instance.disableNetwork()
        return firebaseInit;
      }(),
      builder: (context, snapshot) {
        //if(snapshot.hasError)
        if (snapshot.connectionState == ConnectionState.done) {
          return const TodoApp();
        }
        return const MediaQuery(
            data: MediaQueryData(),
            child: CupertinoApp(title: 'SI413 ToDo', home: Loading()));
      },
    );
  }
}
