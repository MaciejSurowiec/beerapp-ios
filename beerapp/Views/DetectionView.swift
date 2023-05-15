//
//  DetectionView.swift
//  BeerUp
//
//  Created by Maciek  Surowiec on 07/10/2022.
//

import SwiftUI
import Photos
import UIKit
import Vision

struct DetectionView: View {
    
    @EnvironmentObject var modelData: ModelData
    var pathLayer: CALayer?
    @State private var isCustomCameraViewPresented = true
    @State private var capturedImage: UIImage? = nil
    @State private var beers: [ModelData.BeerS] =  []
    let modelURL = Bundle.main.url(forResource: "BeerRecognizer", withExtension: "mlmodelc")

    struct DetectedObject: Identifiable {
        let id = UUID()
        let object: VNRecognizedObjectObservation
    }
    
    
    @State var sendingImages: Bool = false
    @State var Rectangles: [DetectedObject] = []
    @State var images: [ModelData.Images] = []
    @State var ids: [Int] = []
    
    
    
    var body: some View {
        NavigationView {
            if sendingImages {
                ProgressView()
            } else {
                VStack {
                    if isCustomCameraViewPresented {
                        CustomCameraView(captureImage: $capturedImage, isPresent: $isCustomCameraViewPresented)
                    } else {
                        if beers.count == 0 {
                            Spacer()
                            NavigationLink(destination: {
                                ZStack{
                                    Image(uiImage: capturedImage!)
                                        .resizable()
                                }
                            }, label:{
                                Image(uiImage: capturedImage!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                            })
                            
                            Button("Analizuj") {
                                do{
                                    images.removeAll()
                                    let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: self.modelURL!))
                                    let imageRequestHandler = VNImageRequestHandler(cgImage:capturedImage!.cgImage!, orientation:CGImagePropertyOrientation.right, options: [:])
                                    let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                                        DispatchQueue.main.async(execute: {
                                            if let results = request.results {
                                                self.drawVisionRequestResults(results)
                                            }
                                        })
                                    })
                                    let request = [objectRecognition]
                                    
                                    do {
                                        try imageRequestHandler.perform(request)
                                    } catch {
                                        print(error)
                                    }
                                } catch {
                                    print(error)
                                }
                                self.beers.removeAll()
                                self.ids.removeAll()
                                for rect  in self.Rectangles {
                                    let start = CACurrentMediaTime()
                                    let width = Int32(rect.object.boundingBox.width * capturedImage!.size.height)
                                    let height = Int32(rect.object.boundingBox.height * capturedImage!.size.width)
                                    let x = Int32((1-rect.object.boundingBox.midX) * capturedImage!.size.height)
                                    let y = Int32((1-rect.object.boundingBox.midY) * capturedImage!.size.width)
                                    let out = OpenCVWrapper.getImageFeatures(capturedImage!, width: width, height: height, x: x, y: y)
                                    
                                    //print(out)
                                    //images.append(ModelData.Images(image: out))
                                    let id = modelData.GetBeerID(data: out)
                                    let end = CACurrentMediaTime()
                                    //print(end-start)
                                    if !ids.contains(id) {
                                        ids.append(id)
                                        modelData.GetBeerByID(id: id, callback: addBeer)
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .dynamicTypeSize(/*@START_MENU_TOKEN@*/.xxxLarge/*@END_MENU_TOKEN@*/)
                            .padding(.bottom, 5)
                            
                            /*
                             if images.count > 0 {
                             
                             Button("Wyslij") {
                             do{
                             sendingImages = true
                             modelData.StartSendingImages(images: images, callback: sendedCallback)
                             }
                             }
                             .buttonStyle(.borderedProminent)
                             .dynamicTypeSize(/*@START_MENU_TOKEN@*/.xxxLarge/*@END_MENU_TOKEN@*/)
                             .padding(.bottom, 5)
                             
                             List{
                             ForEach(images) { image in
                             Image(uiImage: image.image)
                             .resizable()
                             .scaledToFit()
                             }
                             }
                             }
                             
                             
                             */
                    } else {
                         List {
                         ForEach(beers) { beer in
                         ZStack {
                         BeerView(beer: beer)
                         NavigationLink(destination: BeerDetailsView(beer: beer)) {}
                         .opacity(0)
                         }
                         }
                         }.listStyle(.plain)
                     }
                        Spacer()
                        Button("Zrób nowe zdjęcie") {
                            beers.removeAll()
                            Rectangles.removeAll()
                            isCustomCameraViewPresented = true
                        }
                        .buttonStyle(.borderedProminent)
                        .dynamicTypeSize(/*@START_MENU_TOKEN@*/.xxxLarge/*@END_MENU_TOKEN@*/)
                        .padding(.bottom, 5)
                        .frame(alignment: .top)
                         
                    }
                }
            }
        }
    }

    func sendedCallback() {
        sendingImages = false
        images.removeAll()
        isCustomCameraViewPresented = true
    }
    
    
    func addBeer(_ beer: ModelData.BeerS) {
        // trzeba sprawdzic czy tego piwa juz nie ma
        beers.append(beer)
    }
    
    func drawVisionRequestResults(_ results: [Any]) {
        Rectangles.removeAll()
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            
            let obj = DetectedObject(object: objectObservation)
            if objectObservation.labels[0].identifier == "label" {
                self.Rectangles.append(obj)
            }
        }
    }
}
    
    

struct DetectionView_Previews: PreviewProvider {
    static var stats: ModelData.Stats = ModelData.Stats() // empty but I have no idea how to change this
    static var previews: some View {
        DetectionView().environmentObject(ModelData())
    }
}

