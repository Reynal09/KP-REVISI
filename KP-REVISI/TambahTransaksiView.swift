import SwiftUI
import FirebaseFirestore

struct TambahTransaksiView: View {
  
  let transaksiService = TransaksiService()
  @AppStorage("uid") var uid: String = ""     // UID user yang login
  
  @State private var inputNominal: String = ""
  @State private var riwayat: [Transaksi] = []
  @State private var selectedKategori_Keluar: String = "Makanan"
  @State private var selectedKategori_Masuk: String = "Investasi"
  @State private var selectedDate: Date = Date()
  @State private var showCalendar: Bool = false
  
  struct KategoriMeta {
    let icon: String
    let color: Color?
  }
  
  var kategori_Keluar: [String: KategoriMeta] = [
    "Makanan": KategoriMeta(icon: "fork.knife", color: nil),
    "Medis": KategoriMeta(icon: "cross.case", color: nil),
    "Transaksi": KategoriMeta(icon: "dollarsign.circle", color: nil),
    "Hiburan": KategoriMeta(icon: "gamecontroller", color: nil),
    "Lainnya": KategoriMeta(icon: "plus.circle", color: Color.red.opacity(0.7))
  ]
  
  var kategori_Masuk: [String: KategoriMeta] = [
    "Investasi": KategoriMeta(icon: "chart.line.uptrend.xyaxis", color: nil),
    "Gaji": KategoriMeta(icon: "banknote", color: nil),
    "Bonus": KategoriMeta(icon: "gift", color: nil),
    "Uang Saku": KategoriMeta(icon: "wallet.pass", color: nil),
    "Lainnya": KategoriMeta(icon: "plus.circle", color: Color.green.opacity(0.7))
  ]
  
  private let accent = Color.black
  private let income = Color.green
  private let expense = Color.red
  
  private let headerGradient = LinearGradient(colors: [.black.opacity(0.9), .black.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
  
  @EnvironmentObject var financeData: DataKeuangan
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          
          // Header
          VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
              ZStack {
                Circle()
                  .fill(headerGradient)
                  .frame(width: 36, height: 36)
                Image(systemName: "wallet.pass")
                  .font(.subheadline.weight(.semibold))
                  .foregroundStyle(.white)
              }
              Text("Dompet")
                .font(.title.bold())
                .foregroundStyle(.primary)
            }
            Text("Catat pemasukan & pengeluaran")
              .font(.callout)
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical, 8)
          
          // Input Card
          VStack(spacing: 12) {
            
            // NOMINAL
            VStack(alignment: .leading, spacing: 6) {
              Text("Nominal")
                .font(.footnote)
                .foregroundStyle(.secondary)
              
              HStack(spacing: 8) {
                Image(systemName: "dollarsign")
                  .foregroundStyle(.secondary)
                TextField("Masukkan nominal", text: $inputNominal)
                  .keyboardType(.decimalPad)
              }
              Divider()
            }
            
            // KATEGORI
            VStack(spacing: 10) {
              HStack {
                Label("Keluar", systemImage: "arrow.up.circle.fill")
                  .foregroundStyle(expense)
                Spacer()
                Picker("", selection: $selectedKategori_Keluar) {
                  ForEach(kategori_Keluar.keys.sorted(), id: \.self) { kategori in
                    Text(kategori)
                  }
                }
                .tint(expense)
                .pickerStyle(.menu)
              }
              Divider()
              
              HStack {
                Label("Masuk", systemImage: "arrow.down.circle.fill")
                  .foregroundStyle(income)
                Spacer()
                Picker("", selection: $selectedKategori_Masuk) {
                  ForEach(kategori_Masuk.keys.sorted(), id: \.self) { kategori in
                    Text(kategori)
                  }
                }
                .tint(income)
                .pickerStyle(.menu)
              }
              Divider()
              
              // TANGGAL
              HStack {
                Image(systemName: "calendar")
                  .foregroundStyle(.secondary)
                Text(selectedDate, format: .dateTime.day().month(.abbreviated).year())
                  .foregroundStyle(.primary)
                Spacer()
                Button {
                  withAnimation(.spring(duration: 0.45)) {
                    showCalendar.toggle()
                  }
                } label: {
                  Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(showCalendar ? 180 : 0))
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
              }
            }
            
            if showCalendar {
              DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(accent)
                .transition(.opacity.combined(with: .scale))
                .onChange(of: selectedDate) { _ in
                  // TUTUP KALENDER OTOMATIS
                  withAnimation(.spring(duration: 0.35)) {
                    showCalendar = false
                  }
                }
            }
            
            // BUTTON PEMASUKAN & PENGELUARAN
            HStack(spacing: 10) {
              Button {
                simpanTransaksi(jenis: .masuk)
              } label: {
                HStack {
                  Image(systemName: "arrow.down")
                  Text("Pemasukan")
                }
                .frame(maxWidth: .infinity)
              }
              .buttonStyle(.borderedProminent)
              .tint(income)

              Button {
                simpanTransaksi(jenis: .keluar)
              } label: {
                HStack {
                  Image(systemName: "arrow.up")
                  Text("Pengeluaran")
                }
                .frame(maxWidth: .infinity)
              }
              .buttonStyle(.bordered)
              .tint(expense)
            }
            .opacity(inputNominal.isEmpty ? 0.6 : 1)
            .disabled(inputNominal.isEmpty)
          }
          .padding(16)
          .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .fill(Color(.secondarySystemBackground))
          )
          
          // MINI GAME / FUN SECTION
          VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
              Image(systemName: "gamecontroller.fill")
                .foregroundStyle(.purple)
              Text("Seru-seruan")
                .font(.headline)
                .foregroundStyle(.primary)
              Spacer()
            }
            .padding(.horizontal, 4)

            MiniGameView()
              .padding(.top, 4)
          }
          .padding(16)
          .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
              .fill(Color(.secondarySystemBackground))
          )
        }
        .padding()
        .padding(.horizontal)
      }
    }
    .navigationTitle("Dompet")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.bar, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarColorScheme(.light, for: .navigationBar)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Image(systemName: "sparkles")
          .foregroundStyle(.secondary)
      }
    }
  }
  
  // MARK: - FUNCTION SIMPAN TRANSAKSI
  private func simpanTransaksi(jenis: JenisTransaksi) {
    guard let nominal = Double(inputNominal) else { return }
    
    let transaksiBaru = Transaksi(
      nominal: nominal,
      jenis: jenis,
      kategori_Masuk: selectedKategori_Masuk,
      kategori_Keluar: selectedKategori_Keluar,
      tanggal: selectedDate
    )
    
    // Simpan ke lokal (EnvironmentObject)
    financeData.tambahTransaksi(transaksiBaru)
    
    // Simpan ke FIRESTORE per-UID
    Task {
      if uid.isEmpty {
        // UID kosong -> user belum login atau belum tersimpan di AppStorage
        print("Warning: UID kosong — pastikan user sudah login sebelum menyimpan transaksi.")
        return
      }
      
      do {
        try await transaksiService.tambahTransaksi(transaksiBaru, uid: uid) // <-- kirim uid di sini
      } catch {
        print("Gagal simpan transaksi ke Firestore:", error)
      }
    }
    
    inputNominal = ""
  }
}

