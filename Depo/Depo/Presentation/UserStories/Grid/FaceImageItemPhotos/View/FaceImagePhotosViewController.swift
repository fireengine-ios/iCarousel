//
//  FaceImageItemPhotosViewController.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class FaceImagePhotosViewController: BaseFilesGreedChildrenViewController, FaceImagePhotosViewInput {

    private let albumsSliderHeight: CGFloat = 170
    private let headerImageHeight: CGFloat = 190
    
    private var albumsSlider: LBAlbumLikePreviewSliderViewController?
    private var albumsSliderModule: LBAlbumLikePreviewSliderPresenter?
    private var headerView = UIView()
    private var headerImage = UIImageView()
    private var albumsHeightConstraint: NSLayoutConstraint?
    private var headerImageHeightConstraint: NSLayoutConstraint?
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderPosition()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if mainTitle.count == 0 {
            mainTitle = TextConstants.faceImageAddName
        }
        
        configureTitleNavigationBar()
    }
    
    // MARK: - BaseFilesGreedViewController
    
    override func configurateNavigationBar() {
        configureFaceImageItemsPhotoActions()
    }
    
    override func stopSelection() {
        super.stopSelection()
        
        configureFaceImageItemsPhotoActions()
        setTitle(withString: mainTitle)
    }
    
    @objc func addNameAction() {
        if let output = output as? FaceImagePhotosViewOutput {
            output.openAddName()
        }
    }
    
    private func configureTitleNavigationBar() {
        setTouchableTitle(title: mainTitle)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.addNameAction))
        navigationItem.titleView?.addGestureRecognizer(tap)
    }
    
    // MARK: - FaceImagePhotosViewInput
    
    func reloadName(_ name: String) {
        mainTitle = name
        
        setTitle(withString: mainTitle)
    }

    // MARK: - FaceImagePhotosViewInput
    
    func setHeaderImage(with url: URL) {
        headerImage.sd_setImage(with: url) { [weak self] (image, error, cacheType, url) in
            self?.headerImage.image = image
        }
    }
    
    func loadAlbumsForPeopleItem(_ peopleItem: PeopleItem) {
        setupHeaderViewWith(peopleItem: peopleItem)
    }
    
    func setHeaderViewHidden(_ isHidden: Bool) {
        if isHidden {
            albumsHeightConstraint?.constant = 0
            headerImageHeightConstraint?.constant = 0
        } else {
            albumsHeightConstraint?.constant = albumsSliderHeight
            headerImageHeightConstraint?.constant = headerImageHeight
        }
        
        albumsSlider?.view.isHidden = isHidden
        headerImage.isHidden = isHidden
    }
    
    // MARK: - Header View Methods
    
    private func setupHeaderViewWith(peopleItem: PeopleItem) {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addSubview(headerView)
        headerView.bottomAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        createHeaderImage()
        headerView.addSubview(headerImage)
        headerImage.translatesAutoresizingMaskIntoConstraints = false
        headerImage.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        headerImage.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
        headerImage.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
        headerImageHeightConstraint = headerImage.heightAnchor.constraint(equalToConstant: 0)
        headerImageHeightConstraint?.isActive = true
        
        createAlbumsSliderWith(peopleItem: peopleItem)
        if let albumsView = albumsSlider?.view {
            albumsView.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(albumsView)
            headerImage.bottomAnchor.constraint(equalTo: albumsView.topAnchor).isActive = true
            albumsView.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
            albumsView.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
            albumsView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
            albumsHeightConstraint = albumsView.heightAnchor.constraint(equalToConstant: 0)
            albumsHeightConstraint?.isActive = true
        }
    }
    
    private func createAlbumsSliderWith(peopleItem: PeopleItem) {
        let sliderModuleConfigurator = LBAlbumLikePreviewSliderModuleInitializer()
        let sliderPresenter = LBAlbumLikePreviewSliderPresenter()
        sliderModuleConfigurator.initialise(inputPresenter: sliderPresenter, peopleItem: peopleItem)
        let sliderVC = sliderModuleConfigurator.lbAlbumLikeSliderVC
        albumsSlider = sliderVC
        albumsSliderModule = sliderPresenter
        if let basePresenter = output as? BaseFilesGreedModuleInput {
            sliderPresenter.baseGreedPresenterModule = basePresenter
        }
    }
    
    private func createHeaderImage() {
        headerImage = UIImageView()
        headerImage.translatesAutoresizingMaskIntoConstraints = false
        headerImage.contentMode = .scaleAspectFill
        headerImage.clipsToBounds = true
    }
    
    private func updateHeaderPosition() {
        collectionView.contentInset.top = headerView.frame.height;
    }
    
}
