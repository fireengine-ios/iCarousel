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
    
    override init(){
        for i in 1...1{
            let model = IntroduceModel()
            let imageName = "IntroduceImage" + String(i)
            model.imageName = imageName
            //let textKey = "IntroduceString" + String(i)
            let textKey = "Yaşa, Biriktir, Hatırla\n\nFotoğraflarını, videolarını ve tüm dosylarını lifebox'ta biriktir, istediğin yerde istediğin zamanda aç ve hatırla"
            let text = NSLocalizedString(textKey, comment: "")
            
            let string = text as NSString
            let range = string.range(of: "\n\n")
            let attributedText = NSMutableAttributedString(string: text)
            let font1 = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 18)
            let font2 = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 10)
            let r1 = NSRange(location: 0, length: range.location)
            let r2 = NSRange(location: range.location + range.length, length: string.length - range.location - range.length)
            attributedText.addAttribute(NSFontAttributeName, value: font1!, range: r1)
            attributedText.addAttribute(NSFontAttributeName, value: font2!, range: r2)
            model.text = attributedText
            
            introModels.append(model)
        }
    }
    
    func getModels()-> [IntroduceModel]{
        return introModels
    }
    
    
}
