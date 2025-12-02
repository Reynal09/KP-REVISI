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
  @AppStorage("uid") var uid: String = ""   // ← WAJIB! BIAR UID TERSEDIA
  func login() async {
    isLoading = true
    
    do {
      // pencet tombol → masuk ke proses login
      let hasil = try await AuthenticationManager.shared
        .signInUser(email: email, password: password)
      
      print("Login UID:", hasil.uid)
      
      // Update UI di MainActor
      await MainActor.run {
        self.uid = hasil.uid
        self.appStateLoggedIn = true
        self.isLoggedIn = true
        self.isShowSuccess = true
        self.isLoading = false
        self.isLoggedIn = false
      }
      
    } catch {
      // kalau login gagal
      await MainActor.run {
        self.isShowFailed = true
        self.isLoading = false
      }
      
      print("Error login:", error.localizedDescription)
    }
  }
  
}



struct LoginView: View {
  @StateObject var vm = LoginViewModel()
  @AppStorage("uid") var uid: String = ""
  
  var body: some View {
    NavigationStack {
      ZStack {
        
        // Background Calm Gradient (lebih dingin & maskulin)
        LinearGradient(
          colors: [
            Color.blue.opacity(0.35),
            Color.cyan.opacity(0.35),
            Color.green.opacity(0.25)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        ScrollView {
          VStack(spacing: 28) {
            
            // ICON / HEADER
            Image(systemName: "lock.shield.fill")
              .font(.system(size: 70))
              .foregroundStyle(.white.opacity(0.95))
              .padding(40)
              .background(.ultraThinMaterial)
              .clipShape(RoundedRectangle(cornerRadius: 35))
              .shadow(color: .black.opacity(0.25), radius: 10, y: 6)
              .padding(.top, 40)
            
            
            // --------------------------
            // MARK: FORM CARD (GLASS)
            // --------------------------
            VStack(spacing: 18) {
              
              Text("Masuk ke Akun")
                .font(.title2.bold())
                .foregroundStyle(.primary)
              
              Text("Silakan login untuk melanjutkan")
                .font(.subheadline)
                .foregroundStyle(.secondary)
              
              // Email Field
              HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                  .foregroundColor(.blue.opacity(0.8))
                TextField("Email", text: $vm.email)
                  .keyboardType(.emailAddress)
                  .textInputAutocapitalization(.never)
                  .autocorrectionDisabled(true)
                  .textContentType(.emailAddress)
              }
              .padding()
              .background(.white.opacity(0.25))
              .clipShape(RoundedRectangle(cornerRadius: 15))
              .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
              
              
              // Password Field
              HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                  .foregroundColor(.green.opacity(0.8))
                SecureField("Password", text: $vm.password)
                  .textContentType(.password)
              }
              .padding()
              .background(.white.opacity(0.25))
              .clipShape(RoundedRectangle(cornerRadius: 15))
              .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
              
              
              // Login Button
              Button {
                Task {
                  do {
                    try await vm.login()
                  } catch { }
                }
              } label: {
                HStack {
                  if vm.isLoading { ProgressView() }
                  Text(vm.isLoading ? "Sedang Masuk..." : "Login")
                    .bold()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(
                  LinearGradient(
                    colors: [
                      Color.blue.opacity(0.9),
                      Color.cyan.opacity(0.9)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                  )
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: .blue.opacity(0.35), radius: 7, y: 4)
              }
              .disabled(vm.isLoading)
              .padding(.top, 10)
              
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .shadow(color: .black.opacity(0.18), radius: 8, y: 4)
            .padding(.horizontal)
            
            Spacer().frame(height: 40)
          }
        }
      }
      // ALERT
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
