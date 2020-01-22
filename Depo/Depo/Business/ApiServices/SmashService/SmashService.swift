//
//  SmashService.swift
//  Depo
//
//  Created by Maxim Soldatov on 1/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Alamofire
import SwiftyJSON

protocol SmashService: class {
    
    func getStickers(type: StickerType, page: Int, size: Int, handler: @escaping (ResponseResult<(stickers: [SmashStickerResponse], type: StickerType)>) -> Void)
}

final class SmashServiceImpl: BaseRequestService, SmashService {

    private let sessionManager: SessionManager
    
    required init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }
    
    func getStickers(type: StickerType, page: Int, size: Int, handler: @escaping (ResponseResult<(stickers: [SmashStickerResponse], type: StickerType)>) -> Void) {
        
        sessionManager
            .request(RouteRequests.smashAnimation,
                     parameters: ["type" : type.rawValue,
                              "language" : Device.locale,
                                  "page" : page,
                                  "size" : size])
            .customValidate()
            .responseData { response in
                
                switch response.result {
                case .success(let data):

                    guard let stickersData = JSON(data: data).array else {
                        return
                    }
                    
                    let stickers = stickersData.compactMap({ SmashStickerResponse(json: $0)})
                    handler(.success( (stickers, type) ) )
                    
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
}
