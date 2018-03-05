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
    
    let childItemCount: NSNumber?
    let documentSize: NSNumber?
    let createdDate: Date?
    let contentModificationDate: Date?
    
    let isFolder: Bool
    let tempDownloadURL: URL?
    let thumbnailURL: URL?
    
    
    init(itemIdentifier: String,
         parentItemIdentifier: String,
         filename: String,
         typeIdentifier: String,
         
         childItemCount: NSNumber?,
         documentSize: NSNumber?,
         createdDate: Date?,
         contentModificationDate: Date?,
         
         isFolder: Bool,
         tempDownloadURL: URL?,
         thumbnailURL: URL?)
    {
        self.itemIdentifier = NSFileProviderItemIdentifier(itemIdentifier)
        self.parentItemIdentifier = NSFileProviderItemIdentifier(parentItemIdentifier)
        self.filename = filename
        self.typeIdentifier = typeIdentifier
        
        self.childItemCount = childItemCount
        self.documentSize = documentSize
        self.createdDate = createdDate
        self.contentModificationDate = contentModificationDate
        
        self.isFolder = isFolder
        self.tempDownloadURL = tempDownloadURL
        self.thumbnailURL = thumbnailURL
        super.init()
    }
    
    /// TEMP
    override convenience init() {
        self.init(itemIdentifier: "", parentItemIdentifier: "", filename: "", typeIdentifier: "", childItemCount: nil, documentSize: nil, createdDate: nil, contentModificationDate: nil, isFolder: false, tempDownloadURL: nil, thumbnailURL: nil)
    }
}

/// : JsonMap
extension FileProviderItem {
    convenience init?(json: JSON) {
        
        let itemIdentifier = json["uuid"].string ?? UUID().uuidString
        let myParentItemIdentifier = NSFileProviderItemIdentifier.rootContainer.rawValue
        let filename = json["name"].string ?? ""
        let typeIdentifier = filename.utTypeFromExtension ?? kUTTypeFolder as String
        
        let childItemCount = json["childCount"].number
        let documentSize = json["bytes"].number ?? 0
        let createdDate = json["createdDate"].date
        let contentModificationDate = json["lastModifiedDate"].date
        
        let isFolder = json["folder"].bool ?? false
        let tempDownloadURL = json["tempDownloadURL"].url
        let thumbnailURL = json["metadata"]["Thumbnail-Medium"].url
        
        self.init(itemIdentifier: itemIdentifier,
                  parentItemIdentifier: myParentItemIdentifier,
                  filename: filename,
                  typeIdentifier: typeIdentifier,
                  childItemCount: childItemCount,
                  documentSize: documentSize,
                  createdDate: createdDate,
                  contentModificationDate: contentModificationDate,
                  isFolder: isFolder,
                  tempDownloadURL: tempDownloadURL,
                  thumbnailURL: thumbnailURL)
        
//        if isFolder {
//            capabilities = [.allowsAddingSubItems, .allowsReading]
//        } else {
//            capabilities = [.allowsReparenting, .allowsReading]
//        }
    }
}

extension FileProviderItem: NSCoding {
    func encode(with aCoder: NSCoder) {
//        aCoder.encode(capabilities, forKey: "capabilities")
        aCoder.encode(itemIdentifier, forKey: "itemIdentifier")
        aCoder.encode(parentItemIdentifier, forKey: "parentItemIdentifier")
        aCoder.encode(filename, forKey: "filename")
        aCoder.encode(typeIdentifier, forKey: "typeIdentifier")
        
        aCoder.encode(childItemCount, forKey: "childItemCount")
        aCoder.encode(documentSize, forKey: "documentSize")
        aCoder.encode(createdDate, forKey: "createdDate")
        aCoder.encode(contentModificationDate, forKey: "contentModificationDate")
        
        aCoder.encode(isFolder, forKey: "isFolder")
        aCoder.encode(tempDownloadURL, forKey: "tempDownloadURL")
        aCoder.encode(thumbnailURL, forKey: "thumbnailURL")
    }
    
    convenience init?(coder aDecoder: NSCoder) {
//        aDecoder.decodeObject(forKey: "capabilities")
        
        guard
            let itemIdentifier = aDecoder.decodeObject(forKey: "itemIdentifier") as? String,
            let parentItemIdentifier = aDecoder.decodeObject(forKey: "parentItemIdentifier") as? String,
            let filename = aDecoder.decodeObject(forKey: "filename") as? String,
            let typeIdentifier = aDecoder.decodeObject(forKey: "typeIdentifier") as? String
        else {
            return nil
        }
        
        let childItemCount = aDecoder.decodeObject(forKey: "childItemCount") as? NSNumber
        let documentSize = aDecoder.decodeObject(forKey: "documentSize") as? NSNumber
        let createdDate = aDecoder.decodeObject(forKey: "createdDate") as? Date
        let contentModificationDate = aDecoder.decodeObject(forKey: "contentModificationDate") as? Date
        
        let isFolder = aDecoder.decodeBool(forKey: "isFolder")
        let tempDownloadURL = aDecoder.decodeObject(forKey: "tempDownloadURL") as? URL
        let thumbnailURL = aDecoder.decodeObject(forKey: "thumbnailURL") as? URL

        
        self.init(itemIdentifier: itemIdentifier, parentItemIdentifier: parentItemIdentifier, filename: filename, typeIdentifier: typeIdentifier, childItemCount: childItemCount, documentSize: documentSize, createdDate: createdDate, contentModificationDate: contentModificationDate, isFolder: isFolder, tempDownloadURL: tempDownloadURL, thumbnailURL: thumbnailURL)
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
    var utTypeFromExtension: String? {
        let pathExtension = (self as NSString).pathExtension
        if pathExtension.isEmpty {
            return nil
        }
        
        let utType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue() as String?
        
        if utType?.hasPrefix("dyn.") == true {
            return "public.data"
        }
        return utType
    }
}

