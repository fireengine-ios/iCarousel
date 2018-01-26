//
//  FaceImageViewInput.swift
//  Depo
//
//  Created by Tsimafei Harhun on 25.01.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol FaceImageViewInput: class, ActivityIndicator {
    func startActivityIndicator()
    func stopActivityIndicator()
    func showFaceImageStatus(_ isFaceImageAllowed: Bool)
}
