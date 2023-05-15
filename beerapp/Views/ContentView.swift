//
//  ContentView.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 06/05/2022.
//

import SwiftUI


private enum Field: Int, CaseIterable {
    case username, password
}

extension Color {
        static let chocolate = Color("chocolate")
}


struct ContentView: View {
    
    @EnvironmentObject var modelData: ModelData

    @State private var selection: Tab = .login
    
    enum Tab {
        case login
        case logged
    }
    
    
    var body: some View {
        if modelData.noInternet {
            ZStack{
                VStack{
                    Spacer()
                    HStack{
                        Image(systemName: "icloud.slash.fill")
                            .font(.title3)
                        Text("Brak połączenia z Internetem :(")
                    }
                    Spacer()
                }
            }
        } else {
            if modelData.logged {
                if modelData.statsDownloaded {
                    LoggedView()
                } else {
                    StartingView()
                }
            } else {
                LoginView()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData()).previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        
        ContentView()
            .environmentObject(ModelData()).previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
    }
}
