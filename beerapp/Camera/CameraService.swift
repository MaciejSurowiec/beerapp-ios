//
//  CameraService.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 23/07/2022.
//

import Foundation
import AVFoundation


class CameraSevice {
    
    var session: AVCaptureSession?
    var delegate: AVCapturePhotoCaptureDelegate?
    
    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    enum AuthenticationError: Error {
        case denied
        case restricted
        case unknown
    }
    
    func start(delegate: AVCapturePhotoCaptureDelegate, completion: @escaping (Error?) -> ()) {
        self.delegate = delegate
        checkPermissions(completion: completion)
    }
    
    private func checkPermissions(completion: @escaping (Error?) -> ()) {
        do {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
                
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    guard granted else { return }
                    DispatchQueue.main.async{
                        self?.setupCamera(completion: completion)
                    }
                }
            case .restricted:
                throw AuthenticationError.restricted
            case .authorized:
                setupCamera(completion: completion)
            case .denied:
                throw AuthenticationError.denied
            @unknown default:
                throw AuthenticationError.unknown
            }
        } catch {
            completion(error)
        }
    }
    
    private func setupCamera(completion: @escaping (Error?) -> ()){
        DispatchQueue.main.async {
            let session = AVCaptureSession()
            session.sessionPreset = AVCaptureSession.Preset.photo
                if let device = AVCaptureDevice.default(for: .video){
                    do{
                        let input = try AVCaptureDeviceInput(device: device)
                        if session.canAddInput(input) {
                            session.addInput(input)
                        }
                        
                        if session.canAddOutput(self.output) {
                            session.addOutput(self.output)
                        }
                        
                        self.previewLayer.videoGravity = .resizeAspectFill
                        self.previewLayer.session = session
                        
                        session.startRunning()
                        self.session = session
                    } catch {
                        completion(error)
                    }
                }
        }
    }
    
    func capturePhoto(with settings: AVCapturePhotoSettings = AVCapturePhotoSettings()) {
        output.capturePhoto(with: settings, delegate: delegate!)
    }
    
    
}

