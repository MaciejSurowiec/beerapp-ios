//
//  AccountView.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 23/07/2022.
//

import SwiftUI
import StoreKit
import AVFoundation

struct AccountView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink{
                        Text("Jeszcze nic tu nie ma")
                    } label: {
                        HStack{
                            Image(systemName: "person.fill")
                                .font(.title3)
                            Text("Profil")
                        }.padding()
                    }
                        
                    NavigationLink{
                        AboutView()
                    } label: {
                        HStack{
                            Image(systemName: "person.3.fill")
                                .font(.title3)
                            
                            Text("O nas")
                        }.padding()
                    }
                
                    Button(action: {
                            ReviewHandler.requestReview()
                    }, label:{
                        HStack{
                            Image(systemName: "star.fill")
                                .font(.title3)
                            
                            Text("Oceń nas")
                        }.padding()
                    })
                    
                    HStack{
                        Image(systemName: "globe")
                            .font(.title3)
                        Link("Odwiedź naszą stronę", destination: URL(string: "https://diplomabeerapp.github.io/")!)
                    }.padding()
                }.listStyle(.plain)
                
                
               Button("Wyloguj") {
                   modelData.Logout()
               }
               .buttonStyle(.borderedProminent)
               .dynamicTypeSize(.xxxLarge)
               .padding(.bottom, 20)
            }.padding()
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
