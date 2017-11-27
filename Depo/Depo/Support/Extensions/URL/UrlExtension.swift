//
//  UrlExtension.swift
//  Depo
//
//  Created by Ryhor on 25.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

extension URL{


  static func lb_openUrl(url:URL){
        let openurl = (url.absoluteString.hasPrefix("http") == true) ? url : URL(string: String(format:"http://\(url.absoluteString)"))
        if (UIApplication.shared.canOpenURL(openurl!)){
            if #available(iOS 10.0, *){
                UIApplication.shared.open(openurl!, options: [:], completionHandler: nil)
            }
            else{
                UIApplication.shared.openURL(openurl!)
            }
        }
    }
}



