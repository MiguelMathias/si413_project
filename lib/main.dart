import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'ui/loading.dart';
import 'ui/todo_app.dart';

///The main method. Run the app.
void main() {
  runApp(const App());
}

///The main app widget.
class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      //A future builder to wait on the Firebase app initialization
      future: () async {
        final firebaseInit = Firebase.initializeApp();
        //If we're on the web
        if (kIsWeb) {
          //Set firebase authentication persistence to local so our login state persists across sessions
          await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
          //Enable firestore persistence so the app works offline.
          //Any change made offline are pushed to Firebase when reconnected.
          await FirebaseFirestore.instance.enablePersistence();
        } else {
          //If we're not on the web, we have a slightly different init flow
          FirebaseFirestore.instance.settings = const Settings(
              persistenceEnabled: true,
              cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
        }
        return firebaseInit;
      }(),
      builder: (context, snapshot) {
        //if(snapshot.hasError)
        if (snapshot.connectionState != ConnectionState.done) {
          return const MediaQuery(
              //While we're waiting on initialization, return a Cupertino App of just the Loading Page
              data: MediaQueryData(),
              child: CupertinoApp(title: 'SI413 ToDo', home: Loading()));
        }
        //When finished intializing firebase, return the TodoApp
        return const TodoApp();
      },
    );
  }
}
