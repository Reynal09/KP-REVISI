import SwiftUI

struct HomeView: View {
  var body: some View {
    NavigationStack {
      ZStack {
        // COOL BACKGROUND GRADIENT
        LinearGradient(
          colors: [
            Color.blue.opacity(0.30),
            Color.teal.opacity(0.25),
            Color.indigo.opacity(0.25)
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        ScrollView {
          VStack(spacing: 32) {
            
            // ICON / ILLUSTRATION
            Image(systemName: "chart.line.uptrend.xyaxis")
              .font(.system(size: 70))
              .foregroundStyle(.white.opacity(0.9))
              .padding(40)
              .background(.ultraThinMaterial)
              .clipShape(RoundedRectangle(cornerRadius: 40))
              .shadow(color: .black.opacity(0.25), radius: 10, y: 5)
              .padding(.top, 20)
            
            
            // HEADER CARD (GLASS, COOL COLORS)
            VStack(alignment: .leading, spacing: 10) {
              Text("Kelola Keuanganmu")
                .font(.title.bold())
                .foregroundStyle(.primary)
              
              Text("Catat, kontrol, dan raih tujuan finansialmu.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
            .padding(.horizontal, 4)
            
            
            // FORGOT PASSWORD
            HStack {
              Spacer()
              Text("Lupa Password?")
                .font(.footnote.bold())
                .foregroundStyle(.red.opacity(0.9))
            }
            
            
            // LOGIN BUTTON
            NavigationLink(destination: LoginView()) {
              HStack {
                Image(systemName: "arrow.right.circle.fill")
                Text("Login")
                  .fontWeight(.semibold)
              }
              .font(.headline)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 14)
              .foregroundStyle(.white)
              .background(
                LinearGradient(
                  colors: [
                    Color.blue.opacity(0.90),
                    Color.indigo.opacity(0.85)
                  ],
                  startPoint: .leading,
                  endPoint: .trailing
                )
              )
              .clipShape(RoundedRectangle(cornerRadius: 50))
              .shadow(color: Color.blue.opacity(0.35), radius: 6, y: 4)
            }
            
            
            // REGISTER BUTTON
            NavigationLink(destination: RegisterView()) {
              HStack {
                Image(systemName: "person.crop.circle.badge.plus")
                Text("Register")
                  .fontWeight(.semibold)
              }
              .font(.headline)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 14)
              .foregroundStyle(.white)
              .background(
                LinearGradient(
                  colors: [
                    Color.teal.opacity(0.85),
                    Color.blue.opacity(0.70)
                  ],
                  startPoint: .leading,
                  endPoint: .trailing
                )
              )
              .clipShape(RoundedRectangle(cornerRadius: 50))
              .shadow(color: Color.teal.opacity(0.35), radius: 6, y: 4)
            }
            
            Spacer().frame(height: 35)
          }
          .padding(.horizontal)
        }
      }
      .navigationTitle("Home")
    }
  }
}

#Preview {
  HomeView()
}
