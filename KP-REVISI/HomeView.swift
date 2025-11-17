//
//  HomeView.swift
//  KP-REVISI
//
//  Created by iCodeWave Community on 13/11/25.
//


import SwiftUI

struct HomeView: View {
  @State private var nama: String = ""
  @State private var password: String = ""
  @State private var isLoggedIn = false
  
  var body: some View {
    NavigationStack {
      
      ScrollView{
        
        VStack {
          Text("Hemat pangkal kaya, login dan Catat keuanganmu sekarang!!")
            .padding()
          
            .frame(maxWidth: .infinity)
            .background(.green .opacity(0.4))
            .cornerRadius(20)
            .fontWeight(.bold)
          
          
          
          HStack{
            Spacer()
            Text ("Kamu lupa Password?")
              .foregroundStyle(.red)
              .fontWeight(.bold)
          }
          
          NavigationLink(destination: LoginView()) {
            Text("Login")
              .padding(.vertical,5)
              .frame(maxWidth: .infinity)
              .padding(.vertical,8)
              .foregroundStyle(.white)
              .background(.blue)
              .cornerRadius(100)
              .padding(.vertical,20)
          }
          
          NavigationLink(destination: RegisterView()) {
            Text("Register")
            
              .padding(.vertical,5)
              .frame(maxWidth: .infinity)
              .padding(.vertical,8)
              .foregroundStyle(.white)
              .background(.blue)
              .cornerRadius(100)
              .padding(.vertical,20)
          }
          
        }
        .padding(.horizontal)
      }
      .navigationTitle("Home")
      
    }
  }
}

#Preview {
  HomeView()
}
