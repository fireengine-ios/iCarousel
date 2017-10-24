//
//  TabBarViewController.swift
//  Depo
//
//  Created by Aleksandr on 6/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

final class TabBarViewController: UIViewController, UITabBarDelegate {
    
    @IBOutlet weak var tabBar: CustomTabBar!
    
    @IBOutlet weak var plussButton: UIButton!
    
    @IBOutlet weak var curtainView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var plusButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var plusButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var musicBarContainer: UIView!
    
    @IBOutlet weak var musicBarContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    
    static let notificationHideTabBar = "HideMainTabBarNotification"
    static let notificationShowTabBar = "ShowMainTabBarNotification"
    static let notificationMusicStartedPlaying = "MusicStartedPlaying"
    static let notificationMusicDrop = "MusicDrop"
    static let notificationMusicStop = "MusicStop"
    
    let originalPlusBotttomConstraint: CGFloat = 10
    
    var photoBtn: SubPlussButtonView!
    
    fileprivate var uploadBtn: SubPlussButtonView!
    
    fileprivate var storyBtn: SubPlussButtonView!

    fileprivate var folderBtn: SubPlussButtonView!

    let musicBar = MusicBar.initFromXib()
    let player: MediaPlayer = factory.resolve()
    
    var customNavigationControllers: [UINavigationController] = []
    
    var selectedViewController: UIViewController? {
        if customNavigationControllers.count > 0 {
            return customNavigationControllers[selectedIndex]
        } else {
            return nil
        }
    }
    
    var selectedIndex: NSInteger = 0 {
        willSet {
            // will get crash 
            selectedViewController?.willMove(toParentViewController: nil)
            selectedViewController?.view.removeFromSuperview()
            selectedViewController?.removeFromParentViewController()
        }
        
        didSet {
            guard tabBar.items?.count != 0 else {
                return
            }
            addChildViewController(selectedViewController!)
            selectedViewController?.view.frame = contentView.bounds
            contentView.addSubview(selectedViewController!.view)
            selectedViewController?.didMove(toParentViewController: self)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var activeNavigationController: UINavigationController? {
        var  result: UINavigationController?
        if customNavigationControllers.count > 0 {
            result = customNavigationControllers[selectedIndex]
        }
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
        
        let items = [("outlineHome",TextConstants.home),
                     ("outlinePhotosVideos", TextConstants.photoAndVideo),
                     ("", ""),
                     ("outlineMusic", TextConstants.music),
                     ("outlineDocs",  TextConstants.documents)]
        
        tabBar.setupItems(withImageToTitleNames: items)
        
        setupCurtainView()
        setupSubButtons()
        setupCustomNavControllers()

        selectedIndex = 0
        tabBar.selectedItem = tabBar.items?.first
        
        setupMusicBar()
        
        setupObserving()
        
        player.delegates.add(self)
    }
    
    deinit {
        player.delegates.remove(self)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        
//        super.viewWillAppear(true)
//        navigationController?.navigationBar.isHidden = true
//    }
    
    private func setupMusicBar() {
        musicBarContainer.addSubview(musicBar)
        let horisontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[item1]-(0)-|",
                                                               options: [], metrics: nil,
                                                               views: ["item1" : musicBar])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[item1]-(0)-|",
                                                                   options: [], metrics: nil,
                                                                   views: ["item1" : musicBar])

        musicBarContainer.addConstraints(horisontalConstraints + verticalConstraints)
        changeVisibleStatus(hidden: true)
//        musicBar.frame = musicBarContainer.bounds
    }
    
    private func setupObserving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.hideTabBar(_:)),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationHideTabBar),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.showTabBar(_:)),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationShowTabBar),
                                               object: nil)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(self.showMusicBar(_:)),
