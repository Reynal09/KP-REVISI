import SwiftUI


struct TambahTransaksiView: View {
  @State private var inputNominal: String = ""
  @State private var riwayat: [Transaksii] = []
  @State private var selectedKategori_Keluar: String = "Makanan"
  @State private var selectedKategori_Masuk: String = "Investasi"
  @State private var selectedDate: Date = Date()
  @State private var showCalendar: Bool = false

  var kategori_Keluar = ["Makanan": "fork.knife", "Medis":"cross.case", "Transaksi":"dollarsign.circle", "Hiburan":"gamecontroller"]
  var kategori_Masuk = [
    "Investasi": "chart.line.uptrend.xyaxis",
    "Gaji": "banknote",
    "Bonus": "gift",
    "Uang Saku": "wallet.pass"
  ]

  private let accent = Color.teal
  private let income = Color.green
  private let expense = Color.red
  @EnvironmentObject var financeData: DataKeuangan

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {

          // Header card
          VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
              Image(systemName: "wallet.pass")
                .font(.title3)
                .foregroundStyle(accent)
              Text("Dompet")
                .font(.title.bold())
            }
            Text("Catat pemasukan & pengeluaran")
              .font(.footnote)
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.vertical, 8)

          // Input card
          VStack(spacing: 12) {
            // Nominal
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
              .padding(.vertical, 8)
              Divider()
            }

            // Kategori
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

              HStack {
                Image(systemName: "calendar").foregroundStyle(.secondary)
                Text(selectedDate, format: .dateTime.day().month(.abbreviated).year())
                  .foregroundStyle(.secondary)
                Spacer()
                Button {
                  withAnimation(.spring(duration: 0.50)) {
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
                .padding(.top, 4)
                .transition(.opacity.combined(with: .scale))
            }

            // Actions
            HStack(spacing: 10) {
              Button {
                if let nominal = Double(inputNominal) {
                  financeData.tambahTransaksi(Transaksii(nominal: nominal, jenis: .masuk, kategori_Masuk: selectedKategori_Masuk, kategori_Keluar: selectedKategori_Keluar, tanggal: selectedDate))
                  inputNominal = ""

                  
                }
              } label: {
                HStack { Image(systemName: "arrow.down"); Text("Pemasukan") }
                  .frame(maxWidth: .infinity)
              }
              .buttonStyle(.borderedProminent)
              .tint(income)

              Button {
                if let nominal = Double(inputNominal) {
                  financeData.tambahTransaksi(Transaksii(nominal: nominal, jenis: .keluar, kategori_Masuk: selectedKategori_Masuk, kategori_Keluar: selectedKategori_Keluar, tanggal: selectedDate))
                  inputNominal = ""

                }
              } label: {
                HStack { Image(systemName: "arrow.up"); Text("Pengeluaran") }
                  .frame(maxWidth: .infinity)
              }
              .buttonStyle(.bordered)
              .tint(expense)
            }
          }

        }
        .padding()
      }
    }
    .navigationTitle("Dompet")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.bar, for: .navigationBar)
    .toolbarBackground(.visible, for: .navigationBar)
    .toolbarColorScheme(.light, for: .navigationBar)
    
   
  }
}

#Preview {
  TambahTransaksiView()
    .environmentObject(DataKeuangan())
}
