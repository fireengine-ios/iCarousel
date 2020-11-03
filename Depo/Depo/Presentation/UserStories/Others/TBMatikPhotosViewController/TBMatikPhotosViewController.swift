//
//  TBMatikPhotosViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 9/19/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import iCarousel

final class TBMatikPhotosViewController: ViewController, NibInit {
    
    static func with(uuids: [String]) -> TBMatikPhotosViewController {
        let controller = initFromNib()
        controller.uuids = uuids
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .overFullScreen
        return controller
    }
    
    static func with(items: [Item], selectedIndex: Int) -> TBMatikPhotosViewController {
        
        var itemsDict = [String: Item]()
        for item in items {
            itemsDict[item.uuid] = item
        }
        
        let uuids = items.compactMap { $0.uuid }
        
        let controller = initFromNib()
        controller.modalTransitionStyle = .coverVertical
        controller.modalPresentationStyle = .overFullScreen
        controller.items = itemsDict
        controller.uuids = uuids
        controller.selectedIndex = selectedIndex
        return controller
    }
    
    enum Constants {
        static let leftOffset: CGFloat = 32
        static let rightOffset: CGFloat = 32
        static let itemSpacing: CGFloat = 8
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var backgroundImageView: UIImageView!
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 22)
            newValue.textColor = .white
            newValue.textAlignment = .center
            newValue.numberOfLines = 2
        }
    }
    
    @IBOutlet private weak var carousel: iCarousel!
    
    @IBOutlet private weak var topConstraint: NSLayoutConstraint! {
        willSet {
            if Device.operationSystemVersionLessThen(11) {
                newValue.constant = 16
            }
        }
    }
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var timelineButton: TimelineButton!
    
    @IBOutlet private weak var shareButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.tbMaticPhotosShare, for: .normal)
            newValue.setTitleColor(ColorConstants.blueGreen, for: .normal)
            newValue.setTitleColor(ColorConstants.blueGreen.withAlphaComponent(0.5), for: .disabled)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            
            newValue.setBackgroundColor(UIColor.white, for: .normal)
            newValue.setBackgroundColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
            newValue.setBackgroundColor(UIColor.white.darker(by: 30), for: .highlighted)
            
            newValue.isEnabled = false
        }
    }
    
    // MARK: - Properties
    
    // manager use only for share images without showing bottom bar
    private lazy var shareManager = TBMatikPhotosBottomBarManager(delegate: self)
    
    private lazy var fileService = FileService.shared
    private lazy var cacheManager = CacheManager.shared
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    
    private var uuids = [String]()
    private var items = [String: Item]()
    
    private lazy var carouselItemFrameWidth: CGFloat = carousel.bounds.width - Constants.leftOffset - Constants.rightOffset
    private lazy var carouselItemFrameHeight: CGFloat = carousel.bounds.height
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM YYYY"
        return formatter
    }()
    
    private var currentItem: Item? {
        if let uuid = uuids[safe: carousel.currentItemIndex] {
            return items[uuid]
        } else {
            assertionFailure("uuids not setuped")
            return nil
        }
    }
    
    private var selectedIndex: Int = 0
    
    // MARK: - View lifecycle
    
    deinit {
        cacheManager.delegates.remove(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        if items.isEmpty {
            loadItemsByUuids()
        } else {
            reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //need to fix crash on show bottom bar
        shareManager.editingTabBar?.view.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        carouselItemFrameWidth = carousel.bounds.width - Constants.leftOffset - Constants.rightOffset
        carouselItemFrameHeight = carousel.bounds.height
        
        if let currentView = carousel.currentItemView as? TBMatikPhotoView, currentView.image != nil {
            updateBackground(with: currentView.image)
        }
    }
    
    private func track(screen: AnalyticsAppScreens) {
        analyticsService.logScreen(screen: screen)
        analyticsService.trackDimentionsEveryClickGA(screen: screen)
    }
    
    private func configure() {
        backgroundImageView.backgroundColor = ColorConstants.tbMatikBlurColor
        backgroundImageView.contentMode = .scaleAspectFill
        
        setupCarousel()
        updateTitle()
        
        if !cacheManager.isCacheActualized {
            cacheManager.delegates.add(self)
            timelineButton.visibleState = .photosPreparation
        } else {
            timelineButton.visibleState = .disabled
        }
    }
    
    private func setupCarousel() {
        carousel.isHidden = true
        carousel.backgroundColor = .clear
        carousel.type = .custom
        carousel.delegate = self
        carousel.dataSource = self
        carousel.isPagingEnabled = true
        carousel.bounces = false
    }
    
    private func loadItemsByUuids() {
        showSpinner()
        
        fileService.details(uuids: uuids, success: { [weak self] items in
            guard let self = self else {
                return
            }
            
            items.forEach { item in
                self.items[item.uuid] = item
            }
            
            self.reloadData()
            self.hideSpinner()
            
        }, fail: { [weak self] errorResponse in
            self?.hideSpinner()
            UIApplication.showErrorAlert(message: errorResponse.description)
        })
    }
    
    private func reloadData() {
        carousel.reloadData()
        carousel.scrollToItem(at: selectedIndex, animated: false)
        carousel.isHidden = false
        updateTitle()
    }
    
    private func updateTitle() {
        let dateString: String
        
        if let date = currentItem?.metaData?.takenDate {
            dateString = dateFormatter.string(from: date)
        } else {
            dateString = ""
        }
        
        titleLabel.text = String(format: TextConstants.tbMaticPhotosTitle, dateString)
    }
    
    // MARK: - Actions
    
    @IBAction private func onClose() {
        dismiss(animated: true)
    }
    
    @IBAction private func onShare() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .share, eventLabel: .tbmatik(.share))
        shareManager.shareCurrentItem()
    }
    
    @IBAction private func onSeeTimeline() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions, eventActions: .tbmatik, eventLabel: .tbmatik(.seeTimeline))
        
        guard let item = currentItem,
            let tabbarController = RouterVC().tabBarController else {
            assertionFailure()
            return
        }
        
        tabbarController.showAndScrollPhotosScreen(scrollTo: item)        
        dismiss(animated: true)
    }
    
    private func updateBackground(with image: UIImage?) {
        DispatchQueue.global().async { [weak self] in
            guard let blurImage = image?.applyBlur(radius: 20,
                                                   tintColor: ColorConstants.tbMatikBlurColor.withAlphaComponent(0.6),
                                                   saturationDeltaFactor: 1.8) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.backgroundImageView.image = blurImage
            }
        }
    }
}

