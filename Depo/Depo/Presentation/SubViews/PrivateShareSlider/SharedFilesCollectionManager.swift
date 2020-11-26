//
//  SharedFilesCollectionManager.swift
//  Depo
//
//  Created by Alex Developer on 23.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol SharedFilesCollectionManagerDelegate: class {
//    func refreshData(refresher: UIRefreshControl)
    func showAll()
    func open(entity: WrapData, allEnteties: [WrapData])
}

final class SharedFilesCollectionManager {

    private let shareApiService = PrivateShareApiServiceImpl()
    private lazy var datasource = SharedFilesCollectionDataSource()
    lazy var sharedFilesSlider = SharedFilesCollectionSliderView.initFromNib()
    
    private let numberOfDisplayedSharedItems: Int = 5
    
    weak var delegate: SharedFilesCollectionManagerDelegate?
    
    private(set) lazy var myFilesLabel: UILabel = {
        let tempoLabel = UILabel()
        tempoLabel.font = .TurkcellSaturaMedFont(size: 18)
        tempoLabel.text = TextConstants.privateShareAllFilesMyFiles
//        tempoLabel.adjustsFontSizeToFitWidth = true
        return tempoLabel
    }()
    
//    let stackView: UIStackView = {
//        let tempoStackView = UIStackView()
//        tempoStackView.axis = .vertical
////        tempoStackView.alignment = .fill
//        return tempoStackView
//    }()
    
    init() {
//        sharedFilesSlider.translatesAutoresizingMaskIntoConstraints = false
//        stackView.addArrangedSubview(sharedFilesSlider)
//        check for private share data source if  available - add and also add label
        checkSharedWithMe()
    }
    
    private func checkSharedWithMe() {

        shareApiService.getSharedWithMe(size: numberOfDisplayedSharedItems, page: 0, sortBy: .lastModifiedDate, sortOrder: .desc) { [weak self] sharedFilesResult in
            guard let self = self else {
                return
            }
            switch sharedFilesResult {
                case .success(let filesInfo):
                    
                    let newItems = filesInfo.compactMap { WrapData(privateShareFileInfo: $0) }
                    guard !newItems.isEmpty else {
                        return
                    }
                    DispatchQueue.main.async {
//
//
//                        self.stackView.addArrangedSubview(self.sharedFilesSlider)//первый или второй?
                        self.datasource.setup(files: newItems, delegate: self)
                        self.sharedFilesSlider.setup(sliderCollectionDelegate: self, collectionDataSource: self.datasource, collectitonDelegate: self.datasource)
                        self.sharedFilesSlider.layoutSubviews()
                        self.sharedFilesSlider.superview?.layoutSubviews()
////                        self.stackView.layoutIfNeeded()
                        
//                        //тут добавть лейбл
                    }
                    
            case .failed(_):
                break
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
