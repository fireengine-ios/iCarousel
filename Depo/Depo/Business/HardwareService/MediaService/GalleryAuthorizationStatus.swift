//
//  GalleryAuthorizationStatus.swift
//  Depo
//
//  Created by Konstantin Studilin on 27.10.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Photos


enum GalleryAuthorizationStatus {
    case authorized
    case limited
    case denied
    case notDetermined
    
    var analyticsValue: String {
        switch self {
            case .authorized: return "All"
            case .denied: return "None"
            case .limited: return "Selected"
            case .notDetermined: return ""
        }
    }
}


extension PHAuthorizationStatus {
    func toGalleryAuthorizationStatus() -> GalleryAuthorizationStatus {
        switch self {
            case .authorized:
                return .authorized
                
            case .limited:
                return .limited
                
            case .denied, .restricted:
                return .denied
                
            case .notDetermined:
                return .notDetermined
                
            default:
                assertionFailure("Add the case")
                return .notDetermined
        }
    }
}
