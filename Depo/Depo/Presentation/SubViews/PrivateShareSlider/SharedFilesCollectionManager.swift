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
}

final class SharedFilesCollectionManager {

    private let datasource = SharedFilesCollectionDataSource()
    private let cardsContainerView = CardsContainerView()
    private let shareApiService = PrivateShareApiServiceImpl()
    
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
        
    }
    
//    private weak var contentSliderTopY: NSLayoutConstraint?
//    private weak var contentSliderH: NSLayoutConstraint?
//    private var refresherY: CGFloat = 0
//    private let showOnlySyncItemsCheckBoxHeight: CGFloat = 44
//
//    private let refresher = UIRefreshControl()
//
//    private let contentSlider: LBAlbumLikePreviewSliderViewController = {
//        let sliderModuleConfigurator = LBAlbumLikePreviewSliderModuleInitializer()
//        let sliderPresenter = LBAlbumLikePreviewSliderPresenter()
//        sliderModuleConfigurator.initialise(inputPresenter: sliderPresenter)
//        return sliderModuleConfigurator.lbAlbumLikeSliderVC
//    }()
//
//
////    private let showOnlySyncItemsCheckBox = CheckBoxView.initFromNib()
//    private let showAllButton: UIButton = {
//        let button = UIButton(type: .custom)
//
//        button.titleLabel?.text = "I SEE YOU"
//        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
//
//        button.setImage(UIImage(named: "people"), for: .normal)
//
//        return button
//    }()
//    private let emptyDataView = EmptyDataView.initFromNib()
//
//    private weak var collectionView: UICollectionView!
//    private weak var delegate: PhotoVideoCollectionViewManagerDelegate?
//    let collectionViewLayout = PhotoVideoCollectionViewLayout()
//
//    var selectedIndexes: [IndexPath] {
//        return collectionView.indexPathsForSelectedItems ?? []
//    }
//
////    var viewType: GalleryViewType {
////        get { showOnlySyncItemsCheckBox.type }
////        set { showOnlySyncItemsCheckBox.type = newValue }
////    }
//
//    init(collectionView: UICollectionView, delegate: PhotoVideoCollectionViewManagerDelegate) {
//        self.collectionView = collectionView
//        self.delegate = delegate
//    }
//
//    deinit {
//        CardsManager.default.removeViewForNotification(view: scrolliblePopUpView)
//    }
//
//    private func updateRefresher() {
//        guard let refresherView = refresher.subviews.first else {
//            return
//        }
//        refresherView.center = CGPoint(x: refresherView.center.x, y: refresherY)
//    }
//
//    @objc private func refreshData() {
//        delegate?.refreshData(refresher: refresher)
//        refresher.endRefreshing()
//    }
//
//    func reloadAlbumsSlider() {
//        contentSlider.reloadAllData()
//    }
//
//    func setup() {
//        setupCollectionView()
//        setupPullToRefresh()
//
//        setupViewForPopUp()
//
//        /// call only after setupViewForPopUp()
////        setupShowOnlySyncItemsCheckBox()
//
//        setupSlider()
//    }
//
//    func setScrolliblePopUpView(isActive: Bool) {
//        scrolliblePopUpView.isActive = isActive
//        if isActive {
//            CardsManager.default.updateAllProgressesInCardsForView(view: scrolliblePopUpView)
//        }
//    }
//
//    func deselectAll() {
//        selectedIndexes.forEach { indexPath in
//            collectionView.deselectItem(at: indexPath, animated: false)
//        }
//    }
//
//    func showEmptyDataViewIfNeeded(isShow: Bool) {
//        guard isShow else {
//            emptyDataView.removeFromSuperview()
//            return
//        }
//
////        emptyDataView.configure(viewType: showOnlySyncItemsCheckBox.type)
////        emptyDataView.delegate = self
//
//        guard emptyDataView.superview == nil else {
//            return
//        }
//
//        collectionView.addSubview(emptyDataView)
//
//        emptyDataView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//
//        var constraintsArray = [NSLayoutConstraint]()
//        constraintsArray.append(NSLayoutConstraint(item: emptyDataView, attribute: .centerY, relatedBy: .equal, toItem: collectionView, attribute: .centerY, multiplier: 1, constant: -showOnlySyncItemsCheckBoxHeight))
//        constraintsArray.append(NSLayoutConstraint(item: emptyDataView, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
//        constraintsArray.append(NSLayoutConstraint(item: emptyDataView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
//        NSLayoutConstraint.activate(constraintsArray)
//    }
//
//    private func setupCollectionView() {
//        collectionView.collectionViewLayout = collectionViewLayout
//        collectionView.allowsMultipleSelection = true
//        collectionView.register(nibCell: PhotoVideoCell.self)
//        collectionView.register(nibSupplementaryView: CollectionViewSimpleHeaderWithText.self, kind: UICollectionElementKindSectionHeader)
//        collectionView.isPrefetchingEnabled = false
//        //        collectionView.alwaysBounceVertical = true
//        //        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
//    }
//
//    private func setupPullToRefresh() {
//        //refresher.tintColor = ColorConstants.whiteColor
//        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
//        collectionView.addSubview(refresher)
//    }
//
//    private func setupViewForPopUp() {
//        CardsManager.default.addViewForNotification(view: scrolliblePopUpView)
//
//        scrolliblePopUpView.delegate = self
//        scrolliblePopUpView.isEnable = true
//
//        scrolliblePopUpView.addNotPermittedCardViewTypes(types: [.waitingForWiFi, .autoUploadIsOff, .freeAppSpace, .freeAppSpaceLocalWarning])
//
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
//        collectionView.addSubview(scrolliblePopUpView)
//
//        scrolliblePopUpView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//
//        var constraintsArray = [NSLayoutConstraint]()
//        contentSliderTopY = NSLayoutConstraint(item: scrolliblePopUpView, attribute: .top, relatedBy: .equal, toItem: collectionView, attribute: .top, multiplier: 1, constant: 0)
//        constraintsArray.append(contentSliderTopY!)
//        constraintsArray.append(NSLayoutConstraint(item: scrolliblePopUpView, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
//        constraintsArray.append(NSLayoutConstraint(item: scrolliblePopUpView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
//        contentSliderH = NSLayoutConstraint(item: scrolliblePopUpView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
//        constraintsArray.append(contentSliderH!)
//
//        NSLayoutConstraint.activate(constraintsArray)
//    }
//
//    private func setupSlider() {
//        let sliderController = contentSlider
//
//        let height = scrolliblePopUpView.frame.height + BaseFilesGreedViewController.sliderH
//
//        let subView = UIView(frame: CGRect(x: 0, y: -height, width: collectionView.frame.width, height: BaseFilesGreedViewController.sliderH))
//        subView.addSubview(sliderController.view)
//
//        if let yConstr = self.contentSliderTopY {
//            yConstr.constant = -height
//        }
//        collectionView.updateConstraints()
//
//        collectionView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 25, right: 0)
//        collectionView.addSubview(subView)
//        sliderController.view.frame = subView.bounds
//
//        subView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//
//        var constraintsArray = [NSLayoutConstraint]()
//        constraintsArray.append(NSLayoutConstraint(item: subView, attribute: .top, relatedBy: .equal, toItem: scrolliblePopUpView, attribute: .bottom, multiplier: 1, constant: 0))
//        constraintsArray.append(NSLayoutConstraint(item: subView, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
//        constraintsArray.append(NSLayoutConstraint(item: subView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
//        constraintsArray.append(NSLayoutConstraint(item: subView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: BaseFilesGreedViewController.sliderH))
//
//        constraintsArray.append(NSLayoutConstraint(item: sliderController.view, attribute: .left, relatedBy: .equal, toItem: subView, attribute: .left, multiplier: 1, constant: 0))
//        constraintsArray.append(NSLayoutConstraint(item: sliderController.view, attribute: .top, relatedBy: .equal, toItem: subView, attribute: .top, multiplier: 1, constant: 0))
//        constraintsArray.append(NSLayoutConstraint(item: sliderController.view, attribute: .right, relatedBy: .equal, toItem: subView, attribute: .right, multiplier: 1, constant: 0))
//        constraintsArray.append(NSLayoutConstraint(item: sliderController.view, attribute: .bottom, relatedBy: .equal, toItem: subView, attribute: .bottom, multiplier: 1, constant: 0))
//
//        NSLayoutConstraint.activate(constraintsArray)
//
//        refresherY = -height + 30
//        updateRefresher()
//    }
//
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


