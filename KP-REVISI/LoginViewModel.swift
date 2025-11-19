//
//  LoginViewModel.swift
//  KP-REVISI
//

import SwiftUI
import FirebaseAuth
import Combine

class LoginViewModel: ObservableObject {
  
  @Published var email = ""
  @Published var password = ""
  @Published var isLoading = false
  @Published var isShowSuccess = false
  @Published var isShowFailed = false
  @Published var isLoggedIn = false
  @AppStorage("isLoggedIn") var appStateLoggedIn: Bool = false
  
  func login() async throws {
      let hasil = try await AuthenticationManager.shared.signInUser(email: email, password: password)
      isLoading = true
      print("Login UID:", hasil.uid)

      await MainActor.run {
          self.appStateLoggedIn = true
          self.isLoggedIn = true
          self.isShowSuccess = true
      }
  }
}


struct LoginView: View {
  @StateObject var vm = LoginViewModel()
  var body: some View {
    NavigationStack {
      VStack(spacing: 20) {
        
        Text("Login Akun")
          .font(.largeTitle)
          .bold()
        
        TextField("Email", text: $vm.email)
          .textFieldStyle(.roundedBorder)
          .keyboardType(.emailAddress)
          .autocorrectionDisabled(true)
          .textInputAutocapitalization(.never)
          .textContentType(.emailAddress)
        
        SecureField("Password", text: $vm.password)
          .textFieldStyle(.roundedBorder)
          .textContentType(.password)
        
        Button {
          Task {
            do {
              try await vm.login()
            } catch {
              
            }
          }
        } label: {
          HStack {
            if vm.isLoading {
              ProgressView()
            }
            Text(vm.isLoading ? "Sedang Masuk..." : "Login")
              .bold()
          }
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(10)
        }
        .disabled(vm.isLoading)
        
        Spacer()
      }
      .padding()
      
      // ALERT GAGAL
      .alert("Login Gagal", isPresented: $vm.isShowFailed) {
        Button("Tutup", role: .cancel) {}
      } message: {
        Text("Email atau password salah.")
      }
      
      
      
    }
  }
}

#Preview {
  LoginView()
}
