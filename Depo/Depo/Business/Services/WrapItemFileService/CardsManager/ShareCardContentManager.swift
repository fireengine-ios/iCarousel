//
//  ShareCardContentManager.swift
//  Depo
//
//  Created by Maxim Soldatov on 8/14/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

protocol ShareCardContentManagerDelegate: class {
    func shareOperationStarted()
    func shareOperationFinished()
}

final class ShareCardContentManager {
    
    private lazy var fileService = WrapItemFileService()
    private let router = RouterVC()
    weak private var delegate: ShareCardContentManagerDelegate?
    
    init(delegate: ShareCardContentManagerDelegate) {
        self.delegate = delegate
    }
    
    func presentSharingMenu(item: BaseDataSourceItem, type: ShareType) {
        
        let controler = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controler.view.tintColor = ColorConstants.darkBlueColor
        
        if type.isOrigin {
            
            let smallAction = UIAlertAction(title: TextConstants.actionSheetShareSmallSize, style: .default) { [weak self] _ in
                self?.sync(items: [item], handler: {
                    self?.shareSmallSize(item: item)
                }, fail: { errorResponse in
                    UIApplication.showErrorAlert(message: errorResponse.description)
                })
            }
            controler.addAction(smallAction)
            
            let originalAction = UIAlertAction(title: TextConstants.actionSheetShareOriginalSize, style: .default) { [weak self] _ in
                self?.sync(items: [item], handler: {
                    self?.shareOrignalSize(item: item)
                }, fail: { errorResponse in
                    UIApplication.showErrorAlert(message: errorResponse.description)
                })
            }
            controler.addAction(originalAction)
            
            let shareViaLinkAction = UIAlertAction(title: TextConstants.actionSheetShareShareViaLink, style: .default) { [weak self] _ in
                self?.shareViaLink(item: item)
            }
            controler.addAction(shareViaLinkAction)
        } else {
            
            let shareViaLinkAction = UIAlertAction(title: TextConstants.actionSheetShareShareViaLink, style: .default) { [weak self] _ in
                self?.shareViaLink(item: item)
            }
            controler.addAction(shareViaLinkAction)
        }
        
        let cancelAction = UIAlertAction(title: TextConstants.actionSheetShareCancel, style: .cancel, handler: nil)
        controler.addAction(cancelAction)
        router.presentViewController(controller: controler)
    }
    
    private func shareViaLink(item: BaseDataSourceItem) {
        
        delegate?.shareOperationStarted()
        fileService.share(sharedFiles: [item], success: { [weak self] url in
            
                DispatchQueue.main.async {
                    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    self?.delegate?.shareOperationFinished()
                    self?.router.presentViewController(controller: activityVC)
                }
            }, fail: { [weak self] errorMessage in
                self?.delegate?.shareOperationFinished()
                UIApplication.showErrorAlert(message: errorMessage.description)
        })
    }
    
    private func shareSmallSize(item: BaseDataSourceItem) {
        guard let item = item as? WrapData, let file = FileForDownload(forMediumURL: item) else {
            assertionFailure()
            return
        }
        shareFiles(filesForDownload: [file], sourceRect: nil, shareType: .smallSize)
    }
    
    private func shareOrignalSize(item: BaseDataSourceItem) {
        guard let item = item as? WrapData, let file = FileForDownload(forMediumURL: item) else {
            assertionFailure()
            return
        }
        shareFiles(filesForDownload: [file], sourceRect: nil, shareType: .originalSize)
    }
    
    private func shareFiles(filesForDownload: [FileForDownload], sourceRect: CGRect?, shareType: NetmeraEventValues.ShareMethodType) {
        let downloader = FilesDownloader()
        delegate?.shareOperationStarted()
        downloader.getFiles(filesForDownload: filesForDownload, response: { [weak self] fileURLs, directoryURL in
            
                DispatchQueue.main.async {
                    self?.delegate?.shareOperationFinished()
                    let activityVC = UIActivityViewController(activityItems: fileURLs, applicationActivities: nil)
                
                    activityVC.completionWithItemsHandler = {  _, _, _, _ in
                        do {
                            try FileManager.default.removeItem(at: directoryURL)
                        } catch {
                            assertionFailure()
                        }
                    }
                    self?.router.presentViewController(controller: activityVC)
                }
            }, fail: { [weak self] errorMessage in
                self?.delegate?.shareOperationFinished()
                UIApplication.showErrorAlert(message: errorMessage.description)
        })
    }
    
    private func sync(items: [BaseDataSourceItem], handler: @escaping VoidHandler, fail: FailResponse?) {
    
        guard let items = items as? [WrapData] else {
            assertionFailure()
            return
        }
        
        let successClosure = {
            DispatchQueue.main.async {
                handler()
            }
        }
        
        let failClosure: FailResponse = { errorResponse in
            DispatchQueue.main.async {
                fail?(errorResponse)
            }
        }
        
        fileService.syncItemsIfNeeded(items, success: successClosure, fail: failClosure, syncOperations: { _ in})
    }
}
