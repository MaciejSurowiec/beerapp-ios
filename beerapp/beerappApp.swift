//
//  beerappApp.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 06/05/2022.
//

import SwiftUI
import NumPySupport
import PythonSupport
import PythonKit

@main
struct beerappApp: App {
    @StateObject private var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(modelData)
        }
    }
}
