//
//  AuthModel.swift
//  KP-REVISI
//
//  Created by iCodeWave Community on 13/11/25.
//


import FirebaseAuth

struct AuthUserModel {
  let uid: String
  let email: String?
  
  init(user: User) {
    self.uid = user.uid
    self.email = user.email
  }
}

struct FSUserModel {
  let uid: String
  let email: String?

  
  init(uid: String, email: String?) {
    self.uid = uid
    self.email = email

  }
}
