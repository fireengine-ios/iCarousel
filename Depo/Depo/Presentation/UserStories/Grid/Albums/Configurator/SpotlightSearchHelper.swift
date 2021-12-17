//
//  SpotlightManager.swift
//  Lifebox
//
//  Created by Burak Donat on 9.12.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation
import CoreData
import CoreSpotlight
import UIKit

enum SpotlightIndexIdentifiers: String {
    case album = "com.turkcell.spotlightAlbum"
}

@available(iOS 14.0, *)
class SpotlightSearchHelper {

    static let shared = SpotlightSearchHelper()
    private let imageDownloder = ImageDownloder()
    private var thumbnails: [String:UIImage] = [:]
    private let serialQueue = DispatchQueue(label: DispatchQueueLabels.spotlightManagerQueue)

    func indexItemsInStore(with albums: [AlbumItem]) {
        serialQueue.async { [weak self] in
            self?.doIndexing(with: albums)
        }
    }

    func doIndexing(with albums: [AlbumItem] ) {
        let domainIdentifier = SpotlightIndexIdentifiers.album.rawValue
        deindexItem(identifier: domainIdentifier)

        let myGroup = DispatchGroup()
        for album in albums {
            myGroup.enter()
            self.imageDownloder.getImageByTrimming(url: album.preview?.metaData?.mediumUrl) { [weak self] image in
                self?.serialQueue.async {
                    self?.thumbnails.updateValue(image ?? UIImage(), forKey: album.uuid)
                    myGroup.leave()
                }
            }
        }

        myGroup.notify(queue: serialQueue) {
            let album = albums.compactMap { album -> CSSearchableItem? in
                guard let name = album.name else { return nil}
                let attributeSet = CSSearchableItemAttributeSet(contentType: .item)
                attributeSet.displayName = name
                attributeSet.contentDescription = "\(album.allContentCount) \(TextConstants.fileInfoAlbumSizeTitle)"
                attributeSet.keywords = [name]
                attributeSet.thumbnailData = self.thumbnails[album.uuid]?.jpegData(compressionQuality: 0.5)

                let item = CSSearchableItem(uniqueIdentifier: album.uuid,
                                            domainIdentifier: domainIdentifier,
                                            attributeSet: attributeSet)
                item.expirationDate = Date.distantFuture
                return item
            }

            CSSearchableIndex.default().indexSearchableItems(album) { error in
                if let error = error {
                    debugLog("Indexing error: \(error.localizedDescription)")
                } else {
                    debugLog("Search item successfully indexed")
                }
                self.serialQueue.async {
                    self.thumbnails = [:]
                }
            }
        }
    }

    func deindexItem(identifier: String) {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [identifier]) { error in
            if let error = error {
                debugLog("Deindexing error: \(error.localizedDescription)")
            } else {
                debugLog("Search item successfully removed!")
            }
        }
    }
}
