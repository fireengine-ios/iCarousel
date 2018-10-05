//
//  AugmentedRealityFileLoader.swift
//  Depo
//
//  Created by Konstantin on 8/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation


final class AugmentedRealityFileProvider {
    
    typealias FileDownloadingSuccess = (_ localURL: URL) -> Void
    typealias FileDownloadingFail = (_ errorMessage: String?) -> Void
    
    
    func downloadFile(item: WrapData, success: @escaping FileDownloadingSuccess, fail: @escaping FileDownloadingFail) {
        guard let file = FileForDownload(forOriginalURL: item) else {
            fail(nil)
            return
        }
        
        FilesDownloader().getFiles(filesForDownload: [file], response: { localUrls, _ in
            guard let localUrl = localUrls.first else {
                fail(nil)
                return
            }
            
            success(localUrl)
        }) { error in
            fail(error)
        }
    }
    
    func removeLocalFile(at localURL: URL) {
        do {
            try FileManager.default.removeItem(at: localURL)
        } catch {
            print(error.description)
        }
    }
}
