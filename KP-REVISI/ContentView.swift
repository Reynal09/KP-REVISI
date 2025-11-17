import SwiftUI
import Charts
import Combine

// ==============================
// MARK: - CONTENT VIEW
// ==============================
struct ContentView: View {
  @State var selectedOption = "Pemasukan"
  @EnvironmentObject var financeData: DataKeuangan

  @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
  @State private var showLogoutConfirmation = false
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 20) {
        VStack(alignment: .leading) {
          Text("Saldo Saat Ini")
            .font(.headline)
            .foregroundStyle(.secondary)
          Text(financeData.hitungSaldo(), format: .currency(code: "IDR"))
            .font(.largeTitle)
            .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.15))
        .cornerRadius(16)
        .padding(.horizontal)
        
        Picker("Pilih tampilan", selection: $selectedOption) {
          Text("Pemasukan").tag("Pemasukan")
          Text("Pengeluaran").tag("Pengeluaran")
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        
        if selectedOption == "Pemasukan" {
          PemasukanView()
        } else {
          PengeluaranView()
        }
        
        Spacer()
        
        StreakView()
          .padding()
      }
      .navigationTitle("Keuangan")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Logout") {
            showLogoutConfirmation = true
          }
        }
      }
      
      .alert("Keluar dari akun?", isPresented: $showLogoutConfirmation) {
        Button("Iya", role: .destructive) {
          isLoggedIn = false
        }
        Button("Batal", role: .cancel) {}
      }
    }
  }
}

/////////////////////////////////////////////////////////////
// ======================= STREAK VIEW =====================
/////////////////////////////////////////////////////////////

struct StreakView: View {
  @State private var streak: Int = StreakManager.shared.currentStreak()
  @State private var fireActive: Bool = StreakManager.shared.isFireActive()
  @State private var hasCheckedInToday: Bool = StreakManager.shared.hasCheckedInToday()
  @State private var animateFlame: Bool = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      
      HStack(spacing: 12) {
        Image(systemName: fireActive ? "flame.fill" : "flame")
          .foregroundStyle(fireActive ? .orange : .gray)
          .font(.system(size: 28))
          .scaleEffect(animateFlame ? 1.15 : 1.0)
          .animation(.spring(response: 0.35, dampingFraction: 0.6), value: animateFlame)
        
        VStack(alignment: .leading) {
          Text("🔥 \(streak)")
            .font(.headline)
          Text("Streak Harian")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        Spacer()
      }
      .padding()
      .background(.ultraThinMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    .onAppear {
      autoCheckIn()
    }
  }
  
  private func autoCheckIn() {
    if !StreakManager.shared.hasCheckedInToday() {
      let result = StreakManager.shared.checkInToday()
      self.streak = result.newStreak
      self.fireActive = StreakManager.shared.isFireActive()
      
      self.animateFlame = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
        self.animateFlame = false
      }
    }
  }
}

/////////////////////////////////////////////////////////////
// ======================= STREAK MANAGER ==================
/////////////////////////////////////////////////////////////

final class StreakManager {
  static let shared = StreakManager()
  
  private let lastCheckInKey = "streak_last_checkin_date"
  private let streakCountKey = "streak_count"
  private let fireActiveKey = "fire_is_active"
  
  private let calendar = Calendar.current
  private let defaults = UserDefaults.standard
  
  private init() {}
  
  func hasCheckedInToday() -> Bool {
    guard let last = defaults.object(forKey: lastCheckInKey) as? Date else { return false }
    return calendar.isDateInToday(last)
  }
  
  func currentStreak() -> Int {
    let count = defaults.integer(forKey: streakCountKey)
    
    if let last = defaults.object(forKey: lastCheckInKey) as? Date,
       !calendar.isDateInToday(last) {
      
      if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()),
         !calendar.isDate(last, inSameDayAs: yesterday) {
        return 0
      }
    }
    return count
  }
  
  func isFireActive() -> Bool {
    return defaults.bool(forKey: fireActiveKey)
  }
  
  @discardableResult
  func checkInToday() -> (newStreak: Int, date: Date) {
    
    let today = Date()
    var newStreak = 1
    
    if let last = defaults.object(forKey: lastCheckInKey) as? Date {
      
      if calendar.isDateInToday(last) {
        newStreak = defaults.integer(forKey: streakCountKey)
        
      } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                calendar.isDate(last, inSameDayAs: yesterday) {
        
        newStreak = defaults.integer(forKey: streakCountKey) + 1
        
      } else {
        newStreak = 1
        defaults.set(false, forKey: fireActiveKey)
      }
    }
    
    defaults.set(today, forKey: lastCheckInKey)
    defaults.set(newStreak, forKey: streakCountKey)
    
    if newStreak >= 3 {
      defaults.set(true, forKey: fireActiveKey)
    }
    
    return (newStreak, today)
  }
}

#Preview {
  ContentView().environmentObject(DataKeuangan())
}
