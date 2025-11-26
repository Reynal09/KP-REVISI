import SwiftUI
import Charts
import Combine

fileprivate struct AccountsStore {
  static let key = "accounts_list"
  static func load() -> [String] {
    if let arr = UserDefaults.standard.array(forKey: key) as? [String] { return arr }
    return []
  }
  static func save(_ accounts: [String]) {
    UserDefaults.standard.set(accounts, forKey: key)
  }
}

struct ContentView: View {
  @State var selectedOption = "Pemasukan"
  @EnvironmentObject var financeData: DataKeuangan
  
  @StateObject var loginVM = LoginViewModel()
  
  @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
  @AppStorage("uid") var uid: String = ""
  @AppStorage("username") var username: String = ""
  @State private var showLogoutConfirmation = false
  @State private var showProfileSheet: Bool = false
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 20) {
        
        // SALDO
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
        
        // PICKER
        Picker("Pilih tampilan", selection: $selectedOption) {
          Text("Pemasukan").tag("Pemasukan")
          Text("Pengeluaran").tag("Pengeluaran")
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        
        // VIEW
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
        ToolbarItem(placement: .topBarLeading) {
          Button {
            showProfileSheet = true
          } label: {
            HStack(spacing: 8) {
              Image(systemName: "person.crop.circle")
              if !username.isEmpty {
                Text(username)
              }
            }
          }
          .accessibilityLabel("Profil")
        }
      }
      .sheet(isPresented: $showProfileSheet) {
        NavigationStack {
          UserProfileSheet(username: $username,
                           showLogoutConfirmation: $showLogoutConfirmation,
                           isLoggedIn: $isLoggedIn,
                           uid: $uid,
                           financeData: financeData)
          .navigationTitle("Profil")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .topBarLeading) {
              EditButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
              Button("Selesai") { showProfileSheet = false }
            }
          }
        }
      }
      // ========= AMBIL DATA FIRESTORE =========
      .task {
        
        let finalUID = loginVM.uid.isEmpty ? uid : loginVM.uid
        
        if !finalUID.isEmpty {
          let data = try? await TransaksiService().ambilTransaksiUser(uid: finalUID)
          
          await MainActor.run {
            financeData.trx = data ?? []
          }
        }
      }
    }
  }
}

struct UserProfileSheet: View {
  @Binding var username: String
  @Binding var showLogoutConfirmation: Bool
  @Binding var isLoggedIn: Bool
  @Binding var uid: String
  var financeData: DataKeuangan
  
  @State private var accounts: [String] = AccountsStore.load()
  @State private var newAccount: String = ""
  @State private var addError: String?
  
  var body: some View {
    VStack(spacing: 0) {
      UserProfileView(username: $username)
      
      Form {
        Section(header: Text("Akun Tersimpan"), footer: Text("Pilih untuk menjadikannya aktif.")) {
          if accounts.isEmpty {
            Text("Belum ada akun.").foregroundStyle(.secondary)
          } else {
            ForEach(accounts, id: \.self) { name in
              HStack {
                Text(name)
                Spacer()
                if name == username { Image(systemName: "checkmark").foregroundStyle(.green) }
              }
              .contentShape(Rectangle())
              .onTapGesture {
                username = name
              }
            }
            .onDelete { indexSet in
              accounts.remove(atOffsets: indexSet)
              AccountsStore.save(accounts)
              if !accounts.contains(username) { username = "" }
            }
          }
        }
        Section(header: Text("Tambahkan Akun")) {
          HStack {
            Image(systemName: "person.badge.plus")
              .foregroundStyle(.blue)
            TextField("Username baru", text: $newAccount)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
          }
          if let addError {
            Text(addError)
              .foregroundStyle(.red)
              .font(.caption)
          }
          Button {
            addAccount()
          } label: {
            Label("Tambah", systemImage: "plus.circle.fill")
          }
          .disabled(newAccount.trimmingCharacters(in: .whitespacesAndNewlines).count < 3)
        }
      }
      
      Form {
        Section {
          Button(role: .destructive) {
            showLogoutConfirmation = true
          } label: {
            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
          }
        }
      }
    }
    .alert("Keluar dari akun?", isPresented: $showLogoutConfirmation) {
      Button("Iya", role: .destructive) {
        isLoggedIn = false
        uid = ""
        username = ""
        financeData.trx = []
      }
      Button("Batal", role: .cancel) {}
    }
  }
  
