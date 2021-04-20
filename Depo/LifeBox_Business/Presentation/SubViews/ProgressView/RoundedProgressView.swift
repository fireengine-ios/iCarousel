//
//  RoundedProgressView.swift
//  Depo
//
//  Created by Maksim Rahleev on 12/08/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import UIKit

// Using on UsageInfo screen

class RoundedProgressView: UIProgressView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.midY
        layer.masksToBounds = true
    }
}
