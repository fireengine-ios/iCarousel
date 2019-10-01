//
//  FileProviderEnumerator.swift
//  LifeboxFileProvider
//
//  Created by Bondar Yaroslav on 3/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import FileProvider

class FileProviderEnumerator: NSObject {
    
    private let enumeratedItemIdentifier: NSFileProviderItemIdentifier
    
    init(enumeratedItemIdentifier: NSFileProviderItemIdentifier) {
        self.enumeratedItemIdentifier = enumeratedItemIdentifier
        super.init()
    }
    
    private let fileService = FileService()
    private var page = 0
    
    private let passcodeStorage: PasscodeStorage = factory.resolve()
    private let tokenStorage: TokenStorage = factory.resolve()

    private var isPasscodeOn: Bool {
        return !passcodeStorage.isEmpty
    }
}

extension FileProviderEnumerator: NSFileProviderEnumerator {

    func invalidate() {
        // TODO: perform invalidation of server connection if necessary
    }

    
    /* Apple TODO:
     - inspect the page to determine whether this is an initial or a follow-up request
     
     If this is an enumerator for a directory, the root container or all directories:
     - perform a server request to fetch directory contents
     If this is an enumerator for the active set:
     - perform a server request to update your local database
     - fetch the active set from your local database
     
     - inform the observer about the items returned by the server (possibly multiple times)
     - inform the observer that you are finished with this page
     */
    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        
        if isPasscodeOn {
            let error = NSError(domain: NSFileProviderErrorDomain,
                                code: NSFileProviderError.notAuthenticated.rawValue,
                                userInfo: [NSLocalizedDescriptionKey: ErrorIdentificators.passcode])
            observer.finishEnumeratingWithError(error)
        }
        
        let folderUUID: String
        if enumeratedItemIdentifier.rawValue != NSFileProviderItemIdentifier.rootContainer.rawValue {
            folderUUID = enumeratedItemIdentifier.rawValue
        } else {
            folderUUID = ""
        }
        
        if tokenStorage.accessToken == nil {
            let authenticationError = NSError(domain: NSFileProviderErrorDomain,
                                              code: NSFileProviderError.notAuthenticated.rawValue,
                                              userInfo: [NSLocalizedDescriptionKey: ErrorIdentificators.authentication])
            observer.finishEnumeratingWithError(authenticationError)
            return
        }
        
        fileService.getFiles(folderUUID: folderUUID, page: self.page) { result in
            switch result {
            case .success( let newItems):
                if newItems.isEmpty {
                    observer.finishEnumerating(upTo: nil)
                    self.page = 0
                } else {                    
                    
                    for item in newItems {
                        FileStorage.shared.write(item)
                    }
                    
                    observer.didEnumerate(newItems)
                    self.page += 1
                    
                    if let data = "\(self.page)".data(using: .utf8) {
                        let providerPage = NSFileProviderPage(data)
                        observer.finishEnumerating(upTo: providerPage)
                    } else {
                        observer.finishEnumerating(upTo: nil)
                    }
                }
                break
            case .failed(let error):
                if error.notAuthorized {
                    let authenticationError = NSError(domain: NSFileProviderErrorDomain,
                                                      code: NSFileProviderError.notAuthenticated.rawValue,
                                                      userInfo: [NSLocalizedDescriptionKey: ErrorIdentificators.authentication])
                    observer.finishEnumeratingWithError(authenticationError)
                } else {
                    observer.finishEnumeratingWithError(error)
                }
            }
        }
    }
    
    /// not used
    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
        /* TODO:
         - query the server for updates since the passed-in sync anchor
         
         If this is an enumerator for the active set:
         - note the changes in your local database
         
         - inform the observer about item deletions and updates (modifications + insertions)
         - inform the observer when you have finished enumerating up to a subsequent sync anchor
         */
    }

}
