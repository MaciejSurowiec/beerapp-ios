//
//  LoggedView.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 09/06/2022.
//

import SwiftUI

struct LoggedView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    @State private var selection: Tab = .homePage

    enum Tab {
        case homePage
        case about
        case beerList
    }
    
    var body: some View {
        VStack{
            TabView(selection: $selection) {
                HomeView()
                    .tabItem {
                        Label("Strona Główna", systemImage: "house")
                    }
                    .tag(Tab.homePage)
                
                BeerListView()
                    .tabItem {
                        Label("Lista Piw", systemImage: "list.bullet")
                    }
                    .tag(Tab.beerList)
                
                AccountView()
                    .tabItem {
                        Label("Konto", systemImage: "person.fill")
                    }
                    .tag(Tab.about)
                
            }.onAppear() {
                let appearance = UITabBarAppearance()
                appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
                appearance.backgroundColor = UIColor(Color.orange.opacity(0.2))
                
                // Use this appearance when scrolling behind the TabView:
                UITabBar.appearance().standardAppearance = appearance
                // Use this appearance when scrolled all the way up:
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            .foregroundColor(.primary)
        }.onChange(of: selection){ newState in
            if (newState == Tab.beerList) {
                if (modelData.beerList.isEmpty) {
                    modelData.DownloadBeerList()
                }
            }
        }
    }
    

}

struct LoggedView_Previews: PreviewProvider {
    
    static var stats: ModelData.Stats = ModelData.Stats() // empty but I have no idea how to change this
    static var previews: some View {
        LoggedView().environmentObject(ModelData())
    }
}
