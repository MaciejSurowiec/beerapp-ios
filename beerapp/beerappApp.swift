//
//  beerappApp.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 06/05/2022.
//

import SwiftUI

// stowrzyc mother view
// w mother view dac switcha i zmieniac na odpowiednie view
@main
struct beerappApp: App {
    @StateObject private var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(modelData)
        }
    }
}
