import SwiftUI // Mengimpor framework SwiftUI untuk UI deklaratif
import Charts // Mengimpor Charts (tidak digunakan langsung di file ini, mungkin dipakai oleh view lain)
import Combine // Mengimpor Combine untuk reactive programming (tidak digunakan langsung di file ini)

fileprivate struct AccountsStore { // Struktur penyimpan akun ke UserDefaults (hanya terlihat di file ini)
  static let key = "accounts_list" // Kunci UserDefaults untuk daftar akun
  static func load() -> [String] { // Memuat daftar akun dari UserDefaults
    if let arr = UserDefaults.standard.array(forKey: key) as? [String] { return arr } // Kembalikan array jika ada
    return [] // Jika tidak ada, kembalikan array kosong
  }
  static func save(_ accounts: [String]) { // Menyimpan daftar akun ke UserDefaults
    UserDefaults.standard.set(accounts, forKey: key) // Simpan array string
  }
}

struct ContentView: View { // View utama aplikasi
  @State var selectedOption = "Pemasukan" // State untuk pilihan segmented control
  @EnvironmentObject var financeData: DataKeuangan // Data keuangan dibagikan melalui environment
  
  @StateObject var loginVM = LoginViewModel() // ViewModel login sebagai StateObject
  
  @AppStorage("isLoggedIn") var isLoggedIn: Bool = false // Status login tersimpan di AppStorage
  @AppStorage("uid") var uid: String = "" // UID user tersimpan di AppStorage
  @AppStorage("username") var username: String = "" // Username tersimpan di AppStorage
  @State private var showLogoutConfirmation = false // State untuk menampilkan alert konfirmasi logout
  @State private var showProfileSheet: Bool = false // State untuk menampilkan sheet profil
  
  var body: some View { // Body dari view
    NavigationStack { // Navigasi berbasis stack
      VStack(spacing: 20) { // Konten utama ditata vertikal dengan jarak 20
        
        // SALDO
        VStack(alignment: .leading) { // Kartu saldo saat ini
          Text("Saldo Saat Ini") // Judul saldo
            .font(.headline) // Gaya font headline
            .foregroundStyle(.secondary) // Warna sekunder
          
          Text(financeData.hitungSaldo(), format: .currency(code: "IDR")) // Menampilkan saldo dalam format Rupiah
            .font(.largeTitle) // Ukuran font besar
            .fontWeight(.bold) // Tebal
        }
        .padding() // Padding dalam kartu
        .frame(maxWidth: .infinity, alignment: .leading) // Lebar penuh, rata kiri
        .background(Color.blue.opacity(0.15)) // Latar biru transparan
        .cornerRadius(16) // Sudut membulat
        .padding(.horizontal) // Padding horizontal luar
        
        // PICKER
        Picker("Pilih tampilan", selection: $selectedOption) { // Segmented control untuk memilih tampilan
          Text("Pemasukan").tag("Pemasukan") // Opsi pemasukan
          Text("Pengeluaran").tag("Pengeluaran") // Opsi pengeluaran
        }
        .pickerStyle(.segmented) // Gaya segmented
        .padding(.horizontal) // Padding horizontal
        
        // VIEW
        if selectedOption == "Pemasukan" { // Kondisional berdasarkan pilihan
          PemasukanView() // Tampilkan view pemasukan
        } else { // Jika bukan pemasukan
          PengeluaranView() // Tampilkan view pengeluaran
        }
        
        Spacer() // Dorong konten ke atas
        
        StreakView() // Tampilan streak harian
          .padding() // Padding sekitar StreakView
      }
      .navigationTitle("Keuangan") // Judul navigasi
      .navigationBarTitleDisplayMode(.inline) // Tampilkan judul inline
      .toolbar { // Toolbar atas
        ToolbarItem(placement: .topBarLeading) { // Item kiri atas
          Button { // Tombol profil
            showProfileSheet = true // Tampilkan sheet profil
          } label: {
            HStack(spacing: 8) { // Ikon dan teks username
              Image(systemName: "person.crop.circle") // Ikon profil
              if !username.isEmpty { // Jika username ada
                Text(username) // Tampilkan username
              }
            }
          }
          .accessibilityLabel("Profil") // Label aksesibilitas
        }
      }
      .sheet(isPresented: $showProfileSheet) { // Sheet untuk profil
        NavigationStack { // Navigasi dalam sheet profil
          UserProfileSheet(username: $username, // Sheet profil dengan binding
                           showLogoutConfirmation: $showLogoutConfirmation,
                           isLoggedIn: $isLoggedIn,
                           uid: $uid,
                           financeData: financeData)
          .navigationTitle("Profil") // Judul sheet profil
          .navigationBarTitleDisplayMode(.inline) // Judul inline
          .toolbar { // Toolbar dalam sheet profil
            ToolbarItem(placement: .topBarLeading) { // Tombol edit kiri
              EditButton() // Tombol edit standar (untuk list)
            }
            ToolbarItem(placement: .topBarTrailing) { // Tombol selesai kanan
              Button("Selesai") { showProfileSheet = false } // Menutup sheet
            }
          }
        }
      }
   
      // ========= AMBIL DATA FIRESTORE =========
      .task { // Task async saat view tampil
        
        let finalUID = loginVM.uid.isEmpty ? uid : loginVM.uid // Tentukan UID akhir (dari VM atau AppStorage)
        
        if !finalUID.isEmpty { // Jika UID tersedia
          let data = try? await TransaksiService().ambilTransaksiUser(uid: finalUID) // Ambil transaksi user dari service (async)
          
          await MainActor.run { // Kembali ke main thread untuk update UI/state
            financeData.trx = data ?? [] // Set data transaksi ke environment object
          }
        }
      }
    }
  }
}

