import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:si413_project/ui/loading.dart';

import 'list_page.dart';
import 'login_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final userStream = FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Loading();
        if (snapshot.data == null) return const LoginPage();
        return ListPage(user: snapshot.data!);
      });
}
