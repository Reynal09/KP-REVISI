//
//  Model.swift
//  projek kp1
//
//  Created by iCodeWave Community on 26/09/25.
//

import Foundation
import SwiftUI

enum JenisTransaksi: Codable {
  case masuk
  case keluar
  case utang
  case piutang
}


struct Transaksii: Codable, Hashable, Identifiable {
  let id: UUID
  let nominal: Double
  let jenis: JenisTransaksi
  let kategori_Masuk: String
  let kategori_Keluar: String
  let tanggal: Date
  

  init(id: UUID = UUID(), nominal: Double, jenis: JenisTransaksi, kategori_Masuk: String, kategori_Keluar: String, tanggal: Date) {
    self.id = id
    self.nominal = nominal
    self.jenis = jenis
    self.kategori_Masuk = kategori_Masuk
    self.kategori_Keluar = kategori_Keluar
    self.tanggal = tanggal
  }
}
