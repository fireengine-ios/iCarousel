//
//  SharedFilesCollectionManager.swift
//  Depo
//
//  Created by Alex Developer on 23.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol SharedFilesCollectionManagerDelegate: class {
    func showAll()
    func open(entity: WrapData, allEnteties: [WrapData])
    func startAsyncOperation()
    func completeAsyncOperation()
}

final class SharedFilesCollectionManager {
    let sharedSliderHeight: CGFloat = 224
    
    private let shareApiService = PrivateShareApiServiceImpl()
    private lazy var datasource = SharedFilesCollectionDataSource()
    let sharedFilesSlider = SharedFilesCollectionSliderView.initFromNib()
    
    private let numberOfDisplayedSharedItems: Int = 5
    
    weak var delegate: SharedFilesCollectionManagerDelegate?
    
    init() {
        self.datasource.delegate = self
        self.sharedFilesSlider.setup(sliderCollectionDelegate: self, collectionDataSource: self.datasource, collectitonDelegate: self.datasource)
    }
    
    func checkSharedWithMe(callBack: @escaping ResponseVoid) {

        shareApiService.getSharedWithMe(size: numberOfDisplayedSharedItems, page: 0, sortBy: .lastModifiedDate, sortOrder: .desc) { [weak self] sharedFilesResult in
            guard let self = self else {
                callBack(.failed(CustomErrors.text("no self instance")))
                return
            }
            switch sharedFilesResult {
            case .success(let filesInfo):
                let newItems = filesInfo.compactMap { WrapData(privateShareFileInfo: $0) }
                guard !newItems.isEmpty else {
                    callBack(.failed(CustomErrors.text("no valid items")))
                    return
                }
                DispatchQueue.main.async {
                    self.datasource.setup(files: newItems)
                    self.sharedFilesSlider.reloadData()
                    callBack(.success(()))
                }
                
            case .failed(let error):
                callBack(.failed(error))
            }
        }
    }
    
    func changeSliderVisability(isHidden: Bool) {
        let height = isHidden ? 0 : sharedSliderHeight
        sharedFilesSlider.frame = CGRect(origin: sharedFilesSlider.frame.origin, size: CGSize(width: sharedFilesSlider.frame.width, height: height))
        sharedFilesSlider.isHidden = isHidden
    }
    
    func reloadData(callBack: @escaping ResponseVoid) {
        checkSharedWithMe(callBack: callBack)
    }
    
    private func createNewUrl(for item: Item, completion: @escaping ValueHandler<URL?>) {
        guard let projectId = item.projectId else {
            completion(nil)
            return
        }
        
        shareApiService.createDownloadUrl(projectId: projectId, uuid: item.uuid) { result in
            switch result {
            case .success(let response):
                completion(response.url)
            case .failed(_):
                completion(nil)
            }
        }
    }
}

extension SharedFilesCollectionManager: SharedFilesCollectionDataSourceDelegate {
    func cellTouched(withModel: WrapData) {
        if withModel.fileType == .audio {
            if withModel.urlToFile == nil || withModel.urlToFile?.isExpired == true {
                delegate?.startAsyncOperation()
                createNewUrl(for: withModel) { [weak self] newUrl in
                    if newUrl != nil {
                        withModel.tmpDownloadUrl = newUrl
                        self?.delegate?.open(entity: withModel, allEnteties: [withModel])
                    }
                    self?.delegate?.completeAsyncOperation()
                }
            } else {
                delegate?.open(entity: withModel, allEnteties: [withModel])
            }
        } else {
            delegate?.open(entity: withModel, allEnteties: datasource.files)
        }
    }
}

extension SharedFilesCollectionManager: SharedFilesCollectionSliderDelegate {
    func showAllPressed() {
        delegate?.showAll()
    }
}
