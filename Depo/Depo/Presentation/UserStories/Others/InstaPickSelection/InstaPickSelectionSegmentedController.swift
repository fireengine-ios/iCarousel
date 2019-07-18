import UIKit
import Reachability

protocol InstaPickSelectionSegmentedControllerDelegate {
    func selectionStateDidChange(_ selectionState: PhotoSelectionState)
    func didSelectItem(_ selectedItem: SearchItemResponse)
    func didDeselectItem(_ deselectItem: SearchItemResponse)
}

final class InstaPickSelectionSegmentedController: UIViewController, ErrorPresenter, BackButtonActions {
    
    // MARK: properties
    
    /// not private bcz protocol requirement
    var selectedItems = [SearchItemResponse]() {
        didSet {
            vcView.analyzeButton.isHidden = selectedItems.isEmpty
        }
    }
    
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
    private let selectingLimit = 5
    
    private var segmentedViewControllers: [UIViewController] = []
    private var delegates = MulticastDelegate<InstaPickSelectionSegmentedControllerDelegate>()
    
    private let instapickService: InstapickService = factory.resolve()
    
    private lazy var albumsTabIndex: Int = {
        if let index = segmentedViewControllers.index(of: albumsVC) {
            return index
        }
        assertionFailure("there is no albumsVC in segmentedViewControllers. check func setupScreenWithSelectingLimit. It was: index = 1")
        return 0
    }()
    
    private lazy var albumsVC = InstapickAlbumSelectionViewController(title: TextConstants.albumsTitle, delegate: self)
    
    private lazy var closeAlbumButton = UIBarButtonItem(image: UIImage(named: "closeButton"),
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(onCloseAlbum))
    
    private lazy var closeSelfButton = UIBarButtonItem(title: TextConstants.cancel,
                                                    font: UIFont.TurkcellSaturaDemFont(size: 19),
                                                    tintColor: UIColor.white,
                                                    accessibilityLabel: TextConstants.cancel,
                                                    style: .plain,
                                                    target: self,
                                                    selector: #selector(closeSelf))
    
    // MARK: start
    
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
        
        removeBackButtonTitle()
        navigationItem.title = String(format: TextConstants.instapickSelectionPhotosSelected, 0)
        navigationItem.leftBarButtonItem = closeSelfButton
    }
    
    override func loadView() {
        let formatedAnalyzesLeft = TextConstants.instapickSelectionAnalyzesLeftMax
        self.view = InstaPickSelectionSegmentedView(buttonText: TextConstants.analyzeWithInstapick,
                                                    maxReachedText: String(format: formatedAnalyzesLeft, selectingLimit),
                                                    needShowSegmentedControll: true)
    }
    
    private lazy var vcView: InstaPickSelectionSegmentedView = {
        if let view = self.view as? InstaPickSelectionSegmentedView {
            return view
        } else {
            assertionFailure("override func loadView")
            let formatedAnalyzesLeft = TextConstants.instapickSelectionAnalyzesLeftMax
            return InstaPickSelectionSegmentedView(buttonText: TextConstants.analyzeWithInstapick,
                                                   maxReachedText: String(format: formatedAnalyzesLeft, selectingLimit),
                                                   needShowSegmentedControll: true)
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScreenWithSelectingLimit(selectingLimit)
        trackScreen()
    }
    
    private func trackScreen() {
        let analyticsService: AnalyticsService = factory.resolve()
        analyticsService.logScreen(screen: .photoPickPhotoSelection)
        analyticsService.trackDimentionsEveryClickGA(screen: .photoPickPhotoSelection)
    }
    
    /// one time called
    private func setupScreenWithSelectingLimit(_ selectingLimit: Int) {
        let formatedAnalyzesLeft = TextConstants.instapickSelectionAnalyzesLeftMax
        vcView.analyzesLeftLabel.text = String(format: formatedAnalyzesLeft, selectingLimit)
        
        let allPhotosDataSource = AllPhotosSelectionDataSource(pageSize: selectionControllerPageSize)
        let allPhotosVC = PhotoSelectionController(title: TextConstants.actionSheetPhotos,
                                                   selectingLimit: selectingLimit,
                                                   delegate: self,
                                                   dataSource: allPhotosDataSource)
        
        let favoriteDataSource = FavoritePhotosSelectionDataSource(pageSize: selectionControllerPageSize)
        let favoritePhotosVC = PhotoSelectionController(title: TextConstants.homeButtonFavorites,
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
        updateLeftBarButtonItem(selectedIndex: selectedIndex)
    }
    
    private func updateLeftBarButtonItem(selectedIndex: Int) {
        /// optimized for reading, not performance
        let isAlbumsTabOpened = (selectedIndex == albumsTabIndex)
        let isAnyAlbumOpened = (segmentedViewControllers[albumsTabIndex] != albumsVC)
        
        if isAlbumsTabOpened, isAnyAlbumOpened {
            navigationItem.leftBarButtonItem = closeAlbumButton
        } else {
            navigationItem.leftBarButtonItem = closeSelfButton
        }
    }
    
    private func add(childController: UIViewController) {
        addChildViewController(childController)
        childController.view.frame = vcView.containerView.bounds
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        vcView.containerView.addSubview(childController.view)
        childController.didMove(toParentViewController: self)
    }
    
    
    @objc private func onCloseAlbum() {
        replaceControllerAtAlbumsTab(with: albumsVC)
    }
    
    private func replaceControllerAtAlbumsTab(with controller: UIViewController) {
        segmentedViewControllers.remove(at: albumsTabIndex)
        segmentedViewControllers.insert(controller, at: albumsTabIndex)
        selectController(at: albumsTabIndex)
    }
}

// MARK: - PhotoSelectionControllerDelegate
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
        navigationItem.title = String(format: TextConstants.instapickSelectionPhotosSelected, selectedItems.count)
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
        replaceControllerAtAlbumsTab(with: albumSelectionVC)
    }
}

// MARK: - Static
extension InstaPickSelectionSegmentedController {
    static func controllerToPresent() -> UIViewController {
        let vc = InstaPickSelectionSegmentedController()
        let navVC = UINavigationController(rootViewController: vc)
        
        let navigationTextColor = UIColor.white
        let navigationBar = navVC.navigationBar
        
        let textAttributes: [NSAttributedStringKey: AnyHashable] = [
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
