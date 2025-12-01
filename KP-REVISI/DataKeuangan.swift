import Foundation // Mengimpor Foundation untuk tipe dasar dan utilitas
import SwiftUI // Mengimpor SwiftUI untuk integrasi dengan UI reaktif
import Combine // Mengimpor Combine (mendukung ObservableObject dan @Published)

enum Page { // Enum untuk halaman yang tersedia di aplikasi
 case home,login // Dua kemungkinan halaman: beranda dan login
}

final class DataKeuangan: ObservableObject { // Kelas model data keuangan yang dapat diamati oleh SwiftUI
  @Published var trx: [Transaksi] = [] // Daftar transaksi, memicu update UI saat berubah
  @Published var currentPage: Page = .home // Halaman saat ini, default ke home
  
  func hitungSaldo() -> Double { // Menghitung saldo total berdasarkan transaksi
    // ForEach untuk looping UI langsung di SwiftUI, pake protocol View
    // for loop untuk diluar urusan View
    var jumlahSaldo: Double = 0 // Inisialisasi saldo awal 0
    for i in trx { // Iterasi semua transaksi
//      jumlahSaldo += i.nominal // Contoh alternatif (dikomentari): tidak memperhitungkan jenis transaksi
      
      if i.jenis == .keluar { // Jika transaksi adalah pengeluaran
        jumlahSaldo = jumlahSaldo - i.nominal // Kurangi saldo dengan nominal
      }
      else{ // Jika bukan pengeluaran (diasumsikan pemasukan)
        jumlahSaldo = jumlahSaldo + i.nominal // Tambahkan saldo dengan nominal
      }
    }
    return jumlahSaldo // Kembalikan saldo akhir
  }
  
//  func ballance() -> Double { // Contoh fungsi yang belum selesai (dikomentari)
//
//    var ballance: Double = 0
//    for i in trx {
//      if i.tanggal < 7 {
//
//      }
//    }
//  }
  
  
  func tambahTransaksi(_ trans: Transaksi) { // Menambahkan transaksi baru
    trx.append(trans) // Tambahkan transaksi ke daftar dan trigger update UI
    StreakManager.shared.checkInToday { _,_  in
      // Completion handler intentionally left empty
    } // Tandai check-in untuk streak harian
  }
}

