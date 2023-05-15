//
//  BeerListView.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 12/07/2022.
//

import SwiftUI


struct BeerListView: View {
    
    @EnvironmentObject var modelData: ModelData
    @State var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(alignment: .top) {
                    Image(systemName: "magnifyingglass")
                    TextField("Search ..", text: $searchText).onChange(of: searchText) { newValue in
                        modelData.queryPhrase = newValue
                        modelData.DownloadBeerList()
                    }.onSubmit {
                        if modelData.queryPhrase != searchText {
                            modelData.queryPhrase = searchText
                            modelData.DownloadBeerList()
                        }
                    }
                    .dynamicTypeSize(/*@START_MENU_TOKEN@*/.xxxLarge/*@END_MENU_TOKEN@*/)
                    .submitLabel(.search)
                }.padding()
                
                if modelData.listDownloaded {
                    List {
                        ForEach(modelData.beerList) { beer in
                            ZStack {
                                BeerView(beer: beer)
                                NavigationLink(destination: BeerDetailsView(beer: beer)) {}
                                .opacity(0)
                            }
                        }
                            
                        Rectangle()
                            .fill(.clear)
                            .onAppear{
                                if !modelData.listLoading && modelData.limit <= modelData.beerList.count {
                                    modelData.DownloadMoreList()
                                }
                        }
                    }.listStyle(.plain)
                } else {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .padding(0)
        }
    }
}

struct BeerListView_Previews: PreviewProvider {
    static var previews: some View {
        BeerListView().environmentObject(ModelData())            .environmentObject(ModelData()).previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
    }
}
