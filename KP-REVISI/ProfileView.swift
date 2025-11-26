import SwiftUI

struct ProfileView: View {
  @AppStorage("uid") private var uid: String = ""
  @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
  
  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        // Avatar
        ZStack {
          Circle()
            .fill(LinearGradient(colors: [.blue.opacity(0.9), .purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 90, height: 90)
          Image(systemName: "person.fill")
            .foregroundStyle(.white)
            .font(.system(size: 38, weight: .bold))
        }
        .padding(.top, 24)
        
        // Basic Info
        VStack(spacing: 8) {
          Text("Profil Saya")
            .font(.title2.bold())
          
          if !uid.isEmpty {
            Text("UID: \(uid)")
              .font(.footnote)
              .foregroundStyle(.secondary)
          } else {
            Text("Belum login")
              .font(.footnote)
              .foregroundStyle(.secondary)
          }
        }
        
        // Actions
        VStack(spacing: 12) {
          Button {
            // Placeholder for edit profile action
          } label: {
            Label("Edit Profil", systemImage: "pencil")
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.bordered)
          
          Button {
            isLoggedIn = false
          } label: {
            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
              .foregroundStyle(.red)
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.bordered)
        }
        .padding(.top, 8)
      }
      .padding()
    }
    .navigationTitle("Profil")
    .navigationBarTitleDisplayMode(.inline)
    
  }
}

#Preview {
  NavigationStack { ProfileView() }
}
