//
//  TagView.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 22/07/2022.
//

import SwiftUI

struct TagView: View {
    
    @State var active: Bool
    var tag: String
    
    init(active: Bool, tag: String, callback: ((String, Bool) -> Void)? = nil) {
        self.active = active
        self.tag = tag        
        self.ChangeTag = callback
    }
    
    private var ChangeTag: ((String, Bool) -> Void)?
    
    var body: some View {
        if active {
            Button(TranslateTag(tag)){
                active = false
                ChangeTag!(tag, active)
            }
            .buttonStyle(.borderedProminent)
            .dynamicTypeSize(.large)
            .padding(.bottom, 10)
        } else {
            Button(TranslateTag(tag)){
                active = true
                ChangeTag!(tag, active)
            }
            .buttonStyle(.borderedProminent)
            .dynamicTypeSize(.large)
            .padding(.bottom, 10)
            .tint(.gray)
        }
    }
    
    func TranslateTag(_ tag: String)->String {
        switch(tag){
            case "WHEAT":
                return "Pszeniczne"
            case "BITTER":
                return "Gorzkie"
            case "LIGHT":
                return "Jasne"
            case "DARK":
                return "Ciemne"
            case "HOPPY":
                return "Chmielowe"
            case "CITRUS":
                return "Cytrusowe"
            case "MALT":
                return "Słodowe"
            case "FRUITY":
                return "Owocowe"
            case "SOUR":
                return "Kwaśne"
            case "CARMEL":
                return "Karmelowe"
            case "SWEET":
                return "Słodkie"
            case "CHOCOLATE":
                return "Czekoladowe"
            case "COFFEE":
                return "Kawowe"
            case "MILK":
                return "Mleczne"
            case "HERBAL":
                return "Ziołowe"
            case "BANANA":
                return "Bananowe"
            case "HONEY":
                return "Miodowe"
            case "FLOWER":
                return "Kwiatowe"
            default:
                return "UNKNOWN"
        }
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(active: true, tag: "SWEET")
    }
}
