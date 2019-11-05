//
//  ShareController.swift
//  LifeboxShared
//
//  Created by Bondar Yaroslav on 3/13/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol ShareController: class {
    func getSharedItems(handler: @escaping ([SharedItemSource]) -> Void)
}
extension ShareController where Self: UIViewController {
    func getSharedItems(handler: @escaping ([SharedItemSource]) -> Void) {
        
        guard
            let inputItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let attachments = inputItem.attachments as? [NSItemProvider]
        else {
            return
        }
        
        /// type constatnts
        let imageType = kUTTypeImage as String
        let pdfType = kUTTypePDF as String
        let dataType = kUTTypeData as String
        let videoTypes = [kUTTypeMovie,
                          kUTTypeVideo,
                          kUTTypeMPEG,
                          kUTTypeMPEG4,
                          kUTTypeAVIMovie,
                          kUTTypeQuickTimeMovie] as [String]
        
        var shareItems: [SharedItemSource] = []
        let group = DispatchGroup()
        
        attachmentsFor: for itemProvider in attachments {
            
            /// IMAGE
            if itemProvider.hasItemConformingToTypeIdentifier(imageType) {
                
                group.enter()
                itemProvider.loadItem(forTypeIdentifier: imageType, options: nil) { (item, error) in
                    if let url = item as? URL {
                        shareItems.append(.url(SharedImageUrl(url: url)))
                    } else if let image = item as? UIImage, let sharedImage = SharedImage(image: image) {
                        shareItems.append(.data(sharedImage))
                    } else {
                        assertionFailure("unknown item: \(item.debugDescription)")
                    }
                    
                    group.leave()
                }
                
                /// DATA 1
            } else if itemProvider.hasItemConformingToTypeIdentifier(pdfType) {
                
                group.enter()
                itemProvider.loadItem(forTypeIdentifier: pdfType, options: nil) { (item, error) in
                    guard let path = item as? URL else {
                        group.leave()
                        return
                    }
                    shareItems.append(.url(SharedFileUrl(url: path)))
                    group.leave()
                }
                
            } else {
                
                /// VIDEO
                for type in videoTypes {
                    if itemProvider.hasItemConformingToTypeIdentifier(type) {
                        
                        group.enter()
                        itemProvider.loadItem(forTypeIdentifier: type, options: nil) { (item, error) in
                            guard let path = item as? URL else {
                                group.leave()
                                return
                            }
                            shareItems.append(.url(SharedVideo(url: path)))
                            group.leave()
                        }
                        
                        /// we found video type. parse next itemProvider
                        continue attachmentsFor
                    }
                }
                
                /// if not any type try to take data
                /// DATA 2
                if itemProvider.hasItemConformingToTypeIdentifier(dataType) {
                    
                    group.enter()
                    itemProvider.loadItem(forTypeIdentifier: dataType, options: nil) { (item, error) in
                        guard let path = item as? URL else {
                            group.leave()
                            return
                        }
                        shareItems.append(.url(SharedFileUrl(url: path)))
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            handler(shareItems)
        }
    }
}
