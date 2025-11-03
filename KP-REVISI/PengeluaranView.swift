//
//  PengeluaranView.swift
//  KP-REVISI
//
//  Created by iCodeWave Community on 03/11/25.
//

import SwiftUI

struct PengeluaranView: View {
  @EnvironmentObject var financeData: DataKeuangan
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
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Tidak Ada Catatan")
        .font(.subheadline.bold())
      
      ForEach(financeData.trx.filter { $0.jenis == .keluar }, id: \.self) { trx in
        HStack(spacing: 12) {
          Image(systemName: "arrow.up.circle")
            .foregroundStyle(expense)
            .font(.body)
          
          VStack(alignment: .leading, spacing: 2) {
            Text(trx.nominal, format: .currency(code: "IDR").precision(.fractionLength(2)))
              .font(.subheadline.weight(.semibold))
            
            HStack(spacing: 6) {
              Image(systemName: "calendar").foregroundStyle(.secondary)
              Text(trx.tanggal, format: .dateTime.day().month(.abbreviated).year())
                .font(.caption)
                .foregroundStyle(.secondary)
              
              HStack(spacing: 4) {
                Image(systemName: kategori_Keluar[trx.kategori_Keluar] ?? "questionmark")
                  .foregroundStyle(.secondary)
                Text(trx.kategori_Keluar)
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }
          }
          
          Spacer()
        }
        .padding(.vertical, 8)
        Divider()
      }
    }
  }
}

#Preview {
  PengeluaranView()
    .environmentObject(DataKeuangan())
}
