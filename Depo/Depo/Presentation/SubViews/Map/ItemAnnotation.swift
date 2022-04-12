//
//  ItemAnnotation.swift
//  Depo
//
//  Created by Hady on 11/11/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import MapKit

class ItemAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate = kCLLocationCoordinate2DInvalid

    var item: WrapData?
}
