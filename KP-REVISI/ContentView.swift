import SwiftUI

struct ContentView: View {
  @State var selectedOption = "Pemasukan"
  @State var isTambahTransaksi = false
  @EnvironmentObject var financeData: DataKeuangan
  
  var body: some View {
    NavigationStack{
      VStack (alignment: .leading, spacing: 20){
        VStack(alignment: .leading){
          Text("saldo")
            .font(.headline)
            .foregroundStyle(.white.opacity(0.6))
          
          Text(financeData.hitungSaldo(), format: .currency(code: "IDR"))
          
            .font(.largeTitle)
        }
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity,alignment: .leading)
        
        .background(Color(red: 0.243, green: 0.349, blue: 0.439))
        .cornerRadius(20)
      }
      .padding(.horizontal)
      
      Picker("Choos e an option", selection: $selectedOption) {
        ForEach(["Pemasukan", "Pengeluaran"], id: \.self) { option in
          Text(option)
        }
        
      }
      .pickerStyle(.segmented)
      .padding()
      
      ScrollView {
        if selectedOption == "Pemasukan" {
          PemasukanView()

        } else if selectedOption == "Pengeluaran" {
          PengeluaranView()
        }
        
      }

      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("Home")
    }
    
  }
}

#Preview {
  ContentView()
    .environmentObject(DataKeuangan())
}
