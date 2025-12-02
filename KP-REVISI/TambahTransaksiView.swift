import SwiftUI

struct TambahTransaksiView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var financeData: DataKeuangan
  @AppStorage("uid") private var uid: String = ""
  
  // State
  @State private var jenis: JenisTransaksi = .masuk
  @State private var nominal: Double = 0
  @State private var tanggal: Date = Date()
  @State private var kategoriMasuk: String = "Gaji"
  @State private var kategoriKeluar: String = "Makanan"
  @State private var isSaving = false
  @State private var showAlert = false
  @State private var alertTitle = ""
  @State private var alertMessage = ""
  
  // Kategori bawaan
  private let kategoriPemasukan = ["Gaji", "Bonus", "Hadiah", "Lainnya"]
  private let kategoriPengeluaran = ["Makanan", "Transport", "Hiburan", "Tagihan", "Belanja", "Lainnya"]
  
  var body: some View {
    NavigationStack {
      Form {
        // Jenis Transaksi (satu kontrol saja)
        Section {
          Picker("Jenis", selection: $jenis) {
            Text("Pemasukan").tag(JenisTransaksi.masuk)
            Text("Pengeluaran").tag(JenisTransaksi.keluar)
          }
          .pickerStyle(.segmented)
        }
        
        // Nominal & Tanggal
        Section(header: Text("Detail")) {
          HStack {
            Text("Nominal")
            Spacer()
            TextField("0", value: $nominal, format: .number)
              .multilineTextAlignment(.trailing)
              .keyboardType(.numberPad)
          }
          DatePicker("Tanggal", selection: $tanggal, displayedComponents: .date)
        }
        
        // Kategori (hanya tampil sesuai jenis)
        Section(header: Text("Kategori")) {
          if jenis == .masuk {
            Picker("Pilih Kategori", selection: $kategoriMasuk) {
              ForEach(kategoriPemasukan, id: \.self) { Text($0) }
            }
          } else if jenis == .keluar {
            Picker("Pilih Kategori", selection: $kategoriKeluar) {
              ForEach(kategoriPengeluaran, id: \.self) { Text($0) }
            }
          }
        }
        
        // Tombol simpan (kondisional label & warna)
        Section {
          if jenis == .masuk {
            Button {
              Task { await simpan() }
            } label: {
              HStack {
                if isSaving { ProgressView() }
                Text(isSaving ? "Menyimpan..." : "Simpan Pemasukan")
                  .bold()
              }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSaving || !inputValid)
          } else {
            Button {
              Task { await simpan() }
            } label: {
              HStack {
                if isSaving { ProgressView() }
                Text(isSaving ? "Menyimpan..." : "Simpan Pengeluaran")
                  .bold()
              }
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .disabled(isSaving || !inputValid)
          }
        }
      }
      .navigationTitle("Tambah Transaksi")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Tutup") { dismiss() } } }
      .alert(alertTitle, isPresented: $showAlert) {
        Button("OK") { if alertTitle == "Sukses" { dismiss() } }
      } message: { Text(alertMessage) }
    }
  }
  
  private var inputValid: Bool {
    nominal > 0 && (jenis == .masuk ? !kategoriMasuk.isEmpty : !kategoriKeluar.isEmpty)
  }
  
  @MainActor
  private func simpan() async {
    guard !uid.isEmpty else {
      alertTitle = "Gagal"
      alertMessage = "UID tidak ditemukan. Silakan login kembali."
      showAlert = true
      return
    }
    isSaving = true
    defer { isSaving = false }
    
    let transaksi = Transaksi(
      nominal: nominal,
      jenis: jenis,
      kategori_Masuk: jenis == .masuk ? kategoriMasuk : "",
      kategori_Keluar: jenis == .keluar ? kategoriKeluar : "",
      tanggal: tanggal
    )
    
    
    do {
      // Simpan ke Firestore
      try await TransaksiService().tambahTransaksi(transaksi, uid: uid)
      // Update state lokal agar saldo langsung berubah
      financeData.tambahTransaksi(transaksi)
      alertTitle = "Sukses"
      alertMessage = "Transaksi berhasil disimpan."
      showAlert = true
      // Reset input ringan
      nominal = 0
    } catch {
      alertTitle = "Gagal"
      alertMessage = "Tidak dapat menyimpan transaksi. Coba lagi."
      showAlert = true
    }
  }
}

#Preview {
  TambahTransaksiView().environmentObject(DataKeuangan())
}