//                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationMusicStartedPlaying),
//                                               object: nil)
//
        
        let dropNotificationName = NSNotification.Name(rawValue: TabBarViewController.notificationMusicDrop)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideMusicBar),
                                               name: dropNotificationName,
                                               object: nil)
    }
    
    @objc func showMusicBar(_ sender: Any) {
        musicBar.configurateFromPLayer()
        changeVisibleStatus(hidden: false)
        containerViewBottomConstraint.constant = musicBarContainerHeightConstraint.constant
        
    }
    
    @objc func hideMusicBar(_ sender: Any) {
        containerViewBottomConstraint.constant = 0
        changeVisibleStatus(hidden: true)
    }

    private func changeVisibleStatus(hidden: Bool) {
        musicBarContainer.isHidden = hidden
        musicBarContainer.isUserInteractionEnabled = !hidden
    }
    
    @objc private func showTabBar(_ sender: Any) {
        changeTabBarStatus(hidden: false)
    }
    
    @objc private func hideTabBar(_ sender: Any) {
        changeTabBarStatus(hidden: true)
    }
    
    private func changeTabBarStatus(hidden: Bool) {
        plussButton.isHidden = hidden
        plussButton.isEnabled = !hidden
    }
    
    @IBAction func plussBtnAction(_ sender: Any) {
        changeViewState(state: !plussButton.isSelected)
    }
    
    func changeTabBarAppearance(editingMode: Bool = false) {
        plussButton.isHidden = editingMode
        plussButton.isEnabled = !editingMode
    }
    
    func setupCustomNavControllers() {
        
        let router = RouterVC()
        
        let home = router.homePageScreen
        let nController0 = UINavigationController(rootViewController: home!)
        customNavigationControllers.append(nController0)
        
        let photosAndVideos = router.photosAndVideos
        let nController1 = UINavigationController(rootViewController: photosAndVideos!)
//        let photosAndVideos = router.albusListController()
//        let nController1 = UINavigationController(rootViewController: photosAndVideos)
        customNavigationControllers.append(nController1)
        
        let music = router.musics
        let nController2 = UINavigationController(rootViewController: music!)
        customNavigationControllers.append(nController2)
        
        let documents = router.documents
        let nController3 = UINavigationController(rootViewController: documents!)
        customNavigationControllers.append(nController3)
    
    }
    
    @objc func gearButtonAction(sender: Any) {
       // output.gearButtonGotPressed()
    }
    
    fileprivate func changeViewState(state: Bool) {
        plussButton.isSelected = state
        showCurtainView(show: state)
        if state {
            showButtonRainbow()
        } else {
            hideButtonRainbow()
        }
    }
    
    private func setupCurtainView() {
        curtainView.backgroundColor = ColorConstants.whiteColor
        curtainView.alpha = 0.88
        showCurtainView(show: false)
    }
    
    private func showCurtainView(show: Bool) {
        curtainView.isHidden = !show
        curtainView.isUserInteractionEnabled = show
        selectedViewController?.navigationItem.rightBarButtonItem?.isEnabled = !show
        selectedViewController?.navigationItem.leftBarButtonItem?.isEnabled = !show
    }
    
    func setupSubButtons() {
        
        photoBtn = createSubButton(withText: TextConstants.takePhoto,
                                   imageName: "takePhoto", asLeft: true)
        photoBtn.endCenterXconstant = photoBtn.frame.width * 0.5
        photoBtn.endBotConstant = photoBtn.frame.height
        
        uploadBtn = createSubButton(withText: TextConstants.upload,
                                    imageName: "upload", asLeft: true)
        uploadBtn.endCenterXconstant = photoBtn.frame.width * 0.25
        uploadBtn.endBotConstant = uploadBtn.frame.height * 1.8
       
        storyBtn = createSubButton(withText: TextConstants.createStory,
                                   imageName: "createStory", asLeft: false)
        storyBtn.endCenterXconstant = -photoBtn.frame.width * 0.25
        storyBtn.endBotConstant = storyBtn.frame.height * 1.8
        
        folderBtn = createSubButton(withText: TextConstants.newFolder,
                                    imageName: "newFolder", asLeft: false)
        folderBtn.endCenterXconstant = -photoBtn.frame.width * 0.5
        folderBtn.endBotConstant = folderBtn.frame.height
    }

    func createSubButton(withText text: String, imageName: String, asLeft: Bool) -> SubPlussButtonView {
        let subButton = SubPlussButtonView.getFromNib(asLeft: asLeft, withImageName: imageName, labelText: text)
        subButton?.actionDelegate = self
        view.addSubview(subButton!)
        setupOriginalPlustBtnConstraint(forView: subButton!)
        
        subButton?.changeVisability(toHidden: true)
        return subButton!
    }
    
    private func showButtonRainbow() {
        changeButtonsAppearance(toHidden: false, withAnimation: true)
    }
    
    private func hideButtonRainbow() {
        changeButtonsAppearance(toHidden: true, withAnimation: true)
    }
    
    private func changeButtonsAppearance(toHidden hidden: Bool, withAnimation animate: Bool) {
        if photoBtn.alpha == 0, hidden == true {
            return
        }
        photoBtn?.changeConstraints(asHidden: hidden)
        uploadBtn?.changeConstraints(asHidden: hidden)
        storyBtn?.changeConstraints(asHidden: hidden)
        folderBtn?.changeConstraints(asHidden: hidden)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .showHideTransitionViews, animations: {
            self.view.layoutIfNeeded()
            self.photoBtn?.changeVisability(toHidden: hidden)
            self.uploadBtn?.changeVisability(toHidden: hidden)
            self.storyBtn?.changeVisability(toHidden: hidden)
            self.folderBtn?.changeVisability(toHidden: hidden)

        }, completion: { _ in })
    }
    
    private func setupOriginalPlustBtnConstraint(forView unconstrainedView: SubPlussButtonView) {
        let centerX = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: unconstrainedView.button, attribute: .centerX, multiplier: 1, constant: 0)
        let bot = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: unconstrainedView, attribute: .bottom, multiplier: 1, constant: 10)
        unconstrainedView.centerXConstraint = centerX
        unconstrainedView.botConstraint = bot
        view.addConstraints([centerX, bot])
        view.layoutIfNeeded()
    }
    
    
    //MARK: - tab bar delegate
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)  {
        changeViewState(state: false)
        
        if var tabbarSelectedIndex = (tabBar.items?.index(of: item)) {
            
            tabBar.selectedItem = tabBar.items?[tabbarSelectedIndex]
            if tabbarSelectedIndex > 2 {
                tabbarSelectedIndex -= 1
            }
            selectedIndex = tabbarSelectedIndex
        }
    }
}

