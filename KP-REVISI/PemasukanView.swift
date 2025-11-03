//
//  PemasukanView.swift
//  KP-REVISI
//
//  Created by iCodeWave Community on 03/11/25.
//

import SwiftUI
import Charts

struct PemasukanView: View {
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

  var groupedIncome: [(String, Double)] {
    let pemasukan = financeData.trx.filter { $0.jenis == .masuk }
    let grouped = Dictionary(grouping: pemasukan, by: { $0.kategori_Masuk })
    return grouped.map { (kategori, data) in
      (kategori, data.reduce(0) { $0 + $1.nominal })
    }
  }

  var totalIncome: Double {
    groupedIncome.map { $0.1 }.reduce(0, +)
  }

  var body: some View {
    ZStack {
      // 🌈 Background gradasi halus
      LinearGradient(
        colors: [Color.green.opacity(0.15), Color.white],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      VStack(alignment: .leading, spacing: 16) {
        Text("Pemasukan")
          .font(.title2.bold())
          .foregroundStyle(income)

        if !groupedIncome.isEmpty {
          Chart {
            ForEach(groupedIncome, id: \.0) { kategori, total in
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
          VStack(spacing: 16) {
            ZStack {
              Circle()
                .fill(income.opacity(0.1))
                .frame(width: 140, height: 140)
                .shadow(color: income.opacity(0.25), radius: 10, y: 6)
              Image(systemName: "arrow.down.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(income)
                .symbolEffect(.bounce)
            }
            Text("Belum ada data pemasukan")
              .font(.headline)
              .foregroundStyle(.secondary)
            Text("Tambahkan pemasukan pertamamu hari ini 💰")
              .font(.subheadline)
              .foregroundStyle(.gray)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .padding(.top, 40)
          .transition(.opacity)
        }

        ForEach(financeData.trx.filter { $0.jenis == .masuk }, id: \.self) { trx in
          HStack(spacing: 12) {
            Image(systemName: "arrow.down.circle")
              .foregroundStyle(income)
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
                  Image(systemName: kategori_Masuk[trx.kategori_Masuk] ?? "questionmark")
                    .foregroundStyle(.secondary)
                  Text(trx.kategori_Masuk)
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
      .animation(.easeInOut, value: totalIncome)
    }
  }
}

#Preview {
  PemasukanView()
    .environmentObject(DataKeuangan())
}