  private func addAccount() {
    let trimmed = newAccount.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.count >= 3 else {
      addError = "Minimal 3 karakter."
      return
    }
    if accounts.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
      addError = "Username sudah ada."
      return
    }
    accounts.append(trimmed)
    AccountsStore.save(accounts)
    username = trimmed
    newAccount = ""
    addError = nil
  }
}

struct UserProfileView: View {
  @Binding var username: String
  @FocusState private var focused: Bool
  
  private var initials: String {
    let parts = username.split(separator: " ")
    if let first = parts.first {
      return String(first.prefix(2)).uppercased()
    }
    return String(username.prefix(2)).uppercased()
  }
  
  @State private var error: String?
  
  var body: some View {
    Form {
      Section(header: Text("Avatar")) {
        HStack(spacing: 16) {
          ZStack {
            Circle()
              .fill(Color.blue.opacity(0.2))
              .frame(width: 64, height: 64)
            Text(initials.isEmpty ? "?" : initials)
              .font(.headline)
              .foregroundStyle(.blue)
          }
          Text("Avatar akan menampilkan inisial dari username Anda.")
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
      }
      Section(header: Text("Akun")) {
        HStack {
          Image(systemName: "person.fill")
            .foregroundStyle(.blue)
          Text(username)
        }
        if let error {
          Text(error)
            .foregroundStyle(.red)
            .font(.caption)
        }
      }
    }
    .onAppear {
      focused = true
      validate(username)
    }
  }
  
  private func validate(_ value: String) {
    if value.trimmingCharacters(in: .whitespacesAndNewlines).count < 3 {
      error = "Minimal 3 karakter."
    } else {
      error = nil
    }
  }
}

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
  
  // MARK: - AUTO CHECK-IN
  private func autoCheckIn() {
    if !StreakManager.shared.hasCheckedInToday() {
      let result = StreakManager.shared.checkInToday()
      
      self.streak = result.newStreak
      self.fireActive = StreakManager.shared.isFireActive()
      
      // Animasi flame
      self.animateFlame = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
        self.animateFlame = false
      }
    }
  }
}

final class StreakManager {
  static let shared = StreakManager()
  
  private let lastCheckInKey = "streak_last_checkin_date"
  private let streakCountKey = "streak_count"
  private let fireActiveKey = "fire_is_active"
  
  private let calendar = Calendar.current
  private let defaults = UserDefaults.standard
  
  private init() {}
  
  // Cek apakah user sudah check-in hari ini
  func hasCheckedInToday() -> Bool {
    guard let last = defaults.object(forKey: lastCheckInKey) as? Date else { return false }
    return calendar.isDateInToday(last)
  }
  
  // Ambil streak saat ini, termasuk reset otomatis jika lewat sehari
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
  
  // Status flame aktif (>=3 hari streak)
  func isFireActive() -> Bool {
    return defaults.bool(forKey: fireActiveKey)
  }
  
  // MARK: - CHECK-IN FUNCTION
  @discardableResult
  func checkInToday() -> (newStreak: Int, date: Date) {
    
    let today = Date()
    var newStreak = 1
    
    if let last = defaults.object(forKey: lastCheckInKey) as? Date {
      
      if calendar.isDateInToday(last) {
        // Sudah check-in hari ini
        newStreak = defaults.integer(forKey: streakCountKey)
        
      } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                calendar.isDate(last, inSameDayAs: yesterday) {
        
        // Check-in berurutan → tambah streak
        newStreak = defaults.integer(forKey: streakCountKey) + 1
        
      } else {
        // Streak putus → reset
        newStreak = 1
        defaults.set(false, forKey: fireActiveKey)
      }
    }
    
    // Simpan perubahan
    defaults.set(today, forKey: lastCheckInKey)
    defaults.set(newStreak, forKey: streakCountKey)
    
    // Aktifkan api jika streak >= 3
    if newStreak >= 3 {
      defaults.set(true, forKey: fireActiveKey)
    }
    
    return (newStreak, today)
  }
}

#Preview {
  ContentView().environmentObject(DataKeuangan())
}
