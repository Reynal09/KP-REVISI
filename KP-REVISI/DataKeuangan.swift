import Foundation
import SwiftUI
import Combine

enum Page {
 case home,login
}

final class DataKeuangan: ObservableObject {
  @Published var trx: [Transaksi] = []
  @Published var currentPage: Page = .home
  
  func hitungSaldo() -> Double {
    // ForEach untuk looping UI langsung di SwiftUI, pake protocol View
    // for loop untuk diluar urusan View
    var jumlahSaldo: Double = 0
    for i in trx {
//      jumlahSaldo += i.nominal
      
      if i.jenis == .keluar {
        jumlahSaldo = jumlahSaldo - i.nominal
      }
      else{
        jumlahSaldo = jumlahSaldo + i.nominal
      }
    }
    return jumlahSaldo
  }
  
//  func ballance() -> Double {
//
//    var ballance: Double = 0
//    for i in trx {
//      if i.tanggal < 7 {
//
//      }
//    }
//  }
  
  
  func tambahTransaksi(_ trans: Transaksi) {
    trx.append(trans)
    StreakManager.shared.checkInToday()
  }
}
