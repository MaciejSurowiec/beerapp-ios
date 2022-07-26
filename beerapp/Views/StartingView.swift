//
//  StartingView.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 08/07/2022.
//

import SwiftUI

struct StartingView: View {
    var body: some View {
        ZStack{
            Color.chocolate
                .ignoresSafeArea()
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 250)
        }
    }
}

struct StartingView_Previews: PreviewProvider {
    static var previews: some View {
        StartingView()
    }
}
