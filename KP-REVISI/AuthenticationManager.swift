//
//  AuthenticationManager.swift
//  KP-REVISI
//
//  Created by iCodeWave Community on 13/11/25.
//


import Foundation
import FirebaseAuth

class AuthenticationManager {
  private init() {}
  static let shared = AuthenticationManager() // Singleton
  
  func createUser(email: String, password: String) async throws -> AuthModel  {
    let createResult = try await Auth.auth().createUser(withEmail: email, password: password)
    return AuthModel(user: createResult.user)
  }
}
