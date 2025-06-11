import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password, String name) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Validate email format
      if (!email.contains('@') || !email.contains('.')) {
        throw 'Email không hợp lệ';
      }

      // Validate password strength
      if (password.length < 6) {
        throw 'Mật khẩu phải có ít nhất 6 ký tự';
      }

      UserCredential userCredential;
      try {
        print("AuthProvider: Đang gọi createUserWithEmailAndPassword...");
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print("AuthProvider: createUserWithEmailAndPassword thành công.");
      } catch (e, s) {
        // Thêm s để lấy StackTrace
        print(
          "AuthProvider LỖI khi gọi createUserWithEmailAndPassword: ${e.runtimeType} - $e",
        );
        print("AuthProvider StackTrace: $s"); // In StackTrace
        rethrow; // Ném lại lỗi để khối catch bên ngoài xử lý
      }

      final currentUser = userCredential.user;
      if (currentUser != null) {
        try {
          print("AuthProvider: Đang gọi updateDisplayName...");
          await currentUser.updateDisplayName(name);
          print("AuthProvider: updateDisplayName thành công.");
        } catch (e, s) {
          print(
            "AuthProvider LỖI khi gọi updateDisplayName: ${e.runtimeType} - $e",
          );
          print("AuthProvider StackTrace: $s");
          rethrow;
        }

        try {
          print("AuthProvider: Đang lưu dữ liệu vào Firestore...");
          await _firestore.collection('users').doc(currentUser.uid).set({
            'name': name,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          });
          print("AuthProvider: Lưu Firestore thành công.");
        } catch (e, s) {
          print("AuthProvider LỖI khi lưu Firestore: ${e.runtimeType} - $e");
          print("AuthProvider StackTrace: $s");
          rethrow;
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email này đã được sử dụng';
          break;
        // ... (các case khác của bạn) ...
        default:
          message = 'Đã xảy ra lỗi (Auth): ${e.message}';
      }
      print("AuthProvider: FirebaseAuthException - $message (code: ${e.code})");
      throw message;
    } catch (e, s) {
      // Bắt tất cả các lỗi khác, bao gồm TypeError
      // Đây là nơi quan trọng để xem lỗi gốc là gì
      print(
        "AuthProvider LỖI CHUNG trong signUp: ${e.runtimeType} - $e",
      ); // In kiểu và nội dung lỗi
      print(
        "AuthProvider StackTrace LỖI CHUNG: $s",
      ); // In StackTrace của lỗi này
      // Ném lại lỗi để UI có thể hiển thị, hoặc bạn có thể throw một thông báo tùy chỉnh hơn
      // Nếu 'e' chính là TypeError, thì e.toString() sẽ ra thông báo bạn thấy
      throw e; // Ném lại lỗi gốc để UI xử lý (nó sẽ gọi e.toString())
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Áp dụng cách try-catch chi tiết tương tự cho hàm signIn
  Future<void> signIn(String email, String password) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();
      print("AuthProvider: Đang gọi signInWithEmailAndPassword...");
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("AuthProvider: signInWithEmailAndPassword thành công.");
    } on FirebaseAuthException catch (e) {
      // ... (xử lý FirebaseAuthException của bạn) ...
      String message;
      // ... (các case của bạn)
      switch (e.code) {
        // ... các case lỗi của bạn
        default:
          message = 'Đã xảy ra lỗi (Auth): ${e.message}';
      }
      print("AuthProvider: FirebaseAuthException - $message (code: ${e.code})");
      throw message;
    } catch (e, s) {
      print("AuthProvider LỖI CHUNG trong signIn: ${e.runtimeType} - $e");
      print("AuthProvider StackTrace LỖI CHUNG: $s");
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      throw 'Đã xảy ra lỗi khi đăng xuất: $e';
    }
  }

  Future<void> signInWithGoogle() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw 'Đăng nhập bằng Google bị hủy';
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? currentUser = userCredential.user;

      if (currentUser != null) {
        // Check if user exists in Firestore
        final userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (!userDoc.exists) {
          // If user doesn't exist, create new user document
          await _firestore.collection('users').doc(currentUser.uid).set({
            'name': currentUser.displayName,
            'email': currentUser.email,
            'photoURL': currentUser.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = 'Email này đã được đăng ký bằng phương thức khác';
          break;
        case 'invalid-credential':
          message = 'Thông tin đăng nhập không hợp lệ';
          break;
        case 'operation-not-allowed':
          message = 'Đăng nhập bằng Google chưa được bật';
          break;
        case 'user-disabled':
          message = 'Tài khoản này đã bị vô hiệu hóa';
          break;
        case 'user-not-found':
          message = 'Không tìm thấy tài khoản';
          break;
        case 'wrong-password':
          message = 'Mật khẩu không đúng';
          break;
        case 'invalid-verification-code':
          message = 'Mã xác thực không hợp lệ';
          break;
        case 'invalid-verification-id':
          message = 'ID xác thực không hợp lệ';
          break;
        default:
          message = 'Đã xảy ra lỗi (Auth): ${e.message}';
      }
      print("AuthProvider: FirebaseAuthException - $message (code: ${e.code})");
      throw message;
    } catch (e, s) {
      print(
        "AuthProvider LỖI CHUNG trong signInWithGoogle: ${e.runtimeType} - $e",
      );
      print("AuthProvider StackTrace LỖI CHUNG: $s");
      throw e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
