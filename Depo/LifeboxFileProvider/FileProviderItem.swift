//
//  FileProviderItem.swift
//  LifeboxFileProvider
//
//  Created by Bondar Yaroslav on 3/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import FileProvider
import SwiftyJSON
import MobileCoreServices

final class FileProviderItem: NSObject, NSFileProviderItem, Map {

    /// NSFileProviderItem
    var capabilities = NSFileProviderItemCapabilities.allowsReading
    
    let itemIdentifier: NSFileProviderItemIdentifier
    let parentItemIdentifier: NSFileProviderItemIdentifier
    let filename: String
    let typeIdentifier: String
    
//    @NSCopying optional public var documentSize: NSNumber? { get }
//    @NSCopying optional public var childItemCount: NSNumber? { get }
//    optional public var creationDate: Date? { get }
//    optional public var contentModificationDate: Date? { get }
    
    
    let bytes: Int64
    let isFolder: Bool
    let childCount: Int
    let tempDownloadURL: String
    let createdDate: Int64
    var thumbnailURL: String?
    
    
    init(itemIdentifier: String,
         parentItemIdentifier: String,
         filename: String,
         typeIdentifier: String,
         
         bytes: Int64,
         isFolder: Bool,
         childCount: Int,
         tempDownloadURL: String,
         createdDate: Int64,
         thumbnailURL: String?)
    {
        self.itemIdentifier = NSFileProviderItemIdentifier(itemIdentifier)
        self.parentItemIdentifier = NSFileProviderItemIdentifier(parentItemIdentifier)
        self.filename = filename
        self.typeIdentifier = typeIdentifier
        
        self.bytes = bytes
        self.isFolder = isFolder
        self.childCount = childCount
        self.tempDownloadURL = tempDownloadURL
        self.createdDate = createdDate
        self.thumbnailURL = thumbnailURL
        super.init()
    }
    
    /// TEMP
    override convenience init() {
        self.init(itemIdentifier: "", parentItemIdentifier: "", filename: "", typeIdentifier: "", bytes: 0, isFolder: false, childCount: 0, tempDownloadURL: "", createdDate: 0, thumbnailURL: nil)
    }
}

/// : JsonMap
extension FileProviderItem {
    convenience init?(json: JSON) {
        
        let uuid = json["uuid"].string ?? ""
        let name = json["name"].string ?? ""
        
        let isFolder = json["folder"].bool ?? false
        let childCount = json["childCount"].int ?? 0
        let bytes = json["bytes"].int64 ?? 0
        let createdDate = json["createdDate"].int64 ?? 0
        let tempDownloadURL = json["tempDownloadURL"].string ?? ""
        
        let thumbnailURL = json["metadata"]["Thumbnail-Medium"].string
        
        let typeIdentifier = name.utType ?? "public.folder"
        
        let myParentItemIdentifier = "NSFileProviderRootContainerItemIdentifier"
        
        self.init(itemIdentifier: uuid,
                  parentItemIdentifier: myParentItemIdentifier,
                  filename: name,
                  typeIdentifier: typeIdentifier,
                  bytes: bytes,
                  isFolder: isFolder,
                  childCount: childCount,
                  tempDownloadURL: tempDownloadURL,
                  createdDate: createdDate,
                  thumbnailURL: thumbnailURL)
    }
}

/// : DataMapArray
extension FileProviderItem {
    static func array(from data: Data) -> [FileProviderItem] {
        let jsonArray = JSON(data: data)["fileList"]
        return jsonArray.array?.flatMap { json in
            self.init(json: json)
        } ?? []
    }
}


private extension String {
    var utType: String? {
        return UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (self as NSString).pathExtension as CFString, nil)?.takeRetainedValue() as String?
    }
}
