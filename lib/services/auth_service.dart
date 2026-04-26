import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign In
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 10));

      // Fetch user role/data from Firestore
      if (credential.user != null) {
        if (!credential.user!.emailVerified) {
          await _auth.signOut();
          throw Exception('email-not-verified');
        }

          DocumentSnapshot doc = await _firestore
              .collection('users')
              .doc(credential.user!.uid)
              .get()
              .timeout(const Duration(seconds: 10));

        if (doc.exists) {
          return UserModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during sign in');
    }
  }

  // Google Sign In
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User canceled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential).timeout(const Duration(seconds: 15));

      if (userCredential.user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get()
            .timeout(const Duration(seconds: 10));

        if (!doc.exists) {
          UserModel newUser = UserModel(
            uid: userCredential.user!.uid,
            email: googleUser.email,
            name: googleUser.displayName ?? 'Pengguna Google',
            role: 'buyer',
          );
          await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap()).timeout(const Duration(seconds: 10));
          return newUser;
        } else {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during Google sign in');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Register
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 10));

      if (credential.user != null) {
        UserModel newUser = UserModel(
          uid: credential.user!.uid,
          email: email,
          name: name,
          role: role,
        );

        await _firestore
            .collection('users')
            .doc(newUser.uid)
            .set(newUser.toMap())
            .timeout(const Duration(seconds: 10));

        // Send email verification
        await credential.user!.sendEmailVerification().timeout(const Duration(seconds: 10));

        // Immediately sign out to force them to verify before they can actually use the app
        await _auth.signOut();

        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during registration');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  // Resend Verification Email
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Reset Password Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email).timeout(const Duration(seconds: 10));
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to send password reset email');
    }
  }

  // Get current user role from Firestore
  Future<UserModel?> getCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get().timeout(const Duration(seconds: 10));
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    }
    return null;
  }
}
