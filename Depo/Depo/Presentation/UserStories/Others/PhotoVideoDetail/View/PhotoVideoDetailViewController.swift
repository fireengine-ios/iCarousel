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

//BaseFileContentViewDelegate
class PhotoVideoDetailViewController: BaseViewController, PhotoVideoDetailViewInput {
    
    typealias Item = WrapData
    
    var output: PhotoVideoDetailViewOutput!
    
    lazy var player: MediaPlayer = factory.resolve()
 
    var views: [BaseFileContentView] = [BaseFileContentView]()
    var selectedIndex: Int = -1 {
        didSet {
            if objects.isEmpty, selectedIndex > objects.count - 1 {
                return
            }
            configureNavigationBar()
            setupTitle()
            output.setSelectedItemIndex(selectedIndex: selectedIndex)
        }
    }
    var isAnimating = false
    var objects = [Item]() {
        didSet {
            
            configureNavigationBar()
            //collectionView.collectionViewLayout.invalidateLayout()
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            
            if objects.isEmpty, selectedIndex > objects.count - 1 {
                return
            }
            
            let indexPath = IndexPath(item: selectedIndex, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
        
    }
    var localPlayer: AVPlayer?
    var playerController: AVPlayerViewController?
    let floatingView = FloatingView()
    var hideActions = false
    
    @IBOutlet weak var shareButton: MenuButton!
    @IBOutlet weak var infoButton: MenuButton!
    @IBOutlet weak var editButton: MenuButton!
    @IBOutlet weak var deleteButton: MenuButton!
    @IBOutlet weak var viewForContent: UIView!
    var editingTabBar: BottomSelectionTabBarViewController!
    
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView.register(nibCell: PhotoVideoDetailCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.delaysContentTouches = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ItemOperationManager.default.startUpdateView(view: self)
        OrientationManager.shared.lock(for: .all, rotateTo: .unknown)
        configurateView()
        onStopPlay()
        rootNavController(vizible: true)
        blackNavigationBarStyle()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        editingTabBar?.view.layoutIfNeeded()
        editingTabBar.view.backgroundColor = UIColor.black
        output.viewIsReady(view: view)
        setupTitle()
        
        if hideActions {
            editingTabBar.view.isHidden = true
        }
    }
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setNavigationBackgroundColor(color: UIColor.clear)
        setStatusBarBackgroundColor(color: UIColor.clear)
        visibleNavigationBarStyle()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        floatingView.hideView(animated: true)
        output.viewWillDisappear()
        
        /// set previous state of orientation or any new one
        OrientationManager.shared.lock(for: .portrait, rotateTo: .portrait)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        updateFramesForViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        updateFramesForViews()
        
        
        
//        if let indexPath = indexPath {
//            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
//            self.indexPath = nil
//            //            collectionView.performBatchUpdates({}, completion: nil)
//        }
        
        if objects.isEmpty, selectedIndex > objects.count - 1 {
            return
        }
        
        let indexPath = IndexPath(item: selectedIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
    
    private func configureNavigationBar() {
        if objects.count > selectedIndex, selectedIndex >= 0 {
            let item = objects[selectedIndex]
            if hideActions {
                navigationItem.rightBarButtonItem?.customView?.isHidden = true
            } else {
                navigationItem.rightBarButtonItem?.customView?.isHidden = item.isLocalItem
            }
        }
    }
    
//    func onBack() {
//        
//    }
    
//    func updateFramesForViews(){
//        var x = -self.viewForContent.frame.size.width
//        for i in 0...2 {
//            let view = views[i]
//            view.frame = CGRect(x: x, y: 0, width: viewForContent.frame.size.width, height: viewForContent.frame.size.height)
//            x = x + self.viewForContent.frame.size.width
//        }
//    }
    
    func configurateView() {
        
        if (views.count > 0) {
            return
        }
        
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
//        swipeLeft.direction = .left
//        viewForContent.addGestureRecognizer(swipeLeft)
//        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
//        swipeRight.direction = .right
//        viewForContent.addGestureRecognizer(swipeRight)
//        
//        var x = -self.viewForContent.frame.size.width
//        for _ in 0...2 {
//            let view = BaseFileContentView.initFromXib()
//            views.append(view)
//            view.delegate = self
//            view.frame = CGRect(x: x, y: 0, width: viewForContent.frame.size.width, height: viewForContent.frame.size.height)
//            viewForContent.addSubview(view)
//            x = x + self.viewForContent.frame.size.width
//        }
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        let image = UIImage(named: "more")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(onRightBarButtonItem(sender:)), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.rightBarButtonItem = barButton
    }
    
//    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
//        if gesture.direction == UISwipeGestureRecognizerDirection.right {
//            swipeRight(competition: {
//                
//            })
//        }
//        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
//            swipeLeft(competition: {
//                
//            })
//        }
//    }

    //<---.
//    func swipeLeft(competition: @escaping ()-> Void){
//        if (!isAnimating) && (selectedIndex < objects.count - 1) {
//            isAnimating = true
//            selectedIndex = selectedIndex + 1
//            output.setSelectedItemIndex(selectedIndex: selectedIndex)
//            
//            setVisibilityOfNotVisibleViws(visibility: true)
//            UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
//                for view in self.views {
//                    view.frame = CGRect(x: view.frame.origin.x - self.viewForContent.frame.size.width, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
//                }
//            }, completion: { (finished) in
//                let view = self.views.first!
//                view.frame = CGRect(x: self.viewForContent.frame.size.width + self.viewForContent.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
//                self.views.removeFirst()
//                self.views.append(view)
//                
//                if (self.selectedIndex < self.objects.count - 1){
//                    let view = self.views.last!
//                    view.setObject(object: self.objects[self.selectedIndex + 1], index: self.selectedIndex + 1)
//                }
//                
//                self.setVisibilityOfNotVisibleViws(visibility: false)
//                
//                competition()
//                
//                self.isAnimating = false
//                self.setupTitle()
//            })
//        }
//    }
    
    //.--->
//    func swipeRight(competition: @escaping ()-> Void) {
//        if (!isAnimating) && (selectedIndex > 0){
//            isAnimating = true
//            selectedIndex = selectedIndex - 1
//            output.setSelectedItemIndex(selectedIndex: selectedIndex)
//            setVisibilityOfNotVisibleViws(visibility: true)
//            UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
//                for view in self.views{
//                    view.frame = CGRect(x: view.frame.origin.x + self.viewForContent.frame.size.width, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
//                }
//            }, completion: { (finished) in
//                let view = self.views.last!
//                view.frame = CGRect(x: -self.viewForContent.frame.size.width, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
//                self.views.removeLast()
//                self.views.insert(view, at: 0)
//                
//                if (self.selectedIndex > 0){
//                    let view = self.views.first!
//                    view.setObject(object: self.objects[self.selectedIndex - 1], index: self.selectedIndex - 1)
//                }
//                
//                self.setVisibilityOfNotVisibleViws(visibility: false)
//                
//                competition()
//                
//                self.isAnimating = false
//                self.setupTitle()
//            })
//        }
//    }
    
    func setupTitle() {
        let obj = objects[selectedIndex]
        self.setTitle(withString: obj.name ?? "")
    }
    
//    func setVisibilityOfNotVisibleViws(visibility: Bool) {
//        let view0 = views.first
//        let view2 = views.last
//        if (view0 != nil){
//            view0!.isHidden = !visibility
//        }
//        if (view2 != nil){
//            view2!.isHidden = !visibility
//        }
//    }
    
    func configurateAll() {
//        if (selectedIndex > 0) {
//            let view = views.first!
//            view.setObject(object: objects[selectedIndex - 1], index: selectedIndex - 1)
//        }
//        let view = views[1]
//        view.setObject(object: objects[selectedIndex], index: selectedIndex)
//        if (selectedIndex < objects.count - 1) {
//            let view = views.last!
//            view.setObject(object: objects[selectedIndex + 1], index: selectedIndex + 1)
//        }
//        setVisibilityOfNotVisibleViws(visibility: false)
        setupTitle()
    }
    
    func onShowSelectedItem(at index: Int, from items: [PhotoVideoDetailViewInput.Item]) {
        if (selectedIndex != index) {
            selectedIndex = index
            objects.removeAll()
            objects.append(contentsOf: items)
            
            configurateAll()
        }
    }

    @objc func onRightBarButtonItem(sender: UIButton) {
        
        let stackCountViews = self.navigationController?.viewControllers.count ?? 0
        let inAlbumState = stackCountViews > 1 && self.navigationController?.viewControllers[stackCountViews - 2] is AlbumDetailViewController
        
        output.moreButtonPressed(sender: sender, inAlbumState: inAlbumState)   
    }
    
    
    // MARK: PhotoVideoDetailViewInput
    
    func setupInitialState() {
        
    }
    
    func onItemSelected(at index: Int, from items: [PhotoVideoDetailViewInput.Item]) {
        let item = items[index]
        if item.isLocalItem && item.fileType == .image{
            setThreeDotsMenu(active: false)
        }else{
            setThreeDotsMenu(active: true)
        }
    }
    
    func setThreeDotsMenu(active isActive: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isActive
    }
    
    // MARK: BaseFileContentViewDeleGate
    
//    func tapOnSelectedItem() {
//        let file = objects[selectedIndex]
//        
//        if (file.fileType == .video) {
//            guard let url = file.urlToFile else{
//                return
//            }
//            
//            player.pause()
//            
//            playerController?.player = nil
//            playerController?.removeFromParentViewController()
//            playerController = nil
//            localPlayer?.pause()
//            localPlayer = nil
//            localPlayer = AVPlayer()
//            
//            switch file.patchToPreview {
//            case let .localMediaContent(local):
//                let option = PHVideoRequestOptions()
//                option.isNetworkAccessAllowed = true
//                
//                output.startCreatingAVAsset()
//                
//                DispatchQueue.global(qos: .default).async  { [weak self] in
//                    PHImageManager.default().requestAVAsset(forVideo: local.asset, options: option, resultHandler: { [weak self] (avAsset, avAudioMix, hash) in
//                        
//                        DispatchQueue.main.async {
//                            self?.output.stopCreatingAVAsset()
//                            
//                            let playerItem = AVPlayerItem(asset: avAsset!)
//                            self?.play(item: playerItem)
//                        }
//                        
//                    })
//                }
//                
//            case .remoteUrl(_):
//                let playerItem = AVPlayerItem(url:url)
//                play(item: playerItem)
//            }
//
//        }
//    }
    
    func play(item: AVPlayerItem) {
        localPlayer!.replaceCurrentItem(with: item)
        playerController = AVPlayerViewController()
        playerController!.player = localPlayer!
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
        self.selectedIndex = selectedIndex
        
//        if (isRightSwipe) {
//            if (self.selectedIndex == 0) {
//                self.selectedIndex = 1
//            }
//            self.swipeRight(competition: {[weak self] in
//                if let self_ = self {
//                    self_.objects.removeAll()
//                    self_.objects.append(contentsOf: objectsArray)
//                    self_.selectedIndex = selectedIndex
//                    
//                    if (selectedIndex == 0) {
//                        return
//                    }
//                    
//                    let view = self_.views.first!
//                    view.setObject(object: self_.objects[selectedIndex - 1], index: selectedIndex - 1)
//                }
//            })
//        } else {
//            if self.selectedIndex == objectsArray.count - 1 {
//                self.selectedIndex = self.selectedIndex - 1
//            }
//            self.swipeLeft(competition: {[weak self] in
//                if let self_ = self {
//                    self_.objects.removeAll()
//                    self_.objects.append(contentsOf: objectsArray)
//                    
//                    self_.selectedIndex = selectedIndex
//                    if (selectedIndex == 0) {
//                        return
//                    }
//                    let view = self_.views.first!
//                    view.setObject(object: self_.objects[selectedIndex - 1], index: selectedIndex - 1)
//                }
//            })
//        }
    }
    
    func getNavigationController() -> UINavigationController? {
        return navigationController
    }
    
//    func pageToRight() {
//        swipeLeft(competition: {})
//    }
//    
//    func pageToLeft() {
//        swipeRight(competition: {})
//    }
    
    
    
    
    
    
    
    
    
    
    


    var indexPath: IndexPath?
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
//        var offestPoint = self.collectionView.contentOffset
//        offestPoint.x += self.collectionView.center.x
//        collectionView.layoutIfNeeded()
//        indexPath = self.collectionView.indexPathForItem(at: offestPoint)
        collectionView.collectionViewLayout.invalidateLayout()
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
        configureNavigationBar()
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
//        let object = objects[indexPath.row]
        cell.delegate = self
        cell.setObject(object: objects[indexPath.row], index: indexPath.row)
    }
}

extension PhotoVideoDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension PhotoVideoDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension PhotoVideoDetailViewController: PhotoVideoDetailCellDelegate {
    func tapOnSelectedItem() {
        let file = objects[selectedIndex]
        
        if (file.fileType == .video) {
            guard let url = file.urlToFile else{
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
                
                DispatchQueue.global(qos: .default).async  { [weak self] in
                    PHImageManager.default().requestAVAsset(forVideo: local.asset, options: option, resultHandler: { [weak self] (avAsset, avAudioMix, hash) in
                        
                        DispatchQueue.main.async {
                            self?.output.stopCreatingAVAsset()
                            
                            let playerItem = AVPlayerItem(asset: avAsset!)
                            self?.play(item: playerItem)
                        }
                        
                    })
                }
                
            case .remoteUrl(_):
                let playerItem = AVPlayerItem(url:url)
                play(item: playerItem)
            }

        }
    }
    
    func pageToRight() {
        
    }
    
    func pageToLeft() {
        
    }
    
    
}

extension PhotoVideoDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = collectionView.contentOffset.x
        let w = collectionView.bounds.size.width
        var currentPage = Int(ceil(x/w))
        
        if currentPage >= objects.count {
            currentPage = objects.count - 1
        }
        print(currentPage)
        
//        let viewObject = objects[currentPage]
        
        selectedIndex = currentPage
    }
}






