//
//  PengeluaranView.swift
//  KP-REVISI
//
//  Created by iCodeWave Community on 03/11/25.
//

import SwiftUI
import Charts

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

  var groupedExpense: [(String, Double)] {
    let pengeluaran = financeData.trx.filter { $0.jenis == .keluar }
    let grouped = Dictionary(grouping: pengeluaran, by: { $0.kategori_Keluar })
    return grouped.map { (kategori, data) in
      (kategori, data.reduce(0) { $0 + $1.nominal })
    }
  }

  var totalExpense: Double {
    groupedExpense.map { $0.1 }.reduce(0, +)
  }

  var body: some View {
    ZStack {
      // 🌈 Background gradien lembut
      LinearGradient(
        colors: [Color.teal.opacity(0.15), Color.white],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      VStack(alignment: .leading, spacing: 16) {
        Text("Pengeluaran")
          .font(.title2.bold())
          .foregroundStyle(expense)

        if !groupedExpense.isEmpty {
          // Pie Chart
          Chart {
            ForEach(groupedExpense, id: \.0) { kategori, total in
              SectorMark(
                angle: .value("Total", total),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
              )
              .foregroundStyle(by: .value("Kategori", kategori))
            }
          }
          .frame(height: 220)
          .chartLegend(position: .trailing)
          .padding(.bottom, 8)
          .transition(.opacity.combined(with: .scale))
        } else {
          // ✨ Tampilan awal kosong yang menarik
          VStack(spacing: 16) {
            ZStack {
              Circle()
                .fill(expense.opacity(0.1))
                .frame(width: 140, height: 140)
                .shadow(color: expense.opacity(0.25), radius: 10, y: 6)
              Image(systemName: "arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(expense)
                .symbolEffect(.bounce)
            }
            Text("Belum ada data pengeluaran")
              .font(.headline)
              .foregroundStyle(.secondary)
            Text("Mulai catat pengeluaranmu hari ini 🧾")
              .font(.subheadline)
              .foregroundStyle(.gray)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .padding(.top, 40)
          .transition(.opacity)
        }

        // Riwayat transaksi
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
      .padding()
      .animation(.easeInOut, value: totalExpense)
    }
  }
}

#Preview {
  PengeluaranView()
    .environmentObject(DataKeuangan())
}
