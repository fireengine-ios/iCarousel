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
    
    enum Constants {
        static let leftOffset: CGFloat = 32
        static let rightOffset: CGFloat = 32
        static let itemSpacing: CGFloat = 8
    }
    
    // MARK: - IBOutlets
    
    private lazy var gradientView: GradientView! = {
        let gradientView = GradientView()
        gradientView.alpha = 0.8
        gradientView.setup(withFrame: view.bounds,
                           startColor: ColorConstants.tealBlue,
                           endColoer: ColorConstants.seaweed,
                           startPoint: .zero,
                           endPoint: CGPoint(x: 0, y: 1))
        return gradientView
    }()
    
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
    @IBOutlet private weak var pageControl: UIPageControl! {
        willSet {
            newValue.currentPageIndicatorTintColor = .white
            newValue.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
        }
    }
    
    @IBOutlet private weak var closeButton: UIButton! {
        willSet {
            newValue.addTarget(self, action: #selector(close), for: .touchUpInside)
        }
    }
    
    @IBOutlet private weak var timelineButton: TimelineButton! {
        willSet {
            newValue.addTarget(self, action: #selector(seeTimeline), for: .touchUpInside)
        }
    }
    
    @IBOutlet private weak var shareButton: UIButton! {
        willSet {
            newValue.addTarget(self, action: #selector(share), for: .touchUpInside)
            newValue.setTitle(TextConstants.TBMatic.Photos.share, for: .normal)
            newValue.setTitleColor(ColorConstants.blueGreen, for: .normal)
            newValue.backgroundColor = .white
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.titleLabel?.textAlignment = .center
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = newValue.bounds.height * 0.5
        }
    }
    
    // MARK: - Properties
    
    // manager use only for share images without showing bottom bar
    private lazy var shareManager = TBMatikPhotosBottomBarManager(delegate: self)
    
    private lazy var fileService = FileService.shared
    private lazy var cacheManager = CacheManager.shared
    
    private var uuids = [String]()
    private var items = [Item?]() {
        didSet {
            carousel.reloadData()
        }
    }
    
    private lazy var carouselItemFrameWidth: CGFloat = carousel.bounds.width - Constants.leftOffset - Constants.rightOffset
    private lazy var carouselItemFrameHeight: CGFloat = carousel.bounds.height
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM YYYY"
        return formatter
    }()
    
    private var currentItem: Item? {
        return items[safe: carousel.currentItemIndex] ?? nil
    }
    
    // MARK: - View lifecycle
    
    deinit {
        cacheManager.delegates.remove(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        loadItems()
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
    }
    
    private func configure() {
        view.insertSubview(gradientView, aboveSubview: backgroundImageView)
            
        pageControl.numberOfPages = uuids.count
        setupCarousel()
        
        setTitle(with: nil)
        
        if !cacheManager.isCacheActualized {
            cacheManager.delegates.add(self)
            timelineButton.visibleState = .photosPreparation
        } else {
            timelineButton.visibleState = .disabled
        }
        shareButton.isEnabled = false
    }
    
    private func setupCarousel() {
        carousel.backgroundColor = .clear
        carousel.type = .custom
        carousel.delegate = self
        carousel.dataSource = self
        carousel.isPagingEnabled = true
    }
    
    private func loadItems() {
        fileService.details(uuids: uuids, success: { [weak self] items in
            guard let self = self else {
                return
            }
            
            self.uuids.forEach { uuid in
                self.items.append(items.first(where: { $0.uuid == uuid }))
            }
            
        }, fail: { errorResponse in
            UIApplication.showErrorAlert(message: errorResponse.description)
        })
    }
    
    private func setTitle(with date: Date?) {
        let dateString: String
        if let date = date {
            dateString = dateFormatter.string(from: date)
        } else {
            dateString = ""
        }
        titleLabel.text = String(format: TextConstants.TBMatic.Photos.title, dateString)
    }
    
    // MARK: - Actions
    
    @objc private func close() {
        dismiss(animated: true)
    }
    
    @objc private func share() {
        shareManager.shareCurrentItem()
    }
    
    @objc private func seeTimeline() {
        guard let item = currentItem else {
            return
        }
        
        guard let tabbarController = UIApplication.shared.windows.first?.rootViewController as? TabBarViewController else {
            return
        }
        
        tabbarController.showPhotosScreen(timelineButton)

        if let segmentedController = tabbarController.activeNavigationController?.viewControllers.last as? SegmentedController {
            segmentedController.loadViewIfNeeded()
        
            if let photosController = segmentedController.currentController as? PhotoVideoController {
                photosController.scrollToItem(item)
            }
        }
        
        dismiss(animated: true)
    }
}

// MARK: - iCarouselDataSource

extension TBMatikPhotosViewController: iCarouselDataSource {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return items.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let itemView = view as? TBMatikPhotoView ?? TBMatikPhotoView.initFromNib()
        itemView.frame = CGRect(origin: .zero, size: CGSize(width: carouselItemFrameWidth, height: carouselItemFrameHeight))
        itemView.setup(with: items[index])
        itemView.needShowShadow = index == carousel.currentItemIndex
        itemView.tag = index
        
        itemView.setImageHandler = { [weak self] in
            self?.completeLoadingImage(for: itemView)
        }
        
        return itemView
    }
    
    private func completeLoadingImage(for view: TBMatikPhotoView) {
        guard view.tag == carousel.currentItemIndex else {
            return
        }
        
        if view.hasImage && cacheManager.isCacheActualized {
            timelineButton.visibleState = .enabled
        }
        
        shareButton.isEnabled = view.hasImage
    }
}

// MARK: - iCarouselDelegate

extension TBMatikPhotosViewController: iCarouselDelegate {

    func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        let spacing = 1 + Constants.itemSpacing/carousel.bounds.width
        let x = offset * spacing * carousel.itemWidth
        return CATransform3DTranslate(transform, x, 0, 0)
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        pageControl.currentPage = carousel.currentItemIndex
        if let item = currentItem {
            setTitle(with: item.creationDate)
        }
    
        carousel.visibleItemViews.forEach { view in
            if let itemView = view as? TBMatikPhotoView {
                itemView.needShowShadow = itemView.tag == carousel.currentItemIndex
            }
        }
    }
}

// MARK: - CacheManagerDelegate

extension TBMatikPhotosViewController: CacheManagerDelegate {
    
    func didCompleteCacheActualization() {
        guard let itemView = carousel.itemView(at: carousel.currentItemIndex) as? TBMatikPhotoView else {
            return
        }
        timelineButton.visibleState = itemView.hasImage ? .enabled : .disabled
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
    func deleteFromFaceImageAlbum(items: [BaseDataSourceItem]) { }
    func openInstaPick() { }
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        if let item = currentItem {
            selectedItemsCallback([item])
        }
    }
}
