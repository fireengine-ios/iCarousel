//
//  PhotoVideoDetailPhotoVideoDetailViewController.swift
//  Depo
//
//  Created by Oleg on 01/07/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos

final class PhotoVideoDetailViewController: BaseViewController {
    var output: PhotoVideoDetailViewOutput!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var viewForBottomBar: UIView!
    
    @IBOutlet private weak var bottomBlackView: UIView!
    
    private lazy var player: MediaPlayer = factory.resolve()
    
    private var localPlayer: AVPlayer?
    private var playerController: AVPlayerViewController?
    
    var hideActions = false
    var editingTabBar: BottomSelectionTabBarViewController!
    private var needToScrollAfterRotation = true
    
    private var isFullScreen = false {
        didSet {
            ///  ANIMATION
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { 
//                UIApplication.shared.isStatusBarHidden = self.isFullScreen
//            }
//            navigationController?.setNavigationBarHidden(self.isFullScreen, animated: true)
//            
//            if isFullScreen {
//                UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
//                    self.editingTabBar.view.transform = CGAffineTransform(translationX: 0, y: self.editingTabBar.view.bounds.height)
//                }, completion: {_ in
//                    self.editingTabBar.view.isHidden = self.isFullScreen
//                })
//                
//            } else {      
//                editingTabBar.view.isHidden = self.isFullScreen
//                UIView.animate(withDuration: NumericConstants.animationDuration) { 
//                    self.editingTabBar.view.transform = .identity
//                }
//            }
            
            /// without animation
            
            Device.setStatusBarHiddenForLandscapeIfNeed(isFullScreen)
            editingTabBar.view.isHidden = isFullScreen
            navigationController?.navigationBar.isHidden = isFullScreen
            
            bottomBlackView.isHidden = self.isFullScreen
            viewForBottomBar.isUserInteractionEnabled = !self.isFullScreen
        }
    } 
    
    private var selectedIndex = 0 {
        didSet {
            guard !objects.isEmpty, selectedIndex < objects.count else {
                return
            }
            setupNavigationBar()
            setupTitle()
            output.setSelectedItemIndex(selectedIndex: selectedIndex)
        }
    }
    
    private(set) var objects = [Item]() {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
        }
    }
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        collectionView.register(nibCell: PhotoVideoDetailCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isHidden = true
        
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        cancelButton.setTitle(TextConstants.backTitle, for: .normal)
        cancelButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(onCancelButton), for: .touchUpInside)
        
        let barButtonLeft = UIBarButtonItem(customView: cancelButton)
        navigationItem.leftBarButtonItem = barButtonLeft
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        OrientationManager.shared.lock(for: .all, rotateTo: .unknown)
        ItemOperationManager.default.startUpdateView(view: self)
        
        setupMoreButton()
        onStopPlay()
        rootNavController(vizible: true)
        blackNavigationBarStyle()
        editingTabBar?.view.layoutIfNeeded()
        editingTabBar.view.backgroundColor = UIColor.black
        setupTitle()
        
        if hideActions {
            editingTabBar.view.isHidden = true
        }
        
        output.viewIsReady(view: viewForBottomBar)
        setStatusBarBackgroundColor(color: UIColor.black)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setNavigationBackgroundColor(color: UIColor.clear)
        
        visibleNavigationBarStyle()
        output.viewWillDisappear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.performBatchUpdates(nil, completion: nil)
        
        if needToScrollAfterRotation {
            needToScrollAfterRotation = false
            scrollToSelectedIndex()
        }
    }
    
    @objc private func onCancelButton(){
        hideView()
    }
    
    private func hideView(){
        OrientationManager.shared.lock(for: .portrait, rotateTo: .portrait)
        dismiss(animated: true)
    }
    
    private func scrollToSelectedIndex() {
        guard !objects.isEmpty, selectedIndex < objects.count else {
            return
        }
        
        let indexPath = IndexPath(item: selectedIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    } 
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavigationBar() {
        if hideActions {
            navigationItem.rightBarButtonItem?.customView?.isHidden = true
        } else {
            guard !objects.isEmpty, selectedIndex < objects.count else {
                return
            }
            let item = objects[selectedIndex]
            navigationItem.rightBarButtonItem?.customView?.isHidden = item.isLocalItem
        }
    }
    
    private func setupMoreButton() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        let image = UIImage(named: "more")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(onRightBarButtonItem(sender:)), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        
        navigationItem.rightBarButtonItem = barButton
    }
    
    private func setupTitle() {
        guard !objects.isEmpty, selectedIndex < objects.count else {
            return
        }
        if let name = objects[selectedIndex].name {
            setTitle(withString: name)
        }
    }
    
    func onShowSelectedItem(at index: Int, from items: [PhotoVideoDetailViewInput.Item]) {
        objects = items
        selectedIndex = index
    }

    @objc func onRightBarButtonItem(sender: UIButton) {
        let stackCountViews = navigationController?.viewControllers.count ?? 0
        let inAlbumState = stackCountViews > 1 && navigationController?.viewControllers[stackCountViews - 2] is AlbumDetailViewController
        output.moreButtonPressed(sender: sender, inAlbumState: inAlbumState)   
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        needToScrollAfterRotation = true
        Device.setStatusBarHiddenForLandscapeIfNeed(isFullScreen)
    }
    
    override func getBacgroundColor() -> UIColor {
        return UIColor.black
    }
    
    @objc private func applicationDidEnterBackground(_ application: UIApplication) {
        localPlayer?.pause()
    }
}

