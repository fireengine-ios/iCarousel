//
//  FaceImageItemPhotosViewController.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 2/1/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

 final class FaceImagePhotosViewController: BaseFilesGreedChildrenViewController {

    private let albumsSliderHeight: CGFloat = 170
    private let headerImageHeight: CGFloat = 190
    
    private var albumsSlider: LBAlbumLikePreviewSliderViewController?
    private var headerView = UIView()
    private var headerImage = LoadingImageView()
    private var gradientHeaderLayer: CALayer?
    private var countPhotosLabel = UILabel()
    private var albumsHeightConstraint: NSLayoutConstraint?
    private var headerImageHeightConstraint: NSLayoutConstraint?
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderPosition()
        gradientHeaderLayer?.frame = headerView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureTitleNavigationBar()
    }
    
    // MARK: - BaseFilesGreedViewController
    
    override func configurateNavigationBar() {
        configureFaceImageItemsPhotoActions()
    }
    
    override func stopSelection() {
        super.stopSelection()
        
        configureFaceImageItemsPhotoActions()
        
        configureNavBarWithTouch()
    }
    
    override func changeSortingRepresentation(sortType type: SortedRules) {
        super.changeSortingRepresentation(sortType: type)

        configureNavBarWithTouch()
    }
    
    @objc func addNameAction() {
        if let output = output as? FaceImagePhotosViewOutput {
            output.openAddName()
        }
    }
    
    private func configureTitleNavigationBar() {
        if mainTitle.isEmpty {
            mainTitle = TextConstants.faceImageAddName
        }
        
        configureNavBarWithTouch()
    }

    // MARK: - Header View Methods
    
    private func setupHeaderViewWith(peopleItem: PeopleItem?) {
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
        headerImageHeightConstraint = headerImage.heightAnchor.constraint(equalToConstant: headerImageHeight)
        headerImageHeightConstraint?.isActive = true

        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        gradientHeaderLayer = headerImage.addGradientLayer(colors: [.clear, ColorConstants.textGrayColor])
        
        countPhotosLabel.backgroundColor = UIColor.clear
        countPhotosLabel.textColor = UIColor.white
        countPhotosLabel.font = UIFont.TurkcellSaturaDemFont(size: 17.0)
        countPhotosLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(countPhotosLabel)
        countPhotosLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        countPhotosLabel.bottomAnchor.constraint(equalTo: headerImage.bottomAnchor, constant: -16).isActive = true

        if let peopleItem = peopleItem {
            createAlbumsSliderWith(peopleItem: peopleItem)
            if let albumsView = albumsSlider?.view {
                albumsView.translatesAutoresizingMaskIntoConstraints = false
                headerView.addSubview(albumsView)
                headerImage.bottomAnchor.constraint(equalTo: albumsView.topAnchor).isActive = true
                albumsView.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
                albumsView.rightAnchor.constraint(equalTo: headerView.rightAnchor).isActive = true
                albumsView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
                albumsHeightConstraint = albumsView.heightAnchor.constraint(equalToConstant: albumsSliderHeight)
                albumsHeightConstraint?.isActive = true
            }
        } else {
            headerImage.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
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
    
    private func createHeaderImage() {
        headerImage = LoadingImageView()
        headerImage.translatesAutoresizingMaskIntoConstraints = false
        headerImage.contentMode = .scaleAspectFill
        headerImage.clipsToBounds = true
    }
    
    private func updateHeaderPosition() {
        if let albumHeight = albumsHeightConstraint?.constant,
            let headerImageHeight = headerImageHeightConstraint?.constant {
            collectionView.contentInset.top = albumHeight + headerImageHeight
        } else {
            collectionView.contentInset.top = headerImageHeight
        }
    }
    
    private func configureNavBarWithTouch() {
        setTitle(withString: mainTitle, andSubTitle: output.getCurrentSortRule().descriptionForTitle)
        
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
    
    func setHeaderImage(with path: PathForItem) {
        headerImage.loadImage(path: path)
    }
    
    func setupHeader(forPeopleItem item: PeopleItem?) {
        setupHeaderViewWith(peopleItem: item)
    }
    
    func dismiss() {
        navigationController?.popViewController(animated: true)
    }
    
    func hiddenSlider(isHidden: Bool) {
        if let albumsView = albumsSlider?.view {
            if isHidden {
                albumsHeightConstraint?.isActive = false
                albumsHeightConstraint = albumsView.heightAnchor.constraint(equalToConstant: 0)
                albumsView.isHidden = true
            } else {
                albumsHeightConstraint?.isActive = false
                albumsHeightConstraint = albumsView.heightAnchor.constraint(equalToConstant: albumsSliderHeight)
                headerImage.bottomAnchor.constraint(equalTo: albumsView.topAnchor).isActive = true
                albumsView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
                albumsView.isHidden = false
            }
            albumsHeightConstraint?.isActive = true

            headerImage.layoutIfNeeded()

            updateHeaderPosition()
        }
    }
        
    func setCountImage(_ count: String) {
        countPhotosLabel.text = count
    }
    
}
