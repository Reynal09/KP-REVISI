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
    
    func login() {
        isLoading = true
        
        Task {
            do {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                print("LOGIN SUKSES → UID:", result.user.uid)

                await MainActor.run {
                    self.isShowSuccess = true
                    self.isLoggedIn = true
                    self.appStateLoggedIn = true   // ⬅️ ini yg bikin TabBar muncul
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isShowFailed = true
                    self.isLoading = false
                }
            }
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
                    vm.login()
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
            
            // 🚀 AUTO NAVIGATE KE HALAMAN SETELAH LOGIN
            .navigationDestination(isPresented: $vm.isLoggedIn) {
                ContentView()   // ← Ganti ke NewsView atau HomeView sesuai kebutuhanmu
            }
        }
    }
}

#Preview {
    LoginView()
}
