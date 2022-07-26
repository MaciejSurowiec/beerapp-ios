//
//  AboutView.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 09/06/2022.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
            VStack{
                Text("Aplikacja jest obecnie rozwijana i nie posiada jeszcze wszystkich docelowych funkcjonalności, ale dane dostarczone przez Ciebie pozwolą nam na jej szybkie rozwinięcie. Do docelowych funkcjonalności należą: system rekomendacji piw, dzięki któremu nie będziesz musiał się zastanawiać w sklepie jakie piwo wybrać system rozpoznawania etykiet ze zdjęć, dzięki któremu zrobisz po prostu zdjęcie sklepowej półki a aplikacja sama rozpozna obecne na niej piwa Zachęcamy do intensywnego korzystania z aplikacji 🙂").padding(10).multilineTextAlignment(.leading)
                Spacer()
            }
            .navigationTitle("O nas")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AboutView()
        }
    }
}
