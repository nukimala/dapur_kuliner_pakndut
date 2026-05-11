import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Fungsi untuk Login menggunakan Email & Password bawaan Firebase
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Mencoba login ke Firebase Authentication (sistem akun Google)
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 10));

      // 2. Jika berhasil login, kita cek datanya
      if (credential.user != null) {
        // 3. Wajibkan pengguna memverifikasi email (klik link di email)
        if (!credential.user!.emailVerified) {
          await _auth.signOut();
          throw Exception('email-not-verified');
        }

        // 4. Mengambil data lengkap profil pengguna dari Firestore (termasuk Role/Jabatan)
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

  // Fungsi untuk Login menggunakan akun Google (SSO)
  Future<UserModel?> signInWithGoogle() async {
    try {
      // 1. Memunculkan pop-up pilihan akun Google di HP
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // Jika dibatalkan oleh user

      // 2. Mendapatkan token otentikasi dari Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Login ke Firebase menggunakan token Google tersebut
      UserCredential userCredential = await _auth.signInWithCredential(credential).timeout(const Duration(seconds: 15));

      if (userCredential.user != null) {
        // 4. Cek apakah user Google ini sudah pernah daftar sebelumnya di Firestore
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get()
            .timeout(const Duration(seconds: 10));

        if (!doc.exists) {
          // 5a. JIKA BELUM PERNAH DAFTAR: Buat akun baru di Firestore dengan role default 'buyer'
          UserModel newUser = UserModel(
            uid: userCredential.user!.uid,
            email: googleUser.email,
            name: googleUser.displayName ?? 'Pengguna Google',
            role: 'buyer',
          );
          await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap()).timeout(const Duration(seconds: 10));
          return newUser;
        } else {
          // 5b. JIKA SUDAH PERNAH DAFTAR: Tarik datanya dari Firestore
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

  // Fungsi untuk Mendaftar (Register) Akun Baru
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // 1. Buat akun baru di Firebase Authentication
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 10));

      if (credential.user != null) {
        // 2. Siapkan data profil pengguna baru (termasuk Role-nya)
        UserModel newUser = UserModel(
          uid: credential.user!.uid,
          email: email,
          name: name,
          role: role,
        );

        // 3. Simpan data profil tersebut ke tabel 'users' di Firestore
        await _firestore
            .collection('users')
            .doc(newUser.uid)
            .set(newUser.toMap())
            .timeout(const Duration(seconds: 10));

        // 4. Kirim email verifikasi ke email yang didaftarkan
        await credential.user!.sendEmailVerification().timeout(const Duration(seconds: 10));

        // 5. Langsung paksa Log-Out agar pengguna memverifikasi emailnya sebelum bisa memakai aplikasi
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
