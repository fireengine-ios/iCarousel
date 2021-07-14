//
//  IntroduceDataStorage.swift
//  Depo
//
//  Created by Oleg on 12.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class IntroduceDataStorage: NSObject {
    var introModels: [IntroduceModel] = []
    
    override init() {
        for i in 1...1 {
            let model = IntroduceModel()
            let imageName = "IntroduceImage" + String(i)
            model.imageName = imageName
            let textKey1 = TextConstants.welcome1Info
            let textSubKey1 = TextConstants.welcome1SubInfo
            let text = NSLocalizedString(textKey1, comment: "") + "\n\n" + NSLocalizedString(textSubKey1, comment: "")
            
            let string = text as NSString
            let range = string.range(of: "\n\n")
            let attributedText = NSMutableAttributedString(string: text)
            
            var font1Size: CGFloat = 18
            var font2Size: CGFloat = 10
            if (Device.isIpad) {
                font1Size = 37
                font2Size = 25
            }
            
            let font1 = UIFont.TurkcellSaturaBolFont(size: font1Size)
            let font2 = UIFont.TurkcellSaturaBolFont(size: font2Size)
            let r1 = NSRange(location: 0, length: range.location)
            let r2 = NSRange(location: range.location + range.length, length: string.length - range.location - range.length)
            attributedText.addAttribute(.font, value: font1, range: r1)
            attributedText.addAttribute(.font, value: font2, range: r2)
            model.text = attributedText
            
            introModels.append(model)
        }
    }
    
    func getModels() -> [IntroduceModel] {
        return introModels
    }
    
    
}
