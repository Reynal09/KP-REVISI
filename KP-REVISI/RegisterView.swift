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
  @Published var username = ""
  @Published var isRegistering = false
  @Published var isShowSucses = false
  @Published var isShowFailed = false
  func register() {
    Task {
      do {
        let user = try await AuthenticationManager.shared.createUser(email: email, password: password, username: username)
        
        print("Register UID:", user.uid)
        isShowSucses = true
        isRegistering = false
      } catch {
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
      ZStack {
        
        // BACKGROUND GRADIENT WARNA DINGIN
        LinearGradient(
          colors: [
            .blue.opacity(0.35),
            .purple.opacity(0.35),
            .teal.opacity(0.25)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        ScrollView {
          VStack(spacing: 32) {
            
            // 🔹 HEADER
            VStack(spacing: 8) {
              Text("Buat Akun Baru")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
              
              Text("Isi data berikut untuk melanjutkan.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.top, 30)
            
            
            // 🔹 FORM (GLASS EFFECT)
            VStack(spacing: 20) {
              
              // Username
              HStack(spacing: 12) {
                Image(systemName: "person.fill")
                  .foregroundStyle(.blue)
                TextField("Username", text: $vm.username)
                  .textInputAutocapitalization(.never)
              }
              .padding()
              .background(.ultraThinMaterial)
              .cornerRadius(14)
              
              // Email
              HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                  .foregroundStyle(.teal)
                TextField("Email", text: $vm.email)
                  .keyboardType(.emailAddress)
                  .textInputAutocapitalization(.never)
                  .autocorrectionDisabled()
              }
              .padding()
              .background(.ultraThinMaterial)
              .cornerRadius(14)
              
              // Password
              HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                  .foregroundStyle(.purple)
                SecureField("Password", text: $vm.password)
              }
              .padding()
              .background(.ultraThinMaterial)
              .cornerRadius(14)
              
            }
            .padding()
            .background(.white.opacity(0.12))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
            .padding(.horizontal)
            
            
            // 🔹 BUTTON REGISTER
            Button {
              vm.register()
              vm.isRegistering = true
            } label: {
              HStack {
                if vm.isRegistering {
                  ProgressView()
                }
                Text(vm.isRegistering ? "Mendaftarkan..." : "Daftar Akun")
                  .bold()
              }
              .frame(maxWidth: .infinity)
              .padding()
              .foregroundColor(.white)
              .background(
                LinearGradient(
                  colors: [.blue, .purple, .teal],
                  startPoint: .leading,
                  endPoint: .trailing
                )
              )
              .cornerRadius(14)
              .shadow(color: .blue.opacity(0.25), radius: 6, y: 4)
            }
            .disabled(vm.isRegistering)
            .padding(.horizontal)
            
            Spacer().frame(height: 40)
          }
          .padding()
        }
      }
      
      // 🔹 ALERT SUKSES
      .alert("Pendaftaran Berhasil", isPresented: $vm.isShowSucses) {
        Button("Lanjut") { dismiss() }
      } message: {
        Text("Akunmu berhasil dibuat!")
      }
      
      // 🔹 ALERT GAGAL
      .alert("Gagal", isPresented: $vm.isShowFailed) {
        Button("Tutup") { }
      } message: {
        Text("Terjadi kesalahan. Silakan coba lagi.")
      }
      
      .navigationTitle("Registrasi")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  RegisterView()
}

