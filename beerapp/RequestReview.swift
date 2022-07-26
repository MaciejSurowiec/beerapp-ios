//
//  RequestReview.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 23/07/2022.
//

import Foundation
import StoreKit


class ReviewHandler{
    
    static func requestReview() {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
}

