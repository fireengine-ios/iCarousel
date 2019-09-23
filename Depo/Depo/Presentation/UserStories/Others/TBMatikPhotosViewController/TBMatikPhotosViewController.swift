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
    
    @IBOutlet private weak var timelineButton: UIButton! {
        willSet {
            newValue.addTarget(self, action: #selector(seeTimeline), for: .touchUpInside)
            newValue.setTitle(TextConstants.TBMatic.Photos.seeTimeline, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = .clear
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = newValue.bounds.height * 0.5
            newValue.layer.borderColor = UIColor.white.cgColor
            newValue.layer.borderWidth = 1
        }
    }
    
    @IBOutlet private weak var shareButton: UIButton! {
        willSet {
            newValue.addTarget(self, action: #selector(share), for: .touchUpInside)
            newValue.setTitle(TextConstants.TBMatic.Photos.share, for: .normal)
            newValue.setTitleColor(ColorConstants.blueGreen, for: .normal)
            newValue.backgroundColor = .white
            newValue.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 18)
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = newValue.bounds.height * 0.5
        }
    }
    
    // MARK: - Properties
    
    private lazy var fileService = FileService.shared
    
    private var uuids = ["13E37BED-FBF2-4EDD-B91A-95A0631CC10D~CEF7A87D-B211-4E8B-8BDE-74F1F73078BA",
    "025EDCF9-AE5B-4423-9D88-65C6C523319F~31100ACD-1901-4223-8F32-CB89CEB55828",
    "4F5A86F7-9B85-4408-B5B7-A80E1F7EF75A~496EE479-4363-4102-A2B7-223D7F7F0F0A",
    "D2FACE10-A792-4AF4-8C96-6E7E1A66A48B~190AC638-2FAB-4D52-9682-8FEDE3B7575D",
    "73B0B2CC-60CC-4DF7-9F57-A6AF75C09760~2C7482C4-679C-444C-AF9B-027D867D2E2E"]//["f1322ae6-1086-4d2e-9352-c01a174aa7e3", "1883e3d7-4025-400e-b4d7-4492d9a6d3e6", "7e18f1d2-62e0-4381-a5b4-c60c83574bac", "900f6f1e-512b-4c21-967d-feab91e75d8a"]
    private var items = [Item?]()
    private var images = ["http://mirpozitiva.ru/uploads/posts/2016-08/1472042485_04.jpg",
                          "https://mirpozitiva.ru/uploads/posts/2016-08/1472043884_02.jpg",
                          nil,
                          //"http://mirpozitiva.ru/uploads/posts/2016-08/1472042805_21.jpg",
                          "https://img11.postila.ru/resize?w=460&src=%2Fdata%2Fc6%2F47%2F00%2Fea%2Fc64700eae27399b150b3440083fc94c3bda75f5052ea60f7c2aff71ae5a2d7c8.png"]
    
    private lazy var carouselItemFrameWidth: CGFloat = carousel.bounds.width - Constants.leftOffset - Constants.rightOffset
    private lazy var carouselItemFrameHeight: CGFloat = carousel.bounds.height
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM YYYY"
        return formatter
    }()
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        loadItems()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        carouselItemFrameWidth = carousel.bounds.width - Constants.leftOffset - Constants.rightOffset
        carouselItemFrameHeight = carousel.bounds.height
    }
    
    private func configure() {
//        view.addSubview(gradientView)
//        view.sendSubview(toBack: gradientView)
        
        pageControl.numberOfPages = uuids.count
        
        setTitle(with: Date())
    }
    
    private func setupCarousel() {
        carousel.backgroundColor = .clear
        carousel.type = .custom
        carousel.dataSource = self
        carousel.delegate = self
        carousel.isPagingEnabled = true
        carousel.reloadData()
    }
    
    private func loadItems() {
        fileService.details(uuids: uuids, success: { [weak self] items in
            guard let self = self else {
                return
            }
            
            self.uuids.forEach { uuid in
                self.items.append(items.first(where: { $0.uuid == uuid }))
            }
            
            self.setupCarousel()
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
        
    }
    
    @objc private func seeTimeline() {
        
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
        itemView.setup(with: items[index])
        itemView.needShowShadow = index == carousel.currentItemIndex
        itemView.tag = index
        return itemView
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
        setTitle(with: items[carousel.currentItemIndex]?.creationDate)
    
        carousel.visibleItemViews.forEach { view in
            if let itemView = view as? TBMatikPhotoView {
                itemView.needShowShadow = itemView.tag == carousel.currentItemIndex
            }
        }
    }
}
