import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

///A simple Login Page
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  ///A method to signInWithGoogle. From: https://firebase.flutter.dev/docs/auth/social
  Future<UserCredential> signInWithGoogle() async {
    //if we're on web, we sign in with a popup
    if (kIsWeb) {
      // Create a new provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithPopup(googleProvider);
    }
    //If we're not on the web, use a different auth flow
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
          //Simple a Cupertino Page with a centered button, which when clicked on start the auth flow for loggin in with Google
          child: Center(
        child: CupertinoButton.filled(
            onPressed: () => signInWithGoogle(),
            child: const Text('Log In With Google')),
      ));
}
