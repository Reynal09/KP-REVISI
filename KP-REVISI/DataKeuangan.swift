import Foundation
import SwiftUI
import Combine

final class DataKeuangan: ObservableObject {
  @Published var trx: [Transaksii] = []
  
  
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
  
  
  func tambahTransaksi(_ trans: Transaksii) {
    trx.append(trans)
    StreakManager.shared.checkInToday()
  }
}
