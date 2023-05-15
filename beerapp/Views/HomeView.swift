//
//  HomeView.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 12/07/2022.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        NavigationView {
            VStack{
                HStack{
                    VStack{
                        Text("Ocenione piwa")
                        ZStack{
                            Image(systemName: "seal.fill").foregroundColor(.chocolate).font(.system(size: 62))
                            Image(systemName: "seal.fill").foregroundColor(.chocolate).font(.system(size: 62))
                                .rotationEffect(.degrees(-22.5))
                            Circle()
                                .inset(by: 0).stroke(Color.white, lineWidth: 1).frame(width: 52, height: 52)
                            Circle()
                                .inset(by: 0).stroke(Color.white, lineWidth: 1).frame(width: 57, height: 57)
                            
                            Text(modelData.stats.numberOfReviews == 0 ? "-" : String(modelData.stats.numberOfReviews))
                                .font(.system(size: 25))
                                .foregroundColor(.white)
                        }
                    }.padding()
                    Spacer()
                    VStack{
                        Text("Dodane zdjęcia")
                        ZStack{
                            Image(systemName: "seal.fill").foregroundColor(.chocolate).font(.system(size: 62))
                            Image(systemName: "seal.fill").foregroundColor(.chocolate).font(.system(size: 62))
                                .rotationEffect(.degrees(-22.5))
                            Circle()
                                .inset(by: 0).stroke(Color.white, lineWidth: 1).frame(width: 52, height: 52)
                            Circle()
                                .inset(by: 0).stroke(Color.white, lineWidth: 1).frame(width: 57, height: 57)
                            
                            Text(modelData.stats.numberOfPhotos == 0 ? "-" : String(modelData.stats.numberOfPhotos))
                                .font(.system(size: 25))
                            .foregroundColor(.white)
                        }
                    }.padding()
                }.padding()

                List {
                    ForEach(modelData.stats.lastThreeReviews) { beer in
                        ZStack {
                            BeerView(beer: beer)
                            NavigationLink(destination: BeerDetailsView(beer: beer)) {}
                            .opacity(0)
                        }
                    }
                }.listStyle(.plain)
                    .refreshable{
                    modelData.GetStatistic()
                }
            }.navigationBarHidden(true)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var stats = ModelData.Stats()
    static var previews: some View {
       HomeView().environmentObject(ModelData())
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
    }
}
