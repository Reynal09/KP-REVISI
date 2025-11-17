import FirebaseFirestore

class TransaksiService {
    private let db = Firestore.firestore()

    // Convert Transaksii → Dictionary
    private func toDictionary(_ transaksi: Transaksii) -> [String: Any] {
        return [
            "id": transaksi.id,
            "nominal": transaksi.nominal,
            "jenis": transaksi.jenis.rawValue,
            "kategori_Masuk": transaksi.kategori_Masuk,
            "kategori_Keluar": transaksi.kategori_Keluar,
            "tanggal": Timestamp(date: transaksi.tanggal)
        ]
    }

    // Convert Firestore Document → Transaksii
    private func fromDocument(_ document: DocumentSnapshot) -> Transaksii? {
        guard let data = document.data() else { return nil }

        guard
            let nominal = data["nominal"] as? Double,
            let jenisString = data["jenis"] as? String,
            let jenis = JenisTransaksi(rawValue: jenisString),
            let kategori_Masuk = data["kategori_Masuk"] as? String,
            let kategori_Keluar = data["kategori_Keluar"] as? String,
            let timestamp = data["tanggal"] as? Timestamp
        else {
            return nil
        }

        let id = data["id"] as? String ?? document.documentID

        return Transaksii(
            id: id,
            nominal: nominal,
            jenis: jenis,
            kategori_Masuk: kategori_Masuk,
            kategori_Keluar: kategori_Keluar,
            tanggal: timestamp.dateValue()
        )
    }

    // Tambah transaksi ke Firestore
    func tambahTransaksi(_ transaksi: Transaksii) async throws {
        let data = toDictionary(transaksi)
        try await db.collection("transaksi")
            .document(transaksi.id)
            .setData(data)
    }

    // Ambil semua transaksi
    func ambilSemuaTransaksi() async throws -> [Transaksii] {
        let snapshot = try await db.collection("transaksi").getDocuments()
        return snapshot.documents.compactMap { fromDocument($0) }
    }

    // Hapus transaksi
    func hapusTransaksi(id: String) async throws {
        try await db.collection("transaksi").document(id).delete()
    }
}