// MARK: - Mini Game View
private struct MiniGameView: View {
  @State private var score: Int = 0
  @State private var timeLeft: Int = 10
  @State private var isPlaying: Bool = false
  @State private var targetOffset: CGSize = .zero
  @State private var showResult: Bool = false
  @State private var bestScore: Int = UserDefaults.standard.integer(forKey: "MiniGameBestScore")

  private let generator = UIImpactFeedbackGenerator(style: .light)

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Label("Skor: \(score)", systemImage: "star.fill").foregroundStyle(.yellow)
        Spacer()
        Label("Waktu: \(timeLeft)s", systemImage: "clock").foregroundStyle(.secondary)
      }
      .font(.subheadline)

      ZStack {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(Color(.tertiarySystemBackground))
          .frame(height: 160)

        if isPlaying {
          Button(action: hitTarget) {
            Image(systemName: "target")
              .font(.system(size: 28, weight: .bold))
              .foregroundStyle(.pink)
              .padding(18)
              .background(Circle().fill(Color(.systemBackground)))
              .shadow(radius: 4)
          }
          .offset(targetOffset)
          .animation(.spring(response: 0.35, dampingFraction: 0.8), value: targetOffset)
          .accessibilityLabel("Ketuk target untuk mendapat poin")
        } else {
          VStack(spacing: 8) {
            if showResult {
              Text("Waktu Habis!")
                .font(.headline)
              Text("Skor: \(score)  •  Rekor: \(bestScore)")
                .foregroundStyle(.secondary)
            } else {
              Text("Tap Target!")
                .font(.headline)
              Text("Ketuk target sebanyak mungkin dalam 10 detik.")
                .foregroundStyle(.secondary)
            }
            Button(action: startGame) {
              Label(showResult ? "Main Lagi" : "Mulai", systemImage: "play.fill")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
          }
          .padding()
        }
      }

      if bestScore > 0 {
        HStack {
          Image(systemName: "trophy.fill").foregroundStyle(.orange)
          Text("Rekor terbaik: \(bestScore)")
          Spacer()
          Button(role: .destructive) { resetBest() } label: {
            Label("Reset", systemImage: "arrow.counterclockwise")
          }
          .labelStyle(.iconOnly)
        }
        .font(.footnote)
        .transition(.opacity)
      }
    }
    .onAppear { generator.prepare() }
  }

  // MARK: - Actions
  private func startGame() {
    score = 0
    timeLeft = 10
    showResult = false
    isPlaying = true
    moveTarget(within: 140)

    generator.impactOccurred(intensity: 0.8)

    // Timer sederhana menggunakan DispatchQueue
    DispatchQueue.main.async {
      tick()
    }
  }

  private func tick() {
    guard isPlaying else { return }
    if timeLeft > 0 {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        timeLeft -= 1
        tick()
      }
    } else {
      endGame()
    }
  }

  private func endGame() {
    isPlaying = false
    showResult = true
    if score > bestScore {
      bestScore = score
      UserDefaults.standard.set(bestScore, forKey: "MiniGameBestScore")
    }
  }

  private func hitTarget() {
    guard isPlaying else { return }
    score += 1
    generator.impactOccurred(intensity: 0.6)
    moveTarget(within: 140)
  }

  private func moveTarget(within radius: CGFloat) {
    let dx = CGFloat.random(in: -radius...radius)
    let dy = CGFloat.random(in: -radius...radius)
    withAnimation {
      targetOffset = CGSize(width: dx, height: dy)
    }
  }

  private func resetBest() {
    bestScore = 0
    UserDefaults.standard.removeObject(forKey: "MiniGameBestScore")
  }
}

#Preview {
  TambahTransaksiView()
    .environmentObject(DataKeuangan())
}
