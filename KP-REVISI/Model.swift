import Foundation
import SwiftUI


enum JenisTransaksi: String, Codable {
    case masuk
    case keluar
    case utang
    case piutang
}

struct Transaksii: Codable, Hashable, Identifiable {
    var id: String
    var nominal: Double
    var jenis: JenisTransaksi
    var kategori_Masuk: String
    var kategori_Keluar: String
    var tanggal: Date

    init(
        id: String = UUID().uuidString,
        nominal: Double,
        jenis: JenisTransaksi,
        kategori_Masuk: String,
        kategori_Keluar: String,
        tanggal: Date
    ) {
        self.id = id
        self.nominal = nominal
        self.jenis = jenis
        self.kategori_Masuk = kategori_Masuk
        self.kategori_Keluar = kategori_Keluar
        self.tanggal = tanggal
    }
}
