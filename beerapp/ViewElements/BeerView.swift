//
//  BeerView.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 12/07/2022.
//

import SwiftUI

import StarRating

struct BeerView: View {
    @State var beer: ModelData.BeerS
    
    @State var photoLoaded: Bool = false
    
    @EnvironmentObject var modelData: ModelData
    
    @State var image: UIImage = UIImage()
    @State var customConfig = StarRatingConfiguration(numberOfStars: 5, minRating: 0, borderWidth: CGFloat(1), borderColor: .chocolate, fillColors: [.chocolate])
    
    var body: some View {
        HStack{
            AsyncImage(url: URL(string: beer.mainPhotoUrl)){ image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .aspectRatio(contentMode: .fit)
            .frame(width:150)
            
            VStack{
                Text(beer.name)
                Text(beer.style)
                Text(beer.brewery)
                HStack{
                    Text("ibu:")
                    Text(beer.ibu)
                }
                
                HStack{
                    Text("abv:")
                    Text(beer.abv)
                }
                
                StarRating(initialRating: Double(beer.review) / 2, configuration: $customConfig).frame(height: 20)
            }.padding()
        }
    }
    
    func SetImage(img: UIImage) {
        image = img
        photoLoaded = true
    }
}

struct BeerView_Previews: PreviewProvider {
    static var testBeer: ModelData.BeerS = ModelData.BeerS() // empty but I have no idea how to change this
    
    static var previews: some View {
        BeerView(beer: testBeer).environmentObject(ModelData())
    }
}
