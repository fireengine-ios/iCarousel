//
//  Error+Network.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 2/28/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

extension Error {
    var isNetworkError: Bool {
        return self is URLError
    }
    
    var localizedDescription: String {
        return isNetworkError ? "Please check your internet connection is active and Mobile Data is ON." : self.localizedDescription
    }       
}
