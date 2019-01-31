//
//  InstaPickSelectionSegmentedController.swift
//  Depo_LifeTech
//
//  Created by Yaroslav Bondar on 15/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol InstaPickSelectionSegmentedControllerDelegate {
    func selectionStateDidChange(_ selectionState: PhotoSelectionState)
    func didSelectItem(_ selectedItem: SearchItemResponse)
    func didDeselectItem(_ deselectItem: SearchItemResponse)
}

final class InstaPickSelectionSegmentedView: UIView {
    
    private let topView = UIView()
    let containerView = UIView()
    private let transparentGradientView = TransparentGradientView(style: .vertical, mainColor: .white)
    
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.tintColor = ColorConstants.darcBlueColor
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.TurkcellSaturaRegFont(size: 14)], for: .normal)
        return segmentedControl
    }()
    
    let analyzeButton: RoundedInsetsButton = {
        let button = RoundedInsetsButton()
        button.isExclusiveTouch = true
        button.setTitle(TextConstants.analyzeWithInstapick, for: .normal)
        button.insets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
        
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.white.darker(by: 30), for: .highlighted)
        button.setBackgroundColor(ColorConstants.darcBlueColor, for: .normal)
        button.setBackgroundColor(ColorConstants.darcBlueColor.darker(by: 30), for: .highlighted)
        
        button.titleLabel?.font = ApplicationPalette.bigRoundButtonFont
        button.adjustsFontSizeToFitWidth()
        return button
    }()
    
    let analyzesLeftLabel: InsetsLabel = {
        let label = InsetsLabel()
        label.textAlignment = .center
        label.textColor = ColorConstants.darcBlueColor
        label.font = UIFont.TurkcellSaturaBolFont(size: 16)
        label.isHidden = true
        label.backgroundColor = ColorConstants.fileGreedCellColor
        label.insets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        topView.backgroundColor = .white
        containerView.backgroundColor = .white
        setupLayout()
    }
    
    private func setupLayout() {
        let view = self
        view.addSubview(topView)
        topView.addSubview(segmentedControl)
        view.addSubview(containerView)
        view.addSubview(transparentGradientView)
        view.addSubview(analyzeButton)
        view.addSubview(analyzesLeftLabel)
        
        let edgeOffset: CGFloat = Device.isIpad ? 75 : 35
        let transparentGradientViewHeight = NumericConstants.instaPickSelectionSegmentedTransparentGradientViewHeight
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.topAnchor.constraint(equalTo: view.topAnchor).activate()
        topView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        topView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        topView.heightAnchor.constraint(equalToConstant: 50).activate()
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.leadingAnchor
            .constraint(equalTo: topView.leadingAnchor, constant: edgeOffset).activate()
        segmentedControl.trailingAnchor
            .constraint(equalTo: topView.trailingAnchor, constant: -edgeOffset).activate()
        segmentedControl.centerYAnchor.constraint(equalTo: topView.centerYAnchor).activate()
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: topView.bottomAnchor).activate()
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
        
        transparentGradientView.translatesAutoresizingMaskIntoConstraints = false
        transparentGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
        transparentGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        transparentGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        transparentGradientView.heightAnchor
            .constraint(equalToConstant: transparentGradientViewHeight).activate()
        
        analyzeButton.translatesAutoresizingMaskIntoConstraints = false
        analyzeButton.leadingAnchor
            .constraint(equalTo: view.leadingAnchor, constant: 10)
            .setPriority(750)
            .activate()
        analyzeButton.trailingAnchor
            .constraint(equalTo: view.trailingAnchor, constant: -10)
            .setPriority(750)
            .activate()
        analyzeButton.centerYAnchor.constraint(equalTo: transparentGradientView.centerYAnchor).activate()
        analyzeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
        analyzeButton.heightAnchor.constraint(equalToConstant: 54).activate()
        
        analyzesLeftLabel.translatesAutoresizingMaskIntoConstraints = false
        analyzesLeftLabel.bottomAnchor.constraint(equalTo: transparentGradientView.topAnchor, constant: -20).activate()
        analyzesLeftLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).activate()
    }
}

final class InstaPickSelectionSegmentedController: UIViewController, ErrorPresenter, BackButtonActions {
    
