//
//  KP_REVISIApp.swift
//  KP-REVISI
//
//  Created by iCodeWave Community on 03/11/25.
//

import SwiftUI

@main
struct KP_REVISIApp: App {
  @State private var isTambahTransaksi = false
  @State private var selectedTab = 0
  @StateObject var dataKeuangan = DataKeuangan()

  
    var body: some Scene {
      WindowGroup {
        TabView(selection: $selectedTab) {
          NavigationStack {
            ContentView()
              .navigationTitle("Home")
          }
          .tabItem {
            Label("Home", systemImage: "house")
          }
          .tag(0)

          Color.clear
            .tabItem {
              Label("Tambah", systemImage: "plus.circle")
            }
            .tag(1)
          
          .tabItem {
            Label("Transaksi", systemImage: "list.bullet")
          }
          .tag(2)
        }
        // Penting: semua view di dalam TabView mendapat environment object yang sama
        .environmentObject(dataKeuangan)
        // Pindahkan onChange ke TabView agar memantau perubahan tab dengan benar
        .onChange(of: selectedTab) { _, newValue in
          if newValue == 1 {
            isTambahTransaksi = true
            selectedTab = 0 // kembali ke Home setelah memicu sheet tambah transaksi
          }
        }
        // Pindahkan sheet ke TabView agar bisa ditampilkan dari mana saja
        .sheet(isPresented: $isTambahTransaksi) {
         TambahTransaksiView()
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(24)
            .environmentObject(dataKeuangan)
        }
      }
    }
}
