import 'package:firebase_auth/firebase_auth.dart';

class UserAuth {
  UserAuth();

  // register user with their email
  Future<String?> registerWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak');
        return 'weak';
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email');
        return 'email';
      }
    } catch (e) {
      print(e);
      return '';
    }
  }

  // sign in user with their email
  // return values:
  // 0: Signed in
  // 1: No user for email
  // 2: Wrong password
  // 3: other error
  Future<int> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        return 1;
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        return 2;
      }
    } catch (e) {
      print(e);
      return 3;
    }
    return 0;
  }

  // sign in with google

  // sign in with apple
}