extension PhotoVideoDetailViewController: PhotoVideoDetailViewInput {
    
    func setupInitialState() { }
    
    func onItemSelected(at index: Int, from items: [PhotoVideoDetailViewInput.Item]) {
        if items.isEmpty {
            return
        }
        
        let item = items[index]
        if item.isLocalItem && item.fileType == .image {
            setThreeDotsMenu(active: false)
        } else {
            setThreeDotsMenu(active: true)
        }
    }
    
    func setThreeDotsMenu(active isActive: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isActive
    }
    
    func play(item: AVPlayerItem) {
        MenloworksTagsService.shared.onVideoDisplayed()
        
        localPlayer?.replaceCurrentItem(with: item)
        playerController = AVPlayerViewController()
        playerController?.player = localPlayer
        present(playerController!, animated: true) { [weak playerController] in
            playerController?.player?.play()
            if Device.operationSystemVersionLessThen(11) {
                UIApplication.shared.isStatusBarHidden = true
            }
        }
    }
    
    func onStopPlay() {
        if Device.operationSystemVersionLessThen(11) {
            UIApplication.shared.isStatusBarHidden = false
        }
    }
    
    func updateItems(objectsArray: [Item], selectedIndex: Int, isRightSwipe: Bool) {
        self.objects = objectsArray
        self.selectedIndex = selectedIndex
    }
    
    func getNavigationController() -> UINavigationController? {
        return navigationController
    }
}

extension PhotoVideoDetailViewController: ItemOperationManagerViewProtocol {
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        if let compairedView = object as? PhotoVideoDetailViewController {
            return compairedView == self
        }
        return false
    }
    
    func finishedUploadFile(file: WrapData){
        output.setSelectedItemIndex(selectedIndex: selectedIndex)
        setupNavigationBar()
    }
}

extension PhotoVideoDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: PhotoVideoDetailCell.self, for: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoVideoDetailCell else { return }
        cell.delegate = self
        cell.setObject(object: objects[indexPath.row])
    }
}

extension PhotoVideoDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension PhotoVideoDetailViewController: PhotoVideoDetailCellDelegate {
    func tapOnCellForFullScreen() {
        isFullScreen = !isFullScreen
    }
    
    func tapOnSelectedItem() {
        let file = objects[selectedIndex]
        
        if file.fileType == .video {
            let preUrl = file.metaData?.videoPreviewURL ?? file.urlToFile
            guard let url = preUrl else {
                return
            }
            
            player.pause()
            playerController?.player = nil
            playerController?.removeFromParentViewController()
            playerController = nil
            localPlayer?.pause()
            localPlayer = nil
            localPlayer = AVPlayer()
            
            switch file.patchToPreview {
            case let .localMediaContent(local):
                let option = PHVideoRequestOptions()
                option.isNetworkAccessAllowed = true
                
                output.startCreatingAVAsset()
                
                DispatchQueue.global(qos: .default).async { [weak self] in
                    PHImageManager.default().requestAVAsset(forVideo: local.asset, options: option) { [weak self] (asset, _, _) in
                        
                        DispatchQueue.main.async {
                            self?.output.stopCreatingAVAsset()
                            let playerItem = AVPlayerItem(asset: asset!)
                            self?.play(item: playerItem)
                        }   
                    }
                }
                
            case .remoteUrl(_):
                let playerItem = AVPlayerItem(url:url)
                play(item: playerItem)
            }
        }
    }
    
}

extension PhotoVideoDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectedIndex()
    }
    
    // MARK: - Helper
    
    private func updateSelectedIndex() {
        let x = collectionView.contentOffset.x
        let w = collectionView.bounds.size.width
        var currentPage = Int(ceil(x/w))
        
        if currentPage >= objects.count {
            currentPage = objects.count - 1
        }
        selectedIndex = currentPage
    }
}