extension TabBarViewController: SubPlussButtonViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func buttonGotPressed(button: SubPlussButtonView) {
        changeViewState(state: false)
        if (button == photoBtn ){
           let cameraService = CameraService()
            cameraService.showCamera(onViewController: self)
            
            return
        }
        if (button == folderBtn){
            let router = RouterVC()
            
//            let controller = router.createNewAlbum()
//            router.pushViewController(viewController: controller)
//            return
            
            let isFavorites = router.isOnFavoritesView()
            let controller = router.createNewFolder(rootFolderID: getFolderUUID(), isFavorites: isFavorites)
            router.pushViewController(viewController: controller)
            return
        }
        if (button == storyBtn){
            let router = RouterVC()
            router.createStoryName()
            return
        }
        if (button == uploadBtn){
            let router = RouterVC()
            let controller = router.uploadPhotos()
            router.pushViewController(viewController: controller)
            return
        }
    }
    
    func getDataSource() -> RemoteItemsService{
        var searchService: RemoteItemsService? = nil
        if let nController = selectedViewController as? UINavigationController{
            let viewConroller = nController.viewControllers.last
            if let contr = viewConroller as? BaseFilesGreedViewController{
                searchService = contr.getRemoteItemsService()
            }
        }
        
        if (searchService == nil){
            searchService = AllFilesService(requestSize: 999)
        }
        
        return searchService!
    }
    
    func getFolderUUID() -> String?{
        if let nController = selectedViewController as? UINavigationController{
            let viewConroller = nController.viewControllers.last
            if let contr = viewConroller as? BaseFilesGreedViewController{
                if let folder = contr.getFolder(){
                    return folder.uuid
                }
            }
        }
        return nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        // TODO: Alex need upload 
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
}

extension TabBarViewController: MediaPlayerDelegate {
    func mediaPlayer(_ mediaPlayer: MediaPlayer, didStartItemWith duration: Float) {
        showMusicBar(())
    }
    func mediaPlayer(_ musicPlayer: MediaPlayer, changedCurrentTime time: Float) {}
    func didStartMediaPlayer(_ mediaPlayer: MediaPlayer) {}
    func didStopMediaPlayer(_ mediaPlayer: MediaPlayer) {}
}
