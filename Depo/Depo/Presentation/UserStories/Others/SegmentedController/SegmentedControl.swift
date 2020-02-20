//
//  SegmentedControl.swift
//  Depo_LifeTech
//
//  Created by Igor Bunevich on 7/26/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation
import UIKit

enum SegmentedImage {
    case documents
    case favorites
    case music
    case trashBin
    
    var image: UIImage? {
        switch self {
        case .documents:
            return UIImage(named: "segment_documents")
        case .favorites:
            return UIImage(named: "segment_favorites")
        case .music:
            return UIImage(named: "segment_music")
        case .trashBin:
            return UIImage(named: "segment_trash")
        }
    }
}

final class SegmentedControl: UISegmentedControl {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        allSubviews(of: UILabel.self)
            .forEach { $0.adjustsFontSizeToFitWidth() }
    }
}
