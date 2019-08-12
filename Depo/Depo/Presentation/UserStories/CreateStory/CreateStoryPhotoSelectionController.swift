//
//  CreateStoryPhotoSelectionController.swift
//  Depo
//
//  Created by Andrei Novikau on 8/6/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CreateStoryPhotoSelectionController: BaseViewController, ControlTabBarProtocol {
    /// analog CreateStorySelectionController with fix array of WrapData
    
    private var selectionState = PhotoSelectionState.selecting
    private let selectingLimit = NumericConstants.createStoryImagesCountLimit
    
    private var photos = [WrapData]()
    private var selectedItems = [WrapData]() {
        didSet {
            continueButton.isHidden = selectedItems.isEmpty
        }
    }
    
    private lazy var analyticsService = AnalyticsService()
    private let navTitle = TextConstants.createStory

    private let cellId = String(describing: PhotoCell.self)
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = true

        return collectionView
    }()
    
    private lazy var transparentGradientView = TransparentGradientView(style: .vertical, mainColor: .white)
    
    private lazy var continueButton: RoundedInsetsButton = {
        let button = RoundedInsetsButton()
        button.isExclusiveTouch = true
        button.setTitle(TextConstants.createStoryPhotosContinue, for: .normal)
        button.insets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
        
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.white.darker(by: 30), for: .highlighted)
        button.setBackgroundColor(ColorConstants.darkBlueColor, for: .normal)
        button.setBackgroundColor(ColorConstants.darkBlueColor.darker(by: 30), for: .highlighted)
        
        button.titleLabel?.font = ApplicationPalette.bigRoundButtonFont
        button.adjustsFontSizeToFitWidth()
        button.isHidden = true
        button.addTarget(self, action: #selector(openStorySetup), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    init(photos: [WrapData]) {
        super.init(nibName: nil, bundle: nil)
        self.photos = photos
    }
    
    /// will never be called
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupLayout()
        analyticsService.logScreen(screen: .createStoryPhotosSelection)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateItemSize()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupNavigation() {
        hideTabBar()
        navigationBarWithGradientStyle()
        setTitle(withString: navTitle)
        
        let cancelButton = UIBarButtonItem(title: TextConstants.cancel, target: self, selector: #selector(hideController))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    private func setupLayout() {
        let transparentGradientViewHeight = NumericConstants.instaPickSelectionSegmentedTransparentGradientViewHeight
        view.addSubview(collectionView)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: transparentGradientViewHeight, right: 0)
       
        view.addSubview(transparentGradientView)
        transparentGradientView.translatesAutoresizingMaskIntoConstraints = false
        transparentGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
        transparentGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        transparentGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        transparentGradientView.heightAnchor.constraint(equalToConstant: transparentGradientViewHeight).activate()
        
        view.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 10).activate()
        continueButton.centerYAnchor.constraint(equalTo: transparentGradientView.centerYAnchor).activate()
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        continueButton.heightAnchor.constraint(equalToConstant: 54).activate()
        continueButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 206).activate()
    }
    
    private func updateItemSize() {
        let viewWidth = collectionView.bounds.width
        let columns: CGFloat = Device.isIpad ? 8 : 4
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
    }
    
    //MARK: - Actions
    @objc private func hideController() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func openStorySetup() {
        let controller = CreateStoryViewController(images: selectedItems)
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - cell updates
extension CreateStoryPhotoSelectionController {

    private func selectCell(at indexPath: IndexPath) {
        selectedItems.append(photos[indexPath.row])
        
        let selectedCount = collectionView.indexPathsForSelectedItems?.count ?? 0
        let isReachedLimit = (selectedCount == selectingLimit)
        
        if isReachedLimit {
            /// update all cells
            selectionState = .ended
            updateVisibleCellsForSelectionState()
            
        } else {
            /// update one cell
            selectionState = .selecting
            updateCellForSelectionState(at: indexPath)
        }
        
        updateNavigationTitle()
    }
    
    private func deselectCell(at indexPath: IndexPath) {
        selectedItems.remove(photos[indexPath.row])
        
        selectionState = .selecting
        let selectedCount = collectionView.indexPathsForSelectedItems?.count ?? 0
        let isDeselectFromLimit = (selectedCount == selectingLimit - 1)
        
        if isDeselectFromLimit {
            /// update all cells
            updateVisibleCellsForSelectionState()
            
        } else {
            /// update one cell
            updateCellForSelectionState(at: indexPath)
        }
        
        updateNavigationTitle()
    }
    
    private func updateCellForSelectionState(at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell else {
            return
        }
        cell.update(for: selectionState)
    }
    
    private func updateVisibleCellsForSelectionState() {
        let cells = collectionView.indexPathsForVisibleItems.compactMap { collectionView.cellForItem(at: $0) as? PhotoCell }
        cells.forEach { $0.update(for: selectionState) }
    }
    
    private func updateNavigationTitle() {
        var navigationTitle = navTitle
        
        let selectedItemsCount = selectedItems.count
        if selectedItemsCount > 0 {
            navigationTitle = String(format: TextConstants.createStoryPhotosSelected, selectedItemsCount)
        }
        
        setTitle(withString: navigationTitle)
    }
}

// MARK: - UICollectionViewDataSource
extension CreateStoryPhotoSelectionController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    }
}

// MARK: - UICollectionViewDelegate
extension CreateStoryPhotoSelectionController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoCell else {
            assertionFailure()
            return
        }
        
        let item = photos[indexPath.row]
        cell.update(for: selectionState)
        cell.setup(by: item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? PhotoCell)?.cancelImageLoading()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        switch selectionState {
        case .selecting:
            return true
        case .ended:
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectCell(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        deselectCell(at: indexPath)
    }
}