struct UserProfileSheet: View { // Sheet untuk profil pengguna
  @Binding var username: String // Binding ke username
  @Binding var showLogoutConfirmation: Bool // Binding untuk menampilkan konfirmasi logout
  @Binding var isLoggedIn: Bool // Binding status login
  @Binding var uid: String // Binding UID
  var financeData: DataKeuangan // Referensi data keuangan
  
  @State private var accounts: [String] = AccountsStore.load() // State daftar akun tersimpan
  @State private var newAccount: String = "" // State input akun baru
  @State private var addError: String? // Pesan error saat tambah akun
  
  var body: some View { // Body sheet profil
    VStack(spacing: 0) { // Susun vertikal tanpa spasi antar form
      UserProfileView(username: $username) // Subview profil (avatar + username)
      
      Form { // Form daftar akun tersimpan
        Section(header: Text("Akun Tersimpan"), footer: Text("Pilih untuk menjadikannya aktif.")) { // Section daftar akun
          if accounts.isEmpty { // Jika kosong
            Text("Belum ada akun.").foregroundStyle(.secondary) // Teks kosong
          } else { // Jika ada akun
            ForEach(accounts, id: \.self) { name in // Iterasi akun
              HStack { // Baris akun
                Text(name) // Nama akun
                Spacer() // Spacer ke kanan
                if name == username { Image(systemName: "checkmark").foregroundStyle(.green) } // Tanda centang jika aktif
              }
              .contentShape(Rectangle()) // Perbesar area sentuh
              .onTapGesture { // Tap untuk memilih akun
                username = name // Set username aktif
              }
            }
            .onDelete { indexSet in // Hapus akun dengan swipe
              accounts.remove(atOffsets: indexSet) // Hapus dari array
              AccountsStore.save(accounts) // Simpan perubahan
              if !accounts.contains(username) { username = "" } // Reset username jika akun aktif dihapus
            }
          }
        }
        Section(header: Text("Tambahkan Akun")) { // Section untuk menambah akun
          HStack { // Baris input akun baru
            Image(systemName: "person.badge.plus") // Ikon tambah orang
              .foregroundStyle(.blue) // Warna biru
            TextField("Username baru", text: $newAccount) // Input username baru
              .textInputAutocapitalization(.never) // Nonaktif kapital otomatis
              .autocorrectionDisabled() // Nonaktif autocorrect
          }
          if let addError { // Jika ada error input
            Text(addError) // Tampilkan pesan error
              .foregroundStyle(.red) // Warna merah
              .font(.caption) // Font kecil
          }
          Button { // Tombol tambah akun
            addAccount() // Panggil fungsi tambah
          } label: {
            Label("Tambah", systemImage: "plus.circle.fill") // Label tombol
          }
          .disabled(newAccount.trimmingCharacters(in: .whitespacesAndNewlines).count < 3) // Disable jika kurang 3 karakter
        }
      }
      
      Form { // Form aksi logout
        Section { // Section tunggal
          Button(role: .destructive) { // Tombol logout berbahaya
            showLogoutConfirmation = true // Tampilkan konfirmasi
          } label: {
            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right") // Label tombol logout
          }
        }
      }
    }
    .alert("Keluar dari akun?", isPresented: $showLogoutConfirmation) { // Alert konfirmasi logout
      Button("Iya", role: .destructive) { // Konfirmasi logout
        isLoggedIn = false // Reset status login
        uid = "" // Kosongkan UID
        username = "" // Kosongkan username
        financeData.trx = [] // Kosongkan transaksi
      }
      Button("Batal", role: .cancel) {} // Batalkan logout
    }
  }
  
