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
}

final class SharedFilesCollectionManager {

    private let shareApiService = PrivateShareApiServiceImpl()
    private lazy var datasource = SharedFilesCollectionDataSource()
    lazy var sharedFilesSlider = SharedFilesCollectionSliderView.initFromNib()
    
    private let numberOfDisplayedSharedItems: Int = 5
    
    weak var delegate: SharedFilesCollectionManagerDelegate?
    
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
                        self.datasource.setup(files: newItems, delegate: self)
                        self.sharedFilesSlider.setup(sliderCollectionDelegate: self, collectionDataSource: self.datasource, collectitonDelegate: self.datasource)
                        callBack(.success(()))
                    }
                    
            case .failed(let error):
                callBack(.failed(error))
            }
        }
    }
}

extension SharedFilesCollectionManager: SharedFilesCollectionDataSourceDelegate {
    func cellTouched(withModel: WrapData) {
        delegate?.open(entity: withModel, allEnteties: datasource.files)
    }
}

extension SharedFilesCollectionManager: SharedFilesCollectionSliderDelegate {
    func showAllPressed() {
        delegate?.showAll()
    }
}
