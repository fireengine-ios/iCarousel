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
//    func openAutoSyncSettings()
//    func openViewTypeMenu(sender: UIButton)
//    func openUploadPhotos()
    func showAll()
    func open(entity: WrapData, allEnteties: [WrapData])
}

final class SharedFilesCollectionManager {

    private let cardsContainerView = CardsContainerView()
    private let shareApiService = PrivateShareApiServiceImpl()
    private lazy var datasource = SharedFilesCollectionDataSource()
    private lazy var sharedFilesSlider = SharedFilesCollectionSliderView.initFromNib()
    
    private let numberOfDisplayedSharedItems: Int = 5
    
    weak var delegate: SharedFilesCollectionManagerDelegate?
    
    private(set) lazy var myFilesLabel: UILabel = {
        let tempoLabel = UILabel()
        tempoLabel.font = .TurkcellSaturaMedFont(size: 18)
        tempoLabel.text = TextConstants.privateShareAllFilesMyFiles
//        tempoLabel.adjustsFontSizeToFitWidth = true
        return tempoLabel
    }()
    
    let stackView: UIStackView = {
        let tempoStackView = UIStackView()
        tempoStackView.axis = .vertical
//        tempoStackView.alignment = .fill
        return tempoStackView
    }()
    
    init() {
        stackView.addArrangedSubview(cardsContainerView)
        //check for private share data source if  available - add and also add label
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
                        
                        self.datasource.setup(files: newItems, delegate: self)
                        self.stackView.addArrangedSubview(self.sharedFilesSlider)//первый или второй?
//                        self.stackView.layoutIfNeeded()
                        self.sharedFilesSlider.setup(sliderCollectionDelegate: self, collectionDataSource: self.datasource, collectitonDelegate: self.datasource)
                        //тут добавть лейбл
                    }
                    
            case .failed(_):
                break
            }
        }
    }
    
////    private func setupShowOnlySyncItemsCheckBox() {
////        let checkBox = showOnlySyncItemsCheckBox
////        checkBox.delegate = self
////        collectionView.addSubview(checkBox)
////
////        checkBox.translatesAutoresizingMaskIntoConstraints = false
////        collectionView.translatesAutoresizingMaskIntoConstraints = false
////
////        let height = scrolliblePopUpView.frame.height + BaseFilesGreedViewController.sliderH
////        var constraintsArray = [NSLayoutConstraint]()
////        constraintsArray.append(NSLayoutConstraint(item: checkBox, attribute: .top, relatedBy: .equal, toItem: scrolliblePopUpView, attribute: .bottom, multiplier: 1, constant: height))
////        constraintsArray.append(NSLayoutConstraint(item: checkBox, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
////        constraintsArray.append(NSLayoutConstraint(item: checkBox, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
////        constraintsArray.append(NSLayoutConstraint(item: checkBox, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: showOnlySyncItemsCheckBoxHeight))
////
////        NSLayoutConstraint.activate(constraintsArray)
////    }
}

extension SharedFilesCollectionManager: AllFilesSectionSliderMediatorProtocol {
    
    var cardProtocolSupportedView: CardsContainerView {
        return cardsContainerView
    }
    
    var containerView: UIView {
        return stackView
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