// MARK: - ViewForPopUpDelegate scrolliblePopUpView.delegate
extension SharedFilesCollectionManager: CardsContainerViewDelegate {
    func onUpdateViewForPopUpH(h: CGFloat) {
//        let sliderH = contentSlider.view.frame.height
//        let checkBoxH = showAllButton.frame.height
//        let calculatedH = h + sliderH + checkBoxH
//
//        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
//            if let yConstr = self.contentSliderTopY {
//                yConstr.constant = -calculatedH
//            }
//            if let hConstr = self.contentSliderH {
//                hConstr.constant = h
//            }
//
//            // TODO: need layoutIfNeeded?
//            self.collectionView.superview?.layoutIfNeeded()
//            self.collectionView.contentInset = UIEdgeInsets(top: calculatedH, left: 0, bottom: 25, right: 0)
//        }, completion: { [weak self] _ in
//            guard let self = self else {
//                return
//            }
//
//            if self.collectionView.contentOffset.y < 1 {
//                self.collectionView.contentOffset = CGPoint(x: 0.0, y: -self.collectionView.contentInset.top)
//            }
//        })
//
//        refresherY = -calculatedH + 30
//        updateRefresher()
    }
}

// MARK: - EmptyDataViewDelegate

extension SharedFilesCollectionManager: EmptyDataViewDelegate {
    func didButtonTapped() {
//        delegate?.openUploadPhotos()
    }
}

extension SharedFilesCollectionManager: AllFilesSectionSliderMediatorProtocol {
    
    var cardProtocolSupportedView: CardsContainerView {
        return cardsContainerView
    }
    
    var containerView: UIView {
        return stackView
    }
}

