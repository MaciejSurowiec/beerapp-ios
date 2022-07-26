//
//  PhotoLibraryService.swift
//  BeerUp
//
//  Created by Maciek  Surowiec on 23/07/2022.
//


import SwiftUI
import Foundation
import AVFoundation
import Photos
import UIKit

class PhotoLibraryService: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var photoLibraryPreview: UIImageView!
    
    var imagePickerController = UIImagePickerController()
    public var viewController: UIViewController!
    
    @Published var isAccessible = false
    
    var test = false
    var PhotoChosen: ((UIImage) -> Void)?
        
    func start(callback: @escaping(UIImage) -> Void, completion: @escaping (Error?) -> ()) {
        self.PhotoChosen = callback
        imagePickerController.delegate = self
        checkPermissions(completion: completion)
    }
    
    private func checkPermissions(completion: @escaping (Error?) -> ()){
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] granted in
                if granted == PHAuthorizationStatus.authorized {
                    DispatchQueue.main.async{
                        self?.setupLibrary(completion: completion)
                    }
                } else {
                    return
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupLibrary(completion: completion)
        case .limited:
            break // to change
        @unknown default:
            break
        }
            
        
    }
    
    private func setupLibrary(completion: @escaping (Error?) -> ()){
        self.imagePickerController.sourceType = .photoLibrary
        self.isAccessible = true
    }
    
    public func showLibrary() {
         viewController.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage

        PhotoChosen!(image!)
        test = true
    }
    
    
}
