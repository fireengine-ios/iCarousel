//
//  FileProviderExtension.swift
//  LifeboxFileProvider
//
//  Created by Bondar Yaroslav on 3/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import FileProvider
import MobileCoreServices
import MMWormhole

let unknownError = NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo: [:])


final class FileProviderExtension: NSFileProviderExtension {
    
    private let fileManager = FileManager()
    private let fileCoordinator = NSFileCoordinator()
    
    private let passcodeStorage: PasscodeStorage = factory.resolve()
    
    private var isPasscodeOn: Bool {
        return !passcodeStorage.isEmpty
    }
    
    private let wormhole: MMWormhole = MMWormhole(applicationGroupIdentifier: SharedConstants.groupIdentifier, optionalDirectory: SharedConstants.wormholeDirectoryIdentifier)
    
    override init() {
        super.init()
        listenMessageAboutLogout()
    }
    
    // On some devices (Iphone 6 plus 11.2, Iphone 6s plus 11.2), the NSFileProviderEnumerator protocol methods were not called when logging into the application from the background, the signalEnumerator method provokes a call to the protocol methods.
    
    func listenMessageAboutLogout() {
        wormhole.listenForMessage(withIdentifier: SharedConstants.wormholeLogout) { _ in
            NSFileProviderManager.default.signalEnumerator(for: NSFileProviderItemIdentifier.rootContainer, completionHandler: { (error) in })
        }
    }
    