  private func addAccount() { // Fungsi menambah akun baru
    let trimmed = newAccount.trimmingCharacters(in: .whitespacesAndNewlines) // Trim spasi
    guard trimmed.count >= 3 else { // Validasi minimal 3 karakter
      addError = "Minimal 3 karakter." // Set error
      return // Keluar fungsi
    }
    if accounts.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) { // Cek duplikasi (case-insensitive)
      addError = "Username sudah ada." // Set error duplikasi
      return // Keluar fungsi
    }
    accounts.append(trimmed) // Tambahkan ke array akun
    AccountsStore.save(accounts) // Simpan ke UserDefaults
    username = trimmed // Jadikan akun baru sebagai aktif
    newAccount = "" // Kosongkan input
    addError = nil // Hapus error
  }
}

struct UserProfileView: View { // View untuk avatar dan input username
  @Binding var username: String // Binding username
  @FocusState private var focused: Bool // Fokus untuk TextField
  
  private var initials: String { // Inisial untuk avatar
    let parts = username.split(separator: " ") // Pisahkan berdasarkan spasi
    if let first = parts.first { // Ambil bagian pertama jika ada
      return String(first.prefix(2)).uppercased() // Ambil 2 huruf pertama, kapital
    }
    return String(username.prefix(2)).uppercased() // Jika tidak ada spasi, ambil 2 huruf pertama
  }
  
  @State private var error: String? // Pesan error validasi username
  
  var body: some View { // Body UserProfileView
    Form { // Form berisi avatar dan input akun
      Section(header: Text("Avatar")) { // Bagian avatar
        HStack(spacing: 16) { // Baris avatar + deskripsi
          ZStack { // Tumpuk lingkaran dan teks inisial
            Circle() // Bentuk lingkaran
              .fill(Color.blue.opacity(0.2)) // Warna latar lingkaran
              .frame(width: 64, height: 64) // Ukuran lingkaran
            Text(initials.isEmpty ? "?" : initials) // Tampilkan inisial atau ?
              .font(.headline) // Gaya font
              .foregroundStyle(.blue) // Warna teks biru
          }
          Text("Avatar akan menampilkan inisial dari username Anda.") // Deskripsi avatar
            .font(.footnote) // Font kecil
            .foregroundStyle(.secondary) // Warna sekunder
        }
        .padding(.vertical, 4) // Padding vertikal kecil
      }
      Section(header: Text("Akun")) { // Bagian input akun
        HStack { // Baris ikon + text field
          Image(systemName: "person.fill") // Ikon orang
            .foregroundStyle(.blue) // Warna biru
          TextField("Masukkan username", text: $username) // Input username
            .textInputAutocapitalization(.never) // Nonaktif kapital otomatis
            .autocorrectionDisabled() // Nonaktif autocorrect
            .focused($focused) // Kelola fokus
            .onChange(of: username) { newValue in // Validasi saat nilai berubah
              validate(newValue) // Panggil validasi
            }
        }
        if let error { // Jika ada error
          Text(error) // Tampilkan pesan error
            .foregroundStyle(.red) // Warna merah
            .font(.caption) // Font kecil
        }
      }
    }
    .onAppear { // Saat view muncul
      focused = true // Fokuskan text field
      validate(username) // Validasi nilai awal
    }
  }
  
