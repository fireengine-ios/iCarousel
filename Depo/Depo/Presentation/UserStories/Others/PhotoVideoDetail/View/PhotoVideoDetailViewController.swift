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

class PhotoVideoDetailViewController: BaseViewController, PhotoVideoDetailViewInput, BaseFileContentViewDeleGate {
    
    typealias Item = WrapData
    
    let player: MediaPlayer = factory.resolve()

    var output: PhotoVideoDetailViewOutput!
    var interactor: PhotoVideoDetailInteractor?
    var views: [BaseFileContentView] = [BaseFileContentView]()
    var selectedIndex: Int = -1 {
        didSet {
            configureNavigationBar()
            configureEditingTabBar()
        }
    }
    var isAnimating = false
    var objects = [Item]() { didSet { configureNavigationBar() } }
    var localPlayer: AVPlayer?
    var playerController: AVPlayerViewController?
    let floatingView = FloatingView()
    
    @IBOutlet weak var shareButton: MenuButton!
    @IBOutlet weak var infoButton: MenuButton!
    @IBOutlet weak var editButton: MenuButton!
    @IBOutlet weak var deleteButton: MenuButton!
    @IBOutlet weak var viewForContent: UIView!
    var editingTabBar: BottomSelectionTabBarViewController!
    
    
    // MARK: Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configurateView()
        onStopPlay()
        rootNavController(vizible: true)
        blackNavigationBarStyle()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        editingTabBar?.view.layoutIfNeeded()
        output.viewIsReady(view: view)
        setupTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateFramesForViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        visibleNavigationBarStyle()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        floatingView.hideView(animated: true)
        output.viewWillDisappear()
    }
    
    private func configureNavigationBar() {
        if objects.count > selectedIndex, selectedIndex >= 0 {
            let item = objects[selectedIndex]
            navigationItem.rightBarButtonItem?.customView?.isHidden = !item.isSynced()
        }
    }
    
    private func configureEditingTabBar() {
        if objects.count > selectedIndex, selectedIndex >= 0,
           let editIndex = interactor?.bottomBarConfig.elementsConfig.index(of: .edit) {
            let item = objects[selectedIndex]
            
            if !item.isSynced(){
                editingTabBar.disableItems(atIntdex: [editIndex])
            } else {
                editingTabBar.enableIems(atIndex: [editIndex])
            }
        }
    }
    
    func onBack(){
        
    }
    
    func updateFramesForViews(){
        var x = -self.viewForContent.frame.size.width
        for i in 0...2{
            let view = views[i]
            view.frame = CGRect(x: x, y: 0, width: viewForContent.frame.size.width, height: viewForContent.frame.size.height)
            x = x + self.viewForContent.frame.size.width
        }
    }
    
    func configurateView(){
        
        if (views.count > 0){
            return
        }
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        viewForContent.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        viewForContent.addGestureRecognizer(swipeRight)
        
        var x = -self.viewForContent.frame.size.width
        for _ in 0...2{
            let view = BaseFileContentView.initFromXib()
            views.append(view)
            view.delegate = self
            view.frame = CGRect(x: x, y: 0, width: viewForContent.frame.size.width, height: viewForContent.frame.size.height)
            viewForContent.addSubview(view)
            x = x + self.viewForContent.frame.size.width
        }
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        let image = UIImage(named: "more")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(onRightBarButtonItem(sender:)), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            swipeRight(competition: {
                
            })
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            swipeLeft(competition: {
                
            })
        }
    }

    //<---.
    func swipeLeft(competition: @escaping ()-> Void){
        if (!isAnimating) && (selectedIndex < objects.count - 1){
            isAnimating = true
            selectedIndex = selectedIndex + 1
            output.setSelectedItemIndex(selectedIndex: selectedIndex)
            
            setVisibilityOfNotVisibleViws(visibility: true)
            UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                for view in self.views{
                    view.frame = CGRect(x: view.frame.origin.x - self.viewForContent.frame.size.width, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
                }
            }, completion: { (finished) in
                let view = self.views.first!
                view.frame = CGRect(x: self.viewForContent.frame.size.width + self.viewForContent.frame.origin.x, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
                self.views.removeFirst()
                self.views.append(view)
                
                if (self.selectedIndex < self.objects.count - 1){
                    let view = self.views.last!
                    view.setObject(object: self.objects[self.selectedIndex + 1], index: self.selectedIndex + 1)
                }
                
                self.setVisibilityOfNotVisibleViws(visibility: false)
                
                competition()
                
                self.isAnimating = false
                self.setupTitle()
            })
        }
    }
    
    //.--->
    func swipeRight(competition: @escaping ()-> Void){
        if (!isAnimating) && (selectedIndex > 0){
            isAnimating = true
            selectedIndex = selectedIndex - 1
            output.setSelectedItemIndex(selectedIndex: selectedIndex)
            setVisibilityOfNotVisibleViws(visibility: true)
            UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                for view in self.views{
                    view.frame = CGRect(x: view.frame.origin.x + self.viewForContent.frame.size.width, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
                }
            }, completion: { (finished) in
                let view = self.views.last!
                view.frame = CGRect(x: -self.viewForContent.frame.size.width, y: view.frame.origin.y, width: view.frame.size.width, height: view.frame.size.height)
                self.views.removeLast()
                self.views.insert(view, at: 0)
                
                if (self.selectedIndex > 0){
                    let view = self.views.first!
                    view.setObject(object: self.objects[self.selectedIndex - 1], index: self.selectedIndex - 1)
                }
                
                self.setVisibilityOfNotVisibleViws(visibility: false)
                
                competition()
                
                self.isAnimating = false
                self.setupTitle()
            })
        }
    }
    
    func setupTitle(){
        let obj = objects[selectedIndex]
        self.setTitle(withString: obj.name ?? "")
    }
    
    func setVisibilityOfNotVisibleViws(visibility: Bool){
        let view0 = views.first
        let view2 = views.last
        if (view0 != nil){
            view0!.isHidden = !visibility
        }
        if (view2 != nil){
            view2!.isHidden = !visibility
        }
    }
    
    func configurateAll(){
        if (selectedIndex > 0){
            let view = views.first!
            view.setObject(object: objects[selectedIndex - 1], index: selectedIndex - 1)
        }
        let view = views[1]
        view.setObject(object: objects[selectedIndex], index: selectedIndex)
        if (selectedIndex < objects.count - 1){
            let view = views.last!
            view.setObject(object: objects[selectedIndex + 1], index: selectedIndex + 1)
        }
        setVisibilityOfNotVisibleViws(visibility: false)
        setupTitle()
    }
    
    func onShowSelectedItem(at index: Int, from items: [PhotoVideoDetailViewInput.Item]) {
        if (selectedIndex != index){
            selectedIndex = index
            objects.removeAll()
            objects.append(contentsOf: items)
            
            configurateAll()
        }
    }
    
    func getActionMenyItemsForObject(object: WrapData) -> [ActionMenyItem]{
        if (object.fileType.isApplication) {
            return getActionsForDocumentObject(object: object)
        }
        return getActionsForMostPartOfObjects(object: object)
    }

    @objc func onRightBarButtonItem(sender: UIButton) {
        
        let stackCountViews = self.navigationController?.viewControllers.count ?? 0
        let inAlbumState = stackCountViews > 1 && self.navigationController?.viewControllers[stackCountViews - 2] is AlbumDetailViewController
        
        output.moreButtonPressed(sender: sender, inAlbumState: inAlbumState)

//        let actionsView = ActionsMenuView.initFromXib()
//        
//        var actions = [ActionMenyItem]()
//        let object = objects[selectedIndex]
//        actions.append(contentsOf: getActionMenyItemsForObject(object: object))
//        
//        let frame = sender.frame
//        let rect = CGRect(x: frame.origin.x, y: 20,
//                          width: frame.size.width, height: frame.size.height)
//        
//        actionsView.showActions(actions: actions)
//        
//        floatingView.showView(contentView: actionsView,
//                              animated: true,
//                              popUpSize:
//            actionsView.getSizeForView(),
//                              arrowDirection: .up,
//                              sourceRect: rect,
//                              onViewController: self)
        
    }
    
    
    // MARK: PhotoVideoDetailViewInput
    
    func setupInitialState() {
        
    }
    
    func onItemSelected(at index: Int, from items: [PhotoVideoDetailViewInput.Item]) {
    }
    
    // MARK: BaseFileContentViewDeleGate
    
    func tapOnSelectedItem(){
        let file = objects[selectedIndex]
        
        if (file.fileType == .video){
            guard let url = file.urlToFile else{
                return
            }
            
//            SingleSong.default.pause()
            player.pause()
            
            playerController?.player = nil
            playerController?.removeFromParentViewController()
            playerController = nil
            localPlayer?.pause()
            localPlayer = nil
            localPlayer = AVPlayer()
            
            switch file.patchToPreview {
            case let .localMediaContent(local):
                //localManager.getPreviewImage(asset: local.asset, image: compliteImage)
                let option = PHVideoRequestOptions()
                option.isNetworkAccessAllowed = true
                
                output.startCreatingAVAsset()
                
                DispatchQueue.global(qos: .default).async  { [weak self] in
                    PHImageManager.default().requestAVAsset(forVideo: local.asset, options: option, resultHandler: { (avAsset, avAudioMix, hash) in
                        
                        DispatchQueue.main.async {
                            self?.output.stopCreatingAVAsset()
                            
                            let plauerItem = AVPlayerItem(asset: avAsset!)
                            self?.localPlayer!.replaceCurrentItem(with: plauerItem)
                            let plController = AVPlayerViewController()
                            self?.playerController = plController
                            self?.playerController!.player = self?.localPlayer!
                            self?.present(plController, animated: true) {
                                self?.playerController?.player!.play()
                            }
                        }
                        
                    })
                }
                
                
                
//                [[PHImageManager defaultManager] requestAVAssetForVideo:videoAsset options:option resultHandler:^(AVAsset * avasset, AVAudioMix * audioMix, NSDictionary * info) {
//                    resultAsset = avasset;
//                    dispatch_semaphore_signal(semaphore);
//                    }];
                
            case .remoteUrl(_):
                
                let plauerItem = AVPlayerItem(url:url)
                localPlayer!.replaceCurrentItem(with: plauerItem)
                playerController = AVPlayerViewController()
                playerController!.player = localPlayer!
                self.present(playerController!, animated: true) { [weak playerController] in
                    playerController?.player?.play()
                }
            }

        }
    }
    
    func onStopPlay(){
//        playerController?.player = nil
//        playerController?.removeFromParentViewController()
//        playerController = nil
//        player?.pause()
//        player = nil
//        player = AVPlayer()
//        player!.replaceCurrentItem(with: nil)
    }
    
    
    //MARK actions meny 
    
    func getActionsForDocumentObject(object: WrapData) -> [ActionMenyItem]{
        var actions = [ActionMenyItem]()
        
        actions.append(ActionMenyItem.init(name: TextConstants.actionsMenuActionCopy, action: {
            [weak self] in
            self?.floatingView.hideView(animated: true)
        }))
        actions.append(ActionMenyItem.init(name: TextConstants.actionsMenuActionDocumentDetail, action: {
            [weak self] in
            self?.floatingView.hideView(animated: true)
        }))
        actions.append(ActionMenyItem.init(name: TextConstants.actionsMenuActionAddToFavorites, action: {
            [weak self] in
            self?.floatingView.hideView(animated: true)
        }))
        return actions
    }
    
    func getActionsForMostPartOfObjects(object: WrapData) -> [ActionMenyItem]{
        var actions = [ActionMenyItem]()
        
        actions.append(ActionMenyItem.init(name: TextConstants.actionsMenuActionMove, action: {
            [weak self] in
            self?.floatingView.hideView(animated: true)
        }))
        actions.append(ActionMenyItem.init(name: TextConstants.actionsMenuActionRemoveFromAlbum, action: {
            [weak self] in
            self?.floatingView.hideView(animated: true)
        }))
        actions.append(ActionMenyItem.init(name: TextConstants.actionsMenuActionAddToFavorites, action: {
            [weak self] in
            self?.floatingView.hideView(animated: true)
        }))
        actions.append(ActionMenyItem.init(name: TextConstants.actionsMenuActionDeleteDeviceOriginal, action: { [weak self] in
            self?.floatingView.hideView(animated: true)
        }))
        return actions
    }
    
    func updateItems(objectsArray: [Item], selectedIndex: Int, isRightSwipe: Bool) {
        self.selectedIndex = selectedIndex
        
        if (isRightSwipe) {
            if (self.selectedIndex == 0) {
                self.selectedIndex = 1
            }
            self.swipeRight(competition: {[weak self] in
                if let self_ = self{
                    self_.objects.removeAll()
                    self_.objects.append(contentsOf: objectsArray)
                    self_.selectedIndex = selectedIndex
                    
                    if (selectedIndex == 0){
                        return
                    }
                    
                    let view = self_.views.first!
                    view.setObject(object: self_.objects[selectedIndex - 1], index: selectedIndex - 1)
                }
            })
        } else {
            if self.selectedIndex == objectsArray.count - 1 {
                self.selectedIndex = self.selectedIndex - 1
            }
            self.swipeLeft(competition: {[weak self] in
                if let self_ = self{
                    self_.objects.removeAll()
                    self_.objects.append(contentsOf: objectsArray)
                    
                    self_.selectedIndex = selectedIndex
                    if (selectedIndex == 0){
                        return
                    }
                    let view = self_.views.first!
                    view.setObject(object: self_.objects[selectedIndex - 1], index: selectedIndex - 1)
                }
            })
        }
    }
    
    func getNavigationController() -> UINavigationController?{
        return navigationController
    }
    
}