    /// not private bcz protocol requirement
    var selectedItems = [SearchItemResponse]()
    
    /// not private bcz protocol requirement
    var selectionState = PhotoSelectionState.selecting {
        didSet {
            switch selectionState {
            case .selecting:
                vcView.analyzesLeftLabel.isHidden = true
            case .ended:
                vcView.analyzesLeftLabel.isHidden = false
            }
            
            delegates.invoke { delegate in
                delegate.selectionStateDidChange(selectionState)
            }
        }
    }
    
    private let selectionControllerPageSize = Device.isIpad ? 200 : 100
    private var currentSelectingCount = 0
    private let maxSelectingLimit = 5
    private var selectingLimit = 0
    
    private var segmentedViewControllers: [UIViewController] = []
    private var delegates = MulticastDelegate<InstaPickSelectionSegmentedControllerDelegate>()
    
    private let instapickService: InstapickService = factory.resolve()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        vcView.segmentedControl.addTarget(self, action: #selector(controllerDidChange), for: .valueChanged)
        vcView.analyzeButton.addTarget(self, action: #selector(analyzeWithInstapick), for: .touchUpInside)
        
        // TODO: localize
        navigationItem.title = "Photos Selected (\(0))"
        removeBackButtonTitle()
        
        let cancelButton = UIBarButtonItem(title: "Cancel",
                                           font: UIFont.TurkcellSaturaDemFont(size: 19),
                                           tintColor: UIColor.white,
                                           accessibilityLabel: "Cancel",
                                           style: .plain,
                                           target: self,
                                           selector: #selector(closeSelf))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    override func loadView() {
        self.view = InstaPickSelectionSegmentedView()
    }
    
    private lazy var vcView: InstaPickSelectionSegmentedView = {
        if let view = self.view as? InstaPickSelectionSegmentedView {
            return view
        } else {
            assertionFailure("override func loadView")
            return InstaPickSelectionSegmentedView()
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSelectingLimitAndStart()
    }
    
    /// one time called
    private func getSelectingLimitAndStart() {
        instapickService.getAnalyzesCount { [weak self] result in
            guard let `self` = self else {
                return
            }
            
            switch result {
            case .success(let analyzesCount):
                
                if analyzesCount.left < self.maxSelectingLimit {
                    self.selectingLimit = analyzesCount.left
                } else {
                    self.selectingLimit = self.maxSelectingLimit
                }
                self.setupScreenWithSelectingLimit(self.selectingLimit)
                
            case .failed(let error):
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    /// one time called
    private func setupScreenWithSelectingLimit(_ selectingLimit: Int) {
        vcView.analyzesLeftLabel.text = "You only have \(selectingLimit) analyses left"
        
        let allPhotosDataSource = AllPhotosSelectionDataSource(pageSize: selectionControllerPageSize)
        let allPhotosVC = PhotoSelectionController(title: "Photos",
                                                   selectingLimit: selectingLimit,
                                                   delegate: self,
                                                   dataSource: allPhotosDataSource)
        
        let albumsVC = InstapickAlbumSelectionViewController(title: "Albums", delegate: self)
        
        let favoriteDataSource = FavoritePhotosSelectionDataSource(pageSize: selectionControllerPageSize)
        let favoritePhotosVC = PhotoSelectionController(title: "Favs",
                                                        selectingLimit: selectingLimit,
                                                        delegate: self,
                                                        dataSource: favoriteDataSource)
        
        segmentedViewControllers = [allPhotosVC, albumsVC, favoritePhotosVC]
        
        /// we should not add "delegates.add(albumsVC)" bcz it is not selection controller
        delegates.add(allPhotosVC)
        delegates.add(favoritePhotosVC)
        
        DispatchQueue.toMain {
            self.selectController(at: 0)
            self.setupSegmentedControl()
        }
    }
    
    private func setupSegmentedControl() {
        assert(!segmentedViewControllers.isEmpty, "should not be empty")
        
        for (index, controller) in segmentedViewControllers.enumerated() {
            vcView.segmentedControl.insertSegment(withTitle: controller.title, at: index, animated: false)
        }
        
        /// selectedSegmentIndex == -1 after removeAllSegments
        vcView.segmentedControl.selectedSegmentIndex = 0
    }
    
    @objc private func closeSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func analyzeWithInstapick() {
        guard !selectedItems.isEmpty else {
            return
        }
        
        dismiss(animated: true, completion: {
            
            let imagesUrls = self.selectedItems.flatMap({ $0.metadata?.mediumUrl })
            let ids = self.selectedItems.flatMap({ $0.uuid })
            
            let topTexts = [TextConstants.instaPickAnalyzingText_0,
                            TextConstants.instaPickAnalyzingText_1,
                            TextConstants.instaPickAnalyzingText_2,
                            TextConstants.instaPickAnalyzingText_3,
                            TextConstants.instaPickAnalyzingText_4]
            
            let bottomText = TextConstants.instaPickAnalyzingBottomText
            if let currentController = UIApplication.topController() {
                let controller = InstaPickProgressPopup.createPopup(with: imagesUrls, topTexts: topTexts, bottomText: bottomText)
                currentController.present(controller, animated: true, completion: nil)
                
                let instapickService: InstapickService = factory.resolve()
                instapickService.startAnalyze(ids: ids, popupToDissmiss: controller)
            }
        })
    }
    
    @objc private func controllerDidChange(_ sender: UISegmentedControl) {
        selectController(at: sender.selectedSegmentIndex)
    }
    
    private func selectController(at selectedIndex: Int) {
        guard selectedIndex < segmentedViewControllers.count else {
            assertionFailure()
            return
        }
        
        childViewControllers.forEach { $0.removeFromParentVC() }
        add(childController: segmentedViewControllers[selectedIndex])
    }
    
    private func add(childController: UIViewController) {
        addChildViewController(childController)
        childController.view.frame = vcView.containerView.bounds
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        vcView.containerView.addSubview(childController.view)
        childController.didMove(toParentViewController: self)
    }
}

// MARK: - Static
extension InstaPickSelectionSegmentedController {
    static func controllerToPresent() -> UIViewController {
        let vc = InstaPickSelectionSegmentedController()
        let navVC = UINavigationController(rootViewController: vc)
        
        let navigationTextColor = UIColor.white
        let navigationBar = navVC.navigationBar
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: navigationTextColor,
            .font: UIFont.TurkcellSaturaDemFont(size: 19)
        ]
        
        navigationBar.titleTextAttributes = textAttributes
        navigationBar.barTintColor = UIColor.lrTealish ///bar's background
        navigationBar.barStyle = .black
        navigationBar.isTranslucent = false
        navigationBar.tintColor = navigationTextColor
        
        return navVC
    }
}

extension InstaPickSelectionSegmentedController: PhotoSelectionControllerDelegate {
    
    func selectionController(_ controller: PhotoSelectionController, didSelectItem item: SearchItemResponse) {
        
        delegates.invoke { delegate in
            delegate.didSelectItem(item)
        }
        
        selectedItems.append(item)
        updateTitle()
        
        let selectedCount = selectedItems.count
        let isReachedLimit = (selectedCount == selectingLimit)
        
        if isReachedLimit {
            selectionState = .ended
        } else {
            selectionState = .selecting
        }
    }
    
    func selectionController(_ controller: PhotoSelectionController, didDeselectItem item: SearchItemResponse) {
        
        delegates.invoke { delegate in
            delegate.didDeselectItem(item)
        }
        
        /// not working "selectedItems.remove(item)"
        for index in (0..<selectedItems.count).reversed() where selectedItems[index] == item {
            selectedItems.remove(at: index)
        }
        
        selectionState = .selecting
        updateTitle()
    }
    
    private func updateTitle() {
        navigationItem.title = "Photos Selected (\(selectedItems.count))"
    }
}

// MARK: - InstapickAlbumSelectionDelegate
extension InstaPickSelectionSegmentedController: InstapickAlbumSelectionDelegate {
    
    func onSelectAlbum(_ album: AlbumItem) {
        let dataSource = AlbumPhotosSelectionDataSource(pageSize: selectionControllerPageSize, albumUuid: album.uuid)
        let albumSelectionVC = PhotoSelectionController(title: album.name ?? "",
                                                           selectingLimit: selectingLimit,
                                                           delegate: self,
                                                           dataSource: dataSource)
        delegates.add(albumSelectionVC)
        navigationController?.pushViewController(albumSelectionVC, animated: true)
    }
}