  private func validate(_ value: String) { // Fungsi validasi username
    if value.trimmingCharacters(in: .whitespacesAndNewlines).count < 3 { // Cek panjang minimal 3
      error = "Minimal 3 karakter." // Set error jika kurang
    } else {
      error = nil // Hapus error jika valid
    }
  }
}

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// ===============================================================
// MARK: - STREAK MANAGER (FIREBASE)
// ===============================================================
final class StreakManager {
    static let shared = StreakManager()

    private let db = Firestore.firestore()
    private var userID: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    private let calendar = Calendar.current

    private init() {}

    private var streakDoc: DocumentReference {
        db.collection("users")
            .document(userID)
            .collection("Streak")
            .document("Daily")
    }

    // ------------------------------------------------------------
    // MARK: LOAD STREAK DATA FROM FIREBASE
    // ------------------------------------------------------------
    func loadStreak(completion: @escaping (Int, Bool, Bool) -> Void) {
        streakDoc.getDocument { snapshot, error in
            if let data = snapshot?.data() {

                let streak = data["streak"] as? Int ?? 0
                let fireActive = data["fireActive"] as? Bool ?? false
                let lastCheckIn = (data["lastCheckIn"] as? Timestamp)?.dateValue()
                    ?? Date(timeIntervalSince1970: 0)

                let hasCheckedInToday = self.calendar.isDateInToday(lastCheckIn)

                completion(streak, fireActive, hasCheckedInToday)
                return
            }

            completion(0, false, false) // kalau belum ada dokumennya
        }
    }

    // ------------------------------------------------------------
    // MARK: CHECK-IN TODAY → FIREBASE
    // ------------------------------------------------------------
    func checkInToday(completion: @escaping (Int, Bool) -> Void) {

        streakDoc.getDocument { snapshot, error in
            let today = Date()
            var newStreak = 1
            var fireActive = false

            if let data = snapshot?.data() {
                let lastCheckIn = (data["lastCheckIn"] as? Timestamp)?.dateValue()
                let oldStreak = data["streak"] as? Int ?? 0

                if let last = lastCheckIn {
                    if self.calendar.isDateInToday(last) {
                        // Sudah check-in hari ini
                        completion(oldStreak, data["fireActive"] as? Bool ?? false)
                        return
                    } else if self.calendar.isDate(
                        last,
                        inSameDayAs: self.calendar.date(byAdding: .day, value: -1, to: today)!
                    ) {
                        // Berurutan → tambah streak
                        newStreak = oldStreak + 1
                    }
                }
            }

            // Api aktif jika 3 hari berturut-turut
            fireActive = newStreak >= 3

            // Simpan perubahan ke Firestore
            self.streakDoc.setData([
                "streak": newStreak,
                "fireActive": fireActive,
                "lastCheckIn": Timestamp(date: today)
            ], merge: true)

            completion(newStreak, fireActive)
        }
    }
}



// ===============================================================
// MARK: - STREAK VIEW (AUTO CHECK-IN + ANIMASI)
// ===============================================================
struct StreakView: View {

    @State private var streak: Int = 0
    @State private var fireActive: Bool = false
    @State private var hasCheckedInToday: Bool = false
    @State private var animateFlame: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack(spacing: 12) {

                Image(systemName: fireActive ? "flame.fill" : "flame")
                    .foregroundStyle(fireActive ? .orange : .gray)
                    .font(.system(size: 28))
                    .scaleEffect(animateFlame ? 1.15 : 1.0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.6),
                               value: animateFlame)

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
            loadStreakFromFirebase()
        }
    }

    // ------------------------------------------------------------
    // MARK: LOAD DATA FIREBASE
    // ------------------------------------------------------------
    private func loadStreakFromFirebase() {
        StreakManager.shared.loadStreak { streak, fireActive, checkedInToday in
            self.streak = streak
            self.fireActive = fireActive
            self.hasCheckedInToday = checkedInToday

            if !checkedInToday {
                autoCheckIn()
            }
        }
    }

    // ------------------------------------------------------------
    // MARK: AUTO CHECK-IN FIREBASE
    // ------------------------------------------------------------
    private func autoCheckIn() {
        StreakManager.shared.checkInToday { newStreak, newFireActive in
            self.streak = newStreak
            self.fireActive = newFireActive

            // animasi flame
            self.animateFlame = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.animateFlame = false
            }
        }
    }
}


#Preview { // Preview SwiftUI untuk Xcode canvas
  ContentView().environmentObject(DataKeuangan()) // Menyediakan environment object
}

