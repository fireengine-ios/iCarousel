//
//  FaceImageItemPhotosViewController.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol FaceImagePhotosViewControllerDelegate {
    func viewWillDisappear()
}

final class FaceImagePhotosViewController: BaseFilesGreedChildrenViewController {
    
    @IBOutlet private(set) weak var contentView: UIView!
    
    private let albumsSliderHeight: CGFloat = 200
    private var albumsSlider: LBAlbumLikePreviewSliderViewController?
    private var headerView = UIView()
    private var gradientHeaderLayer: CALayer?
    private var albumsHeightConstraint: NSLayoutConstraint?

    var delegate: FaceImagePhotosViewControllerDelegate?
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderPosition()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureTitleNavigationBar()
        navigationItem.rightBarButtonItem = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.viewWillDisappear()
    }
    
    // MARK: - BaseFilesGreedViewController
    
    override func configurateNavigationBar() {
        configureFaceImageItemsPhotoActions()
    }
    
    override func stopSelection() {
        super.stopSelection()
        
        configureFaceImageItemsPhotoActions()
        
        configureNavBarWithTouch()
        navigationItem.rightBarButtonItem = nil
    }
    
    override func changeSortingRepresentation(sortType type: SortedRules) {
        super.changeSortingRepresentation(sortType: type)

        configureNavBarWithTouch()
    }
    
    override func startSelection(with numberOfItems: Int) {
        super.startSelection(with: numberOfItems)
        navigationItem.rightBarButtonItem = nil
    }
    
    @objc func addNameAction() {
        if let output = output as? FaceImagePhotosViewOutput {
            output.openAddName()
        }
    }
    
    @objc func hideAlbum() {
        if let output = output as? FaceImagePhotosViewOutput {
            AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.ButtonClick(buttonName: .hide))
            output.hideAlbum()
        }
    }
    
    private func configureTitleNavigationBar() {
        if mainTitle.isEmpty {
            mainTitle = TextConstants.faceImageAddName
        }
        
        configureNavBarWithTouch()
    }

    // MARK: - Header View Methods
    
    private func setupHeaderView(with item: Item, status: ItemStatus?) {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addSubview(headerView)
        headerView.bottomAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        if status == .active, let peopleItem = item as? PeopleItem {
            createAlbumsSliderWith(peopleItem: peopleItem)
            if let albumsView = albumsSlider?.view {
                albumsView.translatesAutoresizingMaskIntoConstraints = false
                headerView.addSubview(albumsView)
                albumsView.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
                albumsView.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
                albumsView.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
                albumsView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
                //show slider after loading albums if needed
                albumsHeightConstraint = albumsView.heightAnchor.constraint(equalToConstant: 0)
                albumsHeightConstraint?.isActive = true
            }
        }
    }
    
    private func createAlbumsSliderWith(peopleItem: PeopleItem) {
        let sliderModuleConfigurator = LBAlbumLikePreviewSliderModuleInitializer()
        let sliderPresenter = LBAlbumLikePreviewSliderPresenter()
        if let output = output as? FaceImagePhotosPresenter {
            sliderModuleConfigurator.initialise(inputPresenter: sliderPresenter, peopleItem: peopleItem, moduleOutput: output)
        }
        let sliderVC = sliderModuleConfigurator.lbAlbumLikeSliderVC
        albumsSlider = sliderVC
        if let basePresenter = output as? BaseFilesGreedModuleInput {
            sliderPresenter.baseGreedPresenterModule = basePresenter
        }
    }
    
    private func updateHeaderPosition() {
        if let albumHeight = albumsHeightConstraint?.constant {
            collectionView.contentInset.top = albumHeight
            
            // correct display header image when loading smart albums after photos
            if collectionView.contentOffset.y == 0 {
                collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.contentInset.top), animated: false)
            }
        } else {
            collectionView.contentInset.top = 0
        }
    }
    
    private func configureNavBarWithTouch() {
        setTitle(withString: mainTitle)
        
        if let output = output as? FaceImagePhotosViewOutput,
            let type = output.faceImageType(), type == .people {
            addNavBarTouch()
        }
    }
    
    private func addNavBarTouch() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.addNameAction))
        navigationItem.titleView?.addGestureRecognizer(tap)
    }
    
}

// MARK: - FaceImagePhotosViewInput

extension FaceImagePhotosViewController: FaceImagePhotosViewInput {
    
    func reloadName(_ name: String) {
        mainTitle = name
        
        configureNavBarWithTouch()
    }
    
    func setHeaderImage(with path: PathForItem) {}
    
    func setupHeader(with item: Item, status: ItemStatus?) {
        setupHeaderView(with: item, status: status)
    }
    
    func hiddenSlider(isHidden: Bool) {
        guard let albumsView = albumsSlider?.view else {
            return
        }

        albumsHeightConstraint?.constant = isHidden ? 0 : albumsSliderHeight
        albumsView.isHidden = isHidden
        view.layoutIfNeeded()
    }
        
    func setCountImage(_ count: String) {
        if let output = output as? FaceImagePhotosViewOutput {
            output.setCountLabel(with: count)
        }
    }
    
    func reloadSlider() {
        guard let slider = albumsSlider else {
            return
        }
        slider.reloadAllData()
    }
    
}
