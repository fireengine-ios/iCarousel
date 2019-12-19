//
//  CarouselPagerDataSource.swift
//  Depo
//
//  Created by ÜNAL ÖZTÜRK on 18.12.2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class CarouselPagerDataSource {
    
    static func getCarouselPageModels() -> [CarouselPageModel] {
        
        //TODO: when BE is ready we are going to fill it with BE provided info.
        let first = CarouselPageModel(text:TextConstants.carouselViewFirstPageText, title: TextConstants.carouselViewFirstPageTitle)
        let second = CarouselPageModel(text:TextConstants.carouselViewSecondPageText, title: TextConstants.carouselViewSecondPageTitle)
        let third = CarouselPageModel(text:TextConstants.carouselViewThirdPageText, title: TextConstants.carouselViewThirdPageTitle)
        return [first,second,third]
        
    }
    
}
