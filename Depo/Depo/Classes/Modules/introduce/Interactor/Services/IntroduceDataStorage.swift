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
            let textKey = "IntroduceString" + String(i)
            model.text = NSLocalizedString(textKey, comment: "")
            self.introModels.append(model)
        }
    }
    
    func getModels()-> [IntroduceModel]{
        return self.introModels
    }
    
    
}
