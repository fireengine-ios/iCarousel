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
    func getGIFStickers(page: Int, size: Int, handler: @escaping (ResponseResult<[SmashStickerResponse]>) -> Void)
    
    func getImageStickers(page: Int, size: Int, handler: @escaping (ResponseResult<[SmashStickerResponse]>) -> Void)
}

final class SmashServiceImpl: BaseRequestService, SmashService {
    
    private let sessionManager: SessionManager
    private let downloader = ImageDownloder()
    
    required init(sessionManager: SessionManager = SessionManager.customDefault) {
        self.sessionManager = sessionManager
    }
    
    
    func getGIFStickers(page: Int, size: Int, handler: @escaping (ResponseResult<[SmashStickerResponse]>) -> Void) {
        
        sessionManager
            .request(RouteRequests.smashAnimation,
                     parameters: ["type" : StickerType.gif.rawValue,
                              "language" : "\(Device.locale)",
                                  "page" : page,
                                  "size" : size],
                                 encoding: URLEncoding.default)
            .customValidate()
            .responseData { response in
                
                switch response.result {
                case .success(let data):
                    
                    print(String(data: data, encoding: .utf8))
                    
                    guard let stickersData = JSON(data: data).array else {
                        return
                    }
                    
                    let stickers = stickersData.compactMap({ SmashStickerResponse(json: $0)})
                    handler(.success(stickers))
                    
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
    func getImageStickers(page: Int, size: Int, handler: @escaping (ResponseResult<[SmashStickerResponse]>) -> Void) {
        
        sessionManager
            .request(RouteRequests.smashAnimation,
                     parameters: ["type" : StickerType.image.rawValue,
                              "language" : "\(Device.locale)",
                                  "page" : page,
                                  "size" : size],
                                 encoding: URLEncoding.default)
            .customValidate()
            .responseData { response in
                
                switch response.result {
                case .success(let data):
                                        
                    guard let stickersData = JSON(data: data).array else {
                        return
                    }
                    
                    let stickers = stickersData.compactMap({ SmashStickerResponse(json: $0)})
                    handler(.success(stickers))
                    
                case .failure(let error):
                    handler(.failed(error))
                }
        }
    }
    
//    func downloadThumbnail(url: URL) {
//        downloader.getImageData(url: url, completeData: <#T##RemoteData##RemoteData##(Data?) -> Void#>)
//    }
//    
//    func downloadSticker(url: URL) {
//        
//    }
}
