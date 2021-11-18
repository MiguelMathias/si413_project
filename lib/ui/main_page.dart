import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:si413_project/ui/loading.dart';

import 'lists_page.dart';
import 'login_page.dart';

///The main page widget.
class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ///A stream listening to Firebase authentication state changes
  final userStream = FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
      //Respond to changes in authentication state
      stream: userStream,
      builder: (context, snapshot) {
        //If there's an error in auth state, return a loading page
        if (snapshot.hasError) return const Loading();
        //If there's no data in the auth state, return a login page
        if (!snapshot.hasData) return const LoginPage();
        //Otherwise, return the ListsPage for the current user
        return ListsPage(user: snapshot.data!);
      });
}
