import SwiftUI
import Charts

struct PengeluaranView: View {
  @EnvironmentObject var financeData: DataKeuangan
  @State private var sortOrder: SortOrder = .terbaru
  
  enum SortOrder: String, CaseIterable {
    case terbaru = "Terbaru"
    case terdahulu = "Terdahulu"
  }
  
  private let kategori_Keluar: [String: (icon: String, color: Color)] = [
    // Merah tua
    "Makanan": ("fork.knife", Color(red: 0.60, green: 0.05, blue: 0.05)),
    // Merah terang/cerah
    "Transport": ("car", Color(red: 1.00, green: 0.30, blue: 0.30)),
    // Merah muda/rose
    "Hiburan": ("gamecontroller", Color(red: 1.00, green: 0.60, blue: 0.70)),
    // Merah keungu-an (maroon)
    "Tagihan": ("doc.text", Color(red: 0.55, green: 0.00, blue: 0.20)),
    // Merah oranye
    "Belanja": ("bag", Color(red: 1.00, green: 0.45, blue: 0.20)),
    // Merah lembut
    "Lainnya": ("minus.circle", Color(red: 0.90, green: 0.40, blue: 0.40))
  ]
  
  private struct PieSlice: Identifiable,Equatable {
    let id = UUID()
    let category: String
    let amount: Double
    let color: Color
    let systemImage: String
  }
  
  private var pieData: [PieSlice] {
    let grouped = Dictionary(grouping: financeData.trx.filter { $0.jenis == .keluar }) { $0.kategori_Keluar }
    return grouped.map { key, values in
      let total = values.reduce(0) { $0 + $1.nominal }
      let info = kategori_Keluar[key] ?? ("questionmark", .gray)
      return PieSlice(category: key, amount: total, color: info.color, systemImage: info.icon)
    }.sorted { $0.amount > $1.amount }
  }
  
  private var sortedTransactions: [Transaksi] {
    let filtered = financeData.trx.filter { $0.jenis == .keluar }
    return sortOrder == .terbaru
    ? filtered.sorted(by: { $0.tanggal > $1.tanggal })
    : filtered.sorted(by: { $0.tanggal < $1.tanggal })
  }
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        
        // ✅ PIE CHART
        VStack(alignment: .leading, spacing: 12) {
          Text("Distribusi Pengeluaran")
            .font(.headline)
          if pieData.isEmpty {
            Text("Belum ada data")
              .font(.caption)
              .foregroundStyle(.secondary)
              .frame(maxWidth: .infinity, minHeight: 180)
          } else {
            Chart(pieData) { slice in
              SectorMark(
                angle: .value("Jumlah", slice.amount),
                innerRadius: .ratio(0.6),
                angularInset: 2
              )
              .foregroundStyle(slice.color.gradient)
            }
            .frame(height: 240)
            .animation(.easeInOut, value: pieData)
            
            VStack(alignment: .leading, spacing: 8) {
              ForEach(pieData) { s in
                HStack {
                  Circle().fill(s.color).frame(width: 10, height: 10)
                  Image(systemName: s.systemImage).foregroundStyle(.secondary)
                  Text(s.category)
                  Spacer()
                  Text(s.amount, format: .currency(code: "IDR").precision(.fractionLength(0)))
                    .foregroundStyle(.secondary)
                }
              }
            }
            .padding(.top, 8)
          }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.background))
        .shadow(radius: 2)
        .padding(.horizontal)
        
        // ✅ FILTER & RIWAYAT
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Riwayat Pengeluaran")
                    .font(.headline)
                Spacer()
                
                Menu {
                    Button(action: { sortOrder = .terbaru }) {
                        Label("Terbaru", systemImage: sortOrder == .terbaru ? "checkmark" : "")
                    }
                    Button(action: { sortOrder = .terdahulu }) {
                        Label("Terdahulu", systemImage: sortOrder == .terdahulu ? "checkmark" : "")
                    }
                } label: {
                    Label("Urutkan: \(sortOrder.rawValue)", systemImage: "arrow.up.arrow.down")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            ForEach(sortedTransactions, id: \.self) { trx in
                HStack(spacing: 12) {
                    Image(systemName: "arrow.up.circle")
                        .foregroundStyle(.red)
                    VStack(alignment: .leading) {
                        Text(trx.kategori_Keluar)
                            .fontWeight(.semibold)
                        Text(trx.tanggal, format: .dateTime.day().month().year())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(trx.nominal, format: .currency(code: "IDR"))
                        .foregroundStyle(.red)
                }
                Divider()
            }
        }

        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.background))
        .shadow(radius: 2)
        .padding(.horizontal)
      }
      .padding(.vertical)
    }
  }
}

#Preview {
  PengeluaranView().environmentObject(DataKeuangan())
}
