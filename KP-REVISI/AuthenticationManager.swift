import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthenticationManager {
  private init() {}
  static let shared = AuthenticationManager() // Singleton
  
  // REGISTER USER BARU
  func createUser(email: String, password: String) async throws -> FSUserModel {
    
    // Buat akun di Firebase Auth
    let result = try await Auth.auth().createUser(withEmail: email, password: password)
    let authUser = AuthUserModel(user: result.user)
    
    // Simpan user ke Firestore
    let data: [String: Any] = [
      "id": authUser.uid,
      "email": authUser.email ?? ""
    ]
    
    try await Firestore.firestore()
      .collection("user")
      .document(authUser.uid)
      .setData(data, merge: false)
    
    // RETURN KE LOGIN VIEWMODEL
    return FSUserModel(uid: authUser.uid, email: authUser.email ?? "")
  }
  
  // LOGIN USER
  func signInUser(email: String, password: String) async throws -> FSUserModel {
    
    let signInResult = try await Auth.auth().signIn(withEmail: email, password: password)
    let authUser = AuthUserModel(user: signInResult.user)
    
    let snapshot = try await Firestore.firestore()
      .collection("user")
      .document(authUser.uid)
      .getDocument()
    
    guard let data = snapshot.data() else {
      return FSUserModel(uid: "", email: "")
    }
    
    let id = data["id"] as? String ?? ""
    let email = data["email"] as? String ?? ""
    
    return FSUserModel(uid: id, email: email)
  }
}