    /// ready
    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
        return try FileStorage.shared.read(for: identifier)
    }
    
    /// apple ready !!!
    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        // resolve the given identifier to a file on disk
        guard let item = try? item(for: identifier) else {
            return nil
        }
        
        // in this implementation, all paths are structured as <base storage directory>/<item identifier>/<item file name>
        let manager = NSFileProviderManager.default
        let perItemDirectory = manager.documentStorageURL.appendingPathComponent(identifier.rawValue, isDirectory: true)
        
        return perItemDirectory.appendingPathComponent(item.filename, isDirectory: false)
    }
    
    /// apple ready !!!
    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        // resolve the given URL to a persistent identifier using a database
        let pathComponents = url.pathComponents
        
        // exploit the fact that the path structure has been defined as
        // <base storage directory>/<item identifier>/<item file name> above
        assert(pathComponents.count > 2)
        
        return NSFileProviderItemIdentifier(pathComponents[pathComponents.count - 2])
    }
    
    /// ready
    override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        
        if isPasscodeOn {
            return
        }
        
        guard let identifier = persistentIdentifierForItem(at: url) else {
            completionHandler(NSFileProviderError(.noSuchItem))
            return
        }

        do {
            let fileProviderItem = try item(for: identifier)
            let placeholderURL = NSFileProviderManager.placeholderURL(for: url)
            
            if fileManager.fileExists(atPath: placeholderURL.relativePath) {
                /// ???
//                completionHandler(unknownError)
                completionHandler(nil)
                return
            }
            
            let placecholderDirectoryUrl = placeholderURL.deletingLastPathComponent()
            var fcError: NSErrorPointer
            
            fileCoordinator.coordinate(writingItemAt: placecholderDirectoryUrl, options: .forMerging, error: fcError) { newURL in
                
                if let error = fcError?.pointee {
                    completionHandler(error)
                } else {
                    do {
                        try fileManager.createDirectory(at: newURL, withIntermediateDirectories: true, attributes: nil)
                        ///fileManager.fileExists(atPath: placecholderDirectoryUrl.relativePath) //???
                        try NSFileProviderManager.writePlaceholder(at: placeholderURL, withMetadata: fileProviderItem)
                        completionHandler(nil)
                    } catch {
                        completionHandler(error)
                    }
                }
            }
        } catch let error {
            completionHandler(error)
        }
    }
    
    override func fetchThumbnails(for itemIdentifiers: [NSFileProviderItemIdentifier], requestedSize size: CGSize, perThumbnailCompletionHandler: @escaping (NSFileProviderItemIdentifier, Data?, Error?) -> Void, completionHandler: @escaping (Error?) -> Void) -> Progress {
        
        let progress = Progress(totalUnitCount: Int64(itemIdentifiers.count))
        
        for identifier in itemIdentifiers {
            
            do {
                let baseItem = try self.item(for: identifier)
                
                guard let item = baseItem as? FileProviderItem, let thumbnailURL = item.thumbnailURL else {
                    perThumbnailCompletionHandler(identifier, nil, unknownError)
                    completionHandler(unknownError)
                    return progress
                }
                
                let downloadTask = URLSession.shared.downloadTask(with: thumbnailURL) { tempURL, response, error in
                    
                    guard !progress.isCancelled else {
                        return
                    }
                    
                    /// or 1
                    var errorOrNil = error
                    var dataOrNil: Data?
                    
                    if let fileURL = tempURL {
                        do {
                            dataOrNil = try Data(contentsOf: fileURL, options: .alwaysMapped)
                        } catch let mappingError {
                            errorOrNil = mappingError
                        }
                    }
                    
                    perThumbnailCompletionHandler(identifier, dataOrNil, errorOrNil)
                    
                    DispatchQueue.main.async {
                        if progress.isFinished {
                            /// Call this completion handler once all thumbnails are complete
                            completionHandler(nil)
                        }
                    }
                    
                    /// or 2
//                    if let error = error {
//                        perThumbnailCompletionHandler(identifier, nil, error)
//                        completionHandler(error)
//                    } else if let locationUrl = locationUrl {
//                        do {
//                            let data = try Data(contentsOf: locationUrl)
//                            perThumbnailCompletionHandler(identifier, data, nil)
//                            
//                            DispatchQueue.main.async {
//                                if progress.isFinished {
//                                    /// Call this completion handler once all thumbnails are complete
//                                    completionHandler(nil)
//                                }
//                            }
//                        } catch {
//                            perThumbnailCompletionHandler(identifier, nil, error)
//                            completionHandler(error)
//                        }
//                    }
                }
                
                // Add the download task's progress as a child to the overall progress.
                progress.addChild(downloadTask.progress, withPendingUnitCount: 1)
                
                // Start the download task.
                downloadTask.resume()
                
            } catch {
                perThumbnailCompletionHandler(identifier, nil, error)
                completionHandler(error)
            }
        }
        
        return progress
    }
    
    /// ready
    override func startProvidingItem(at url: URL, completionHandler: @escaping ((_ error: Error?) -> Void)) {
        
        if fileManager.fileExists(atPath: url.path) {
            completionHandler(nil)
            return
        }
        
        guard 
            let itemIdentifier = persistentIdentifierForItem(at: url),
            let item = try? self.item(for: itemIdentifier) as? FileProviderItem,
            let downloadURL = item?.tempDownloadURL
        else {
            completionHandler(unknownError)
            return
        }
        
        URLSession.shared.downloadTask(with: downloadURL) { locationUrl, response, error in
            if let error = error {
                completionHandler(error)
            } else if let locationUrl = locationUrl {
                do {
                    let data = try Data(contentsOf: locationUrl)
                    try data.write(to: url, options: .atomic)
                    completionHandler(nil)
                } catch {
                    completionHandler(error)
                }
            }
        }.resume()
        
        // Should ensure that the actual file is in the position returned by URLForItemWithIdentifier:, then call the completion handler
        
        /* TODO:
         This is one of the main entry points of the file provider. We need to check whether the file already exists on disk,
         whether we know of a more recent version of the file, and implement a policy for these cases. Pseudocode:
         
         if !fileOnDisk {
             downloadRemoteFile()
             callCompletion(downloadErrorOrNil)
         } else if fileIsCurrent {
             callCompletion(nil)
         } else {
             if localFileHasChanges {
                 // in this case, a version of the file is on disk, but we know of a more recent version
                 // we need to implement a strategy to resolve this conflict
                 moveLocalFileAside()
                 scheduleUploadOfLocalFile()
                 downloadRemoteFile()
                 callCompletion(downloadErrorOrNil)
             } else {
                 downloadRemoteFile()
                 callCompletion(downloadErrorOrNil)
             }
         }
         */
        
        
    }
    
    
    /// apple ready !!!
    override func itemChanged(at url: URL) {
        // Called at some point after the file has changed; the provider may then trigger an upload
        
        /* TODO:
         - mark file at <url> as needing an update in the model
         - if there are existing NSURLSessionTasks uploading this file, cancel them
         - create a fresh background NSURLSessionTask and schedule it to upload the current modifications
         - register the NSURLSessionTask with NSFileProviderManager to provide progress updates
         */
    }
    
    override func stopProvidingItem(at url: URL) {
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        // Care should be taken that the corresponding placeholder file stays behind after the content file has been deleted.
        
        // Called after the last claim to the file has been released. At this point, it is safe for the file provider to remove the content file.
        
        // TODO: look up whether the file has local changes
        let fileHasLocalChanges = false
        
        if !fileHasLocalChanges {
            // remove the existing file to free up space
            do {
                _ = try FileManager.default.removeItem(at: url)
            } catch {
                // Handle error
            }
            
            // write out a placeholder to facilitate future property lookups
            self.providePlaceholder(at: url, completionHandler: { error in
                // TODO: handle any error, do any necessary cleanup
            })
        }
    }
    
    // MARK: - Actions
    
    /* TODO: implement the actions for items here
     each of the actions follows the same pattern:
     - make a note of the change in the local model
     - schedule a server request as a background task to inform the server of the change
     - call the completion block with the modified item in its post-modification state
     */
    
    // MARK: - Enumeration
    
    override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        /// ???
        /// It was added after the screen to share the file, since it entered here with the identifier of the file.
        do {
            let item = try self.item(for: containerItemIdentifier)
            if item.typeIdentifier != (kUTTypeFolder as String) {
                /// ?
                return FileProviderEnumerator(enumeratedItemIdentifier: containerItemIdentifier)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        
        //let maybeEnumerator: NSFileProviderEnumerator? = nil
        
        if (containerItemIdentifier == NSFileProviderItemIdentifier.rootContainer) {
            /// TODO: instantiate an enumerator for the container root
            return FileProviderEnumerator(enumeratedItemIdentifier: containerItemIdentifier)
        } else if (containerItemIdentifier == NSFileProviderItemIdentifier.workingSet) {
//            throw unknownError
            // TODO: instantiate an enumerator for the working set
        } else {
            return FileProviderEnumerator(enumeratedItemIdentifier: containerItemIdentifier)
            // TODO: determine if the item is a directory or a file
            // - for a directory, instantiate an enumerator of its subitems
            // - for a file, instantiate an enumerator that observes changes to the file
        }
        
        return FileProviderEnumerator(enumeratedItemIdentifier: containerItemIdentifier)
        
//        guard let enumerator = maybeEnumerator else {
//            throw NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:])
//        }
//        return enumerator
    }
    
}
