//
//  BeerDetailsView.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 13/07/2022.
//

import SwiftUI
import StarRating
import FrameUp

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}


struct BeerDetailsView: View {
    
    @EnvironmentObject var modelData: ModelData
    @State var beer: ModelData.BeerS
    @State var review: Int = 0
    @State var isPhotoSended = false
    @State private var capturedImage: UIImage? = nil
    @State private var isCustomCameraViewPresented = false
    @State private var isPhotoSending = false
    @State private var reviewDisable = true
    @State private var tags: [String]
    @State private var isReviewSended = false
    @State private var isTagsSended = false
    @State private var isTagsButtonDisabled = true
    
    @State var customConfig = StarRatingConfiguration(numberOfStars: 5, minRating: 0, borderWidth: CGFloat(1), borderColor: .chocolate, fillColors: [.chocolate])
    
    
    init(beer: ModelData.BeerS) {
        self.beer = beer
        tags = beer.tags
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                AsyncImage(url: URL(string: beer.mainPhotoUrl)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fit)
                .padding()
                
                Group{
                    Text(beer.name)
                    Text(beer.style)
                    Text(beer.brewery)
                    
                    HStack{
                        HStack{
                            Text("ibu:")
                            Text(beer.ibu)
                        }
                        Spacer()
                        HStack{
                            Text("abv:")
                            Text(beer.abv)
                        }
                    }.padding()
                }
                VStack{
                    HStack{
                        Spacer()
                        StarRating(initialRating: Double(beer.review) / 2, configuration: $customConfig, onRatingChanged: { newRating in
                            review = Int(newRating * 2)
                            isReviewSended = false
                            reviewDisable = (review != beer.review)
                        })
                        Spacer()
                    }.frame(height:60)
                
                    if isReviewSended {
                        Text("Ocena została wysłana")
                            .foregroundColor(.green)
                    }
                
                    Button("Wyślij ocenę"){
                        modelData.SendReview(review: review , beer: beer, callback: ReviewSended)
                    }
                    .buttonStyle(.borderedProminent)
                    .dynamicTypeSize(/*@START_MENU_TOKEN@*/.xxxLarge/*@END_MENU_TOKEN@*/)
                    .padding(.bottom, 20)
                    .disabled(!reviewDisable || review == 0)
                }
                    
                Spacer()
                Group {
                    VStack {
                        if(modelData.tagsDownloaded){
                            WidthReader { width in
                                HFlow(modelData.tags, maxWidth: width){ tag in
                                    TagView(active: beer.tags.contains(tag), tag: tag, callback: ChangeTag)
                                }
                            }.padding()
                        } else {
                            ProgressView()
                        }
                    }
                    Spacer()
                    if isTagsSended {
                        Text("Tagi zostały wysłane")
                            .foregroundColor(.green)
                    }
                    Button("Wyślij tagi"){
                        modelData.SendTags(tags: beer.tags, beer: beer, callback: TagsSended)
                    }
                    .buttonStyle(.borderedProminent)
                    .dynamicTypeSize(/*@START_MENU_TOKEN@*/.xxxLarge/*@END_MENU_TOKEN@*/)
                    .disabled(isTagsButtonDisabled)
                }
                if capturedImage != nil {
                    NavigationLink(destination: {
                        Image(uiImage: capturedImage!)
                                .resizable()
                                .scaledToFill()
                    }, label:{
                    Image(uiImage: capturedImage!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            
                    })
                    .disabled(isPhotoSending)
                    
                    if !isPhotoSending {
                        Button("Wyślij zdjęcie") {
                            isPhotoSending = true
                            modelData.StartSendSendingImage(beerId: beer.beerId, image: capturedImage!, callback: PhotoSended)
                        }
                        .buttonStyle(.borderedProminent)
                        .dynamicTypeSize(/*@START_MENU_TOKEN@*/.xxxLarge/*@END_MENU_TOKEN@*/)
                        .padding(.bottom, 20)
                    }
                
                    if isPhotoSended {
                        Text("Zdjęcie zostało wysłane")
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                if isPhotoSending{
                    ProgressView()
                } else {
                    Button(action: {
                        isCustomCameraViewPresented.toggle()
                    }, label: {
                        Text("Dodaj Zdjęcie")
                    })
                    .buttonStyle(.borderedProminent)
                    .dynamicTypeSize(/*@START_MENU_TOKEN@*/.xxxLarge/*@END_MENU_TOKEN@*/)
                    .dynamicTypeSize(.large)
                    .sheet(isPresented: $isCustomCameraViewPresented, content: {
                        CustomCameraView(captureImage: $capturedImage, isPresent: $isCustomCameraViewPresented)
                    })
                }
            }.padding()
        }
    }
    
    func ChangeTag(_ tag: String, _ add: Bool) {
        isTagsSended = false
        if add {
            tags.append(tag)
        } else {
            tags.remove(at: tags.firstIndex(of: tag) ?? 0)
        }
        
        if Set(tags) == Set(beer.tags) {
            isTagsButtonDisabled = true
        } else {
            isTagsButtonDisabled = false
        }
    }
    
    func ReviewSended() {
        isReviewSended = true
    }
    
    func TagsSended() {
        isTagsSended = true
    }

    func PhotoSended() {
        capturedImage = nil
        isPhotoSended = true
        isPhotoSending = false
    }
    
}

struct BeerDetailsView_Previews: PreviewProvider {
    static var testBeer: ModelData.BeerS = ModelData.BeerS() // empty but I have no idea how to change this
    
    static var previews: some View {
        Group {
            BeerDetailsView(beer: testBeer).environmentObject(ModelData())
            BeerDetailsView(beer: testBeer).previewDevice("iPad (9th generation)").environmentObject(ModelData())
        }
    }
}
