//
//  AuthModel.swift
//  KP-REVISI
//
//  Created by iCodeWave Community on 13/11/25.
//


import FirebaseAuth

struct AuthModel {
  let uid: String
  let email: String?
  
  init(user: User) {
    self.uid = user.uid
    self.email = user.email
  }
}
