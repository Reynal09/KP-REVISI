import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct KP_REVISIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var dataKeuangan = DataKeuangan()
    
    // Menyimpan status login secara permanen
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    @State private var selectedTab = 0
    @State private var isTambahTransaksi = false
    
    var body: some Scene {
        WindowGroup {
            
            // ===========================
            // Jika belum login → ke HomeView
            // ===========================
            if !isLoggedIn {
                VStack {
                    HomeView()
                        .environmentObject(dataKeuangan)
                    
                    // ❗ Tombol reset sementara (hilangkan setelah selesai testing)
                    Button("Reset Status Login") {
                        isLoggedIn = false
                    }
                    .padding(.top, 20)
                    .foregroundColor(.red)
                }
            }
            
            // ===========================
            // Jika sudah login → buka TabView
            // ===========================
            else {
                TabView(selection: $selectedTab) {
                    
                    // Tab Home
                    NavigationStack {
                        ContentView()
                            .navigationTitle("Home")
                    }
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                    
                    // Tab tombol tambah (sheet)
                    Color.clear
                        .tabItem {
                            Label("Tambah", systemImage: "plus.circle")
                        }
                        .tag(1)
                    
                    // Tab transaksi
                    NavigationStack {
                        TambahTransaksiView()
                    }
                    .tabItem {
                        Label("Transaksi", systemImage: "list.bullet")
                    }
                    .tag(2)
                }
                .environmentObject(dataKeuangan)
                
                // Ketika user pilih tab tengah, buka sheet TambahTransaksi
                .onChange(of: selectedTab) { _, newValue in
                    if newValue == 1 {
                        isTambahTransaksi = true
                        selectedTab = 0
                    }
                }
                .sheet(isPresented: $isTambahTransaksi) {
                    TambahTransaksiView()
                        .environmentObject(dataKeuangan)
                }
            }
        }
    }
}
