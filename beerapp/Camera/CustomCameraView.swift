//
//  CustomCameraView.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 23/07/2022.
//

import SwiftUI
import AVFoundation

struct CustomCameraView: View {
    
    let cameraService = CameraSevice()
    @Binding var captureImage: UIImage?
    @Binding var isPresent: Bool
    
    var body: some View {

        ZStack {
            CameraView(cameraService: cameraService){ result in
                switch result {
                    
                case .success(let photo):
                    if let data = photo.fileDataRepresentation() {
                        captureImage = UIImage(data: data)
                        isPresent = false
                    } else {
                        print("Error: no image data found")
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                    isPresent = false
                }
            }
            
            VStack{
                Spacer()
                Button( action:{
                    cameraService.capturePhoto()
                }, label: {
                    Image(systemName: "circle")
                        .font(.system(size: 72))
                        .foregroundColor(.white)
                }).frame(alignment: .center)
            }
        }
    }
}

