//
//  FileProviderEnumerator.swift
//  LifeboxFileProvider
//
//  Created by Bondar Yaroslav on 3/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import FileProvider

class FileProviderEnumerator: NSObject {
    
    var enumeratedItemIdentifier: NSFileProviderItemIdentifier
    
    init(enumeratedItemIdentifier: NSFileProviderItemIdentifier) {
        self.enumeratedItemIdentifier = enumeratedItemIdentifier
        super.init()
    }
    
    let fileService = FileService()
}

extension FileProviderEnumerator: NSFileProviderEnumerator {

    func invalidate() {
        // TODO: perform invalidation of server connection if necessary
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        
//        let isPasscodeOn = true
//        if isPasscodeOn {
//            let error = NSError(domain: NSFileProviderErrorDomain,
//                                code: NSFileProviderError.notAuthenticated.rawValue,
//                                userInfo: [NSLocalizedDescriptionKey: "passcode"])
//            observer.finishEnumeratingWithError(error)
//        }
        
        if enumeratedItemIdentifier.rawValue == "NSFileProviderRootContainerItemIdentifier" {
            ///folderUUID = _enumeratedItemIdentifier
        }
        
        fileService.getFiles(folderUUID: "", page: 0) { (result) in
            switch result {
            case .success(_):
                break
            case .failed(let error):
                print(error.localizedDescription)
            }
        }
        
        /// get files
        observer.didEnumerate([])
        observer.finishEnumerating(upTo: nil)
        //observer.finishEnumeratingWithError(error)
        
        /// OLD
        //    Service *service = [[Service alloc] init];
        //    [service requestForFiles:self.folderUUID pageNum:self.page completion:^(NSMutableArray *fileList, NSError *error) {
        //
        //
        //        if (!error) {
        //            if (fileList.count == 0) {
        ////              [observer didEnumerateItems:self.itemList];
        //                [observer finishEnumeratingUpToPage:nil];
        //                self.page = 0;
        //            } else {
        //                [self.itemList addObjectsFromArray:fileList];
        //                [observer didEnumerateItems:fileList];
        //                self.page++;
        //                [observer finishEnumeratingUpToPage:page];
        //            }
        //        } else {
        //            [observer finishEnumeratingWithError:error];
        //        }
        //    }];

        
        
        /* TODO:
         - inspect the page to determine whether this is an initial or a follow-up request
         
         If this is an enumerator for a directory, the root container or all directories:
         - perform a server request to fetch directory contents
         If this is an enumerator for the active set:
         - perform a server request to update your local database
         - fetch the active set from your local database
         
         - inform the observer about the items returned by the server (possibly multiple times)
         - inform the observer that you are finished with this page
         */
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