// MARK: - iCarouselDataSource

extension TBMatikPhotosViewController: iCarouselDataSource {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return uuids.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let itemView = view as? TBMatikPhotoView ?? TBMatikPhotoView.initFromNib()
        itemView.frame = CGRect(origin: .zero, size: CGSize(width: carouselItemFrameWidth, height: carouselItemFrameHeight))
        
        let uuid = uuids[index]
        itemView.setup(with: items[uuid])
        itemView.needShowShadow = index == carousel.currentItemIndex
        itemView.tag = index
        
        itemView.setImageHandler = { [weak self] in
            self?.updateButtonsState(for: itemView)
            self?.updateBackground(with: itemView.image)
        }
        
        return itemView
    }
    
    private func updateButtonsState(for view: TBMatikPhotoView) {
        guard view.tag == carousel.currentItemIndex else {
            return
        }
        
        if cacheManager.isCacheActualized {
            timelineButton.visibleState = view.hasImage ? .enabled : .disabled
        } else {
            timelineButton.visibleState = .photosPreparation
        }
        
        shareButton.isEnabled = view.hasImage
        shareButton.alpha = shareButton.isEnabled ? 1 : 0.5
    }
}

// MARK: - iCarouselDelegate

extension TBMatikPhotosViewController: iCarouselDelegate {

    func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        let spacing = 1 + Constants.itemSpacing / carousel.bounds.width
        let x = offset * spacing * carousel.itemWidth
        return CATransform3DTranslate(transform, x, 0, 0)
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        updateTitle()

        track(screen: .tbmatikSwipePhoto(carousel.currentItemIndex + 1))
        
        carousel.visibleItemViews.forEach { view in
            if let itemView = view as? TBMatikPhotoView {
                itemView.needShowShadow = itemView.tag == carousel.currentItemIndex
            }
        }
        
        if let currentView = carousel.currentItemView as? TBMatikPhotoView {
            updateButtonsState(for: currentView)
            updateBackground(with: currentView.image)
        }
    }
}

// MARK: - CacheManagerDelegate

extension TBMatikPhotosViewController: CacheManagerDelegate {
    
    func didCompleteCacheActualization() {
        guard let itemView = carousel.itemView(at: carousel.currentItemIndex) as? TBMatikPhotoView else {
            assertionFailure()
            return
        }
        
        DispatchQueue.main.async {
            self.timelineButton.visibleState = itemView.hasImage ? .enabled : .disabled
        }
    }
}

extension TBMatikPhotosViewController: BaseItemInputPassingProtocol {
    func operationFinished(withType type: ElementTypes, response: Any?) { }
    func operationFailed(withType type: ElementTypes) { }
    func selectModeSelected() { }
    func selectAllModeSelected() { }
    func deSelectAll() { }
    func stopModeSelected() { }
    func printSelected() { }
    func changeCover() { }
    func openInstaPick() { }
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        if let item = currentItem {
            selectedItemsCallback([item])
        }
    }
}
