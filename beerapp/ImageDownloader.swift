//
//  ImageDownloader.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 13/07/2022.
//

import Foundation
import UIKit
import SwiftUI


extension UIImageView{
    
    convenience init(photoUrl: String){
        self.init()
        if let url = URL(string: photoUrl) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async { /// execute on main thread
                    self.image = UIImage(data: data)
                }
            }
            
            task.resume()
        }
    }
    
}
/*

extension Image{
    
    init(photoUrl: String){
        
        if let url = URL(string: photoUrl) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async { /// execute on main thread
                    
                    self = Image(uiImage: UIImage(data: data) ?? UIImage())
                }
            }
            
            task.resume()
        } else {
            self = Image("logo")
        }
    }
}
*/
