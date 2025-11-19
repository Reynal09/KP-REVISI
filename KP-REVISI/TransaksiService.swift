import FirebaseFirestore
import FirebaseAuth

class TransaksiService {
    private let db = Firestore.firestore()

    private func toDictionary(_ transaksi: Transaksi) -> [String: Any] {
        return [
            "id": transaksi.id,
            "nominal": transaksi.nominal,
            "jenis": transaksi.jenis.rawValue,
            "kategori_Masuk": transaksi.kategori_Masuk,
            "kategori_Keluar": transaksi.kategori_Keluar,
            "tanggal": Timestamp(date: transaksi.tanggal)
        ]
    }

    // SIMPAN TRANSAKSI PER USER
    func tambahTransaksi(_ transaksi: Transaksi, uid: String) async throws {
        guard !uid.isEmpty else { return } // atau throw error
        let data = toDictionary(transaksi)
        try await db.collection("user")
            .document(uid)
            .collection("transaksi")
            .document(transaksi.id)
            .setData(data)
    }

    // AMBIL TRANSAKSI USER
    func ambilTransaksiUser(uid: String) async throws -> [Transaksi] {
        guard !uid.isEmpty else { return [] }
        let snapshot = try await db.collection("user")
            .document(uid)
            .collection("transaksi")
            .order(by: "tanggal", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { doc -> Transaksi? in
            let data = doc.data()
            return Transaksi(
                id: data["id"] as? String ?? doc.documentID,
                nominal: data["nominal"] as? Double ?? 0,
                jenis: JenisTransaksi(rawValue: data["jenis"] as? String ?? "") ?? .masuk,
                kategori_Masuk: data["kategori_Masuk"] as? String ?? "",
                kategori_Keluar: data["kategori_Keluar"] as? String ?? "",
                tanggal: (data["tanggal"] as? Timestamp)?.dateValue() ?? Date()
            )
        }
    }
}
