//
//  RegisterViewModel.swift
//  KP-REVISI
//
//  Created by iCodeWave Community on 13/11/25.
//


import SwiftUI
import Combine

class RegisterViewModel: ObservableObject {
  @Published var email = ""
  @Published var password = ""
  @Published var isRegistering = false
  @Published var isShowSucses = false
  @Published var isShowFailed = false
  func register() {
    Task { // async - await
      do { // try - throws
        let hasil = try await AuthenticationManager.shared.createUser(email: self.email, password: self.password)
        print("SUKSES BUAT AKUN!")
        isShowSucses = true
        isRegistering = false
      } catch {
        print("GAGAL BUAT AKUN:", error)
        isShowFailed = true
        isRegistering = false
      }
    }
  }
}

struct RegisterView: View {
  @Environment(\.dismiss) var dismiss
  @StateObject var vm = RegisterViewModel()
  var body: some View {
    NavigationStack {
      List {
        TextField("Email", text: $vm.email)
        SecureField("Password", text: $vm.password)
        Button {
          vm.register()
          vm.isRegistering = true
        } label: {
          HStack {
            if vm.isRegistering { // true
              ProgressView()
            }
            Text("Daftar Akun")
          }
        }
        .disabled(vm.isRegistering)
        
      }
      .alert("Sukses", isPresented: $vm.isShowSucses, actions: {
        Button("Yeayy!!!") {
          dismiss()}
      }, message: {
        Text("Akunmu berhasil dibuat")
      })
      
      .alert("Gagal", isPresented: $vm.isShowFailed, actions: {
        Button("YAHHH!!"){}
      }, message: {
        Text("Gagal kimak")
      })
      .navigationTitle("Registrasi Akun")
    }
  }
}

#Preview {
  RegisterView()
}

