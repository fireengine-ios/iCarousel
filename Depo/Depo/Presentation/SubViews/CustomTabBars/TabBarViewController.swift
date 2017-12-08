//
//  TabBarViewController.swift
//  Depo
//
//  Created by Aleksandr on 6/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

enum FloatingButtonsType: String {
    case floatingButtonTakeAPhoto = "Take a Photo"
    case floatingButtonUpload = "Upload"
    case floatingButtonCreateAStory = "Create a Story"
    case floatingButtonNewFolder = "New Folder"
    case floatingButtonCreateAlbum = "Create album"
    case floatingButtonUploadFromLifebox = "Upload from lifebox"
}

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
    
    @IBOutlet weak var bottomTabBarConstraint: NSLayoutConstraint!
    
    static let notificationHidePlusTabBar = "HideMainTabBarPlusNotification"
    static let notificationShowPlusTabBar = "ShowMainTabBarPlusNotification"
    static let notificationHideTabBar = "HideMainTabBarNotification"
    static let notificationShowTabBar = "ShowMainTabBarNotification"
    static let notificationMusicStartedPlaying = "MusicStartedPlaying"
    static let notificationMusicDrop = "MusicDrop"
    static let notificationMusicStop = "MusicStop"
    
    let originalPlusBotttomConstraint: CGFloat = 10
    
    fileprivate var photoBtn            : SubPlussButtonView!
    fileprivate var uploadBtn           : SubPlussButtonView!
    fileprivate var storyBtn            : SubPlussButtonView!
    fileprivate var folderBtn           : SubPlussButtonView!
    fileprivate var albumBtn            : SubPlussButtonView!
    fileprivate var uploadFromLifebox   : SubPlussButtonView!

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
    }
    
    private func setupObserving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.hidePlusTabBar(_:)),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationHidePlusTabBar),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.showPlusTabBar(_:)),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationShowPlusTabBar),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.hideTabBar(_:)),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationHideTabBar),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.showTabBar(_:)),
                                               name: NSNotification.Name(rawValue: TabBarViewController.notificationShowTabBar),
                                               object: nil)
        
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
    
    @objc private func showPlusTabBar(_ sender: Any) {
        if (bottomTabBarConstraint.constant >= 0){
            changeTabBarStatus(hidden: false)
        }
    }
    
    @objc private func hidePlusTabBar(_ sender: Any) {
        if (bottomTabBarConstraint.constant == 0){
            changeTabBarStatus(hidden: true)
        }
    }
    
    @objc private func showTabBar(_ sender: Any) {
        changeTabBarStatus(hidden: false)
        //tabBar.isHidden = false
        if (self.bottomTabBarConstraint.constant < 0){
            if #available(iOS 10.0, *) {
                let obj = UIViewPropertyAnimator(duration: NumericConstants.animationDuration, curve: .linear) {
                    self.bottomTabBarConstraint.constant = 0
                    self.tabBar.layoutIfNeeded()
                }
                obj.startAnimation()
            } else {
                UIView.animate(withDuration: NumericConstants.animationDuration) {
                    self.bottomTabBarConstraint.constant = 0
                    self.tabBar.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc private func hideTabBar(_ sender: Any) {
        changeTabBarStatus(hidden: true)
        if (bottomTabBarConstraint.constant >= 0){
            if #available(iOS 10.0, *) {
                let obj = UIViewPropertyAnimator(duration: NumericConstants.animationDuration, curve: .linear) {
                    self.bottomTabBarConstraint.constant = -self.tabBar.frame.height
                    self.tabBar.layoutIfNeeded()
                }
                obj.startAnimation()
            } else {
                UIView.animate(withDuration: NumericConstants.animationDuration) {
                    self.bottomTabBarConstraint.constant = -self.tabBar.frame.height
                    self.tabBar.layoutIfNeeded()
                }
            }
        }
        
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
        let list = [router.homePageScreen,
                    router.photosAndVideos,
                    router.musics,
                    router.documents]
        customNavigationControllers = list.flatMap{ UINavigationController(rootViewController: $0!)}
    }
    
    @objc func gearButtonAction(sender: Any) {
       // output.gearButtonGotPressed()
    }
    
    fileprivate func changeViewState(state: Bool) {
        plussButton.isSelected = state
        
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            if state{
                self.plussButton.transform = CGAffineTransform(rotationAngle: .pi/4)
            }else{
                self.plussButton.transform = CGAffineTransform(rotationAngle: 0)
            }
        }
        
        showCurtainView(show: state)
        if state {
            showButtonRainbow()
        } else {
            hideButtonRainbow()
        }
    }
    
    private func setupCurtainView() {
        
        let fr = CGRect(x: 0, y: 10, width: 1024, height: 1024)
        let circleView = UIView(frame:fr )
        circleView.backgroundColor = UIColor.blue
        curtainView.addSubview(circleView)
        curtainView.layer.mask = circleView.layer
        curtainView.layer.masksToBounds = true
        
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
        
        photoBtn = createSubButton(withText: TextConstants.takePhoto, imageName: "TakeFhoto", asLeft: true)
        photoBtn?.changeVisability(toHidden: true)
        
        uploadBtn = createSubButton(withText: TextConstants.upload, imageName: "Upload", asLeft: true)
        uploadBtn?.changeVisability(toHidden: true)
        
        storyBtn = createSubButton(withText: TextConstants.createStory, imageName: "CreateAStory", asLeft: false)
        storyBtn?.changeVisability(toHidden: true)
        
        folderBtn = createSubButton(withText: TextConstants.newFolder, imageName: "NewFolder", asLeft: false)
        folderBtn?.changeVisability(toHidden: true)
        
        uploadFromLifebox = createSubButton(withText: TextConstants.uploadFromLifebox, imageName: "NewFolder", asLeft: false)
        uploadFromLifebox?.changeVisability(toHidden: true)
        
        albumBtn = createSubButton(withText: TextConstants.createAlbum, imageName: "NewFolder", asLeft: false)
        albumBtn?.changeVisability(toHidden: true)
        
        view.bringSubview(toFront: plussButton)
    }

    func createSubButton(withText text: String, imageName: String, asLeft: Bool) -> SubPlussButtonView? {
        if let subButton = SubPlussButtonView.getFromNib(asLeft: asLeft, withImageName: imageName, labelText: text){
            subButton.actionDelegate = self
            view.addSubview(subButton)
            
            subButton.translatesAutoresizingMaskIntoConstraints = false
            
            subButton.bottomConstraint = NSLayoutConstraint(item: subButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            subButton.bottomConstraintOrigialConstant = 0
            
            subButton.centerXConstraint = NSLayoutConstraint(item: subButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
            subButton.centerXConstraintOriginalConstant = 0
            
            var constraintsArray = [NSLayoutConstraint]()
            constraintsArray.append(subButton.bottomConstraint!)
            constraintsArray.append(subButton.centerXConstraint!)
            constraintsArray.append(NSLayoutConstraint(item: subButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80))
            constraintsArray.append(NSLayoutConstraint(item: subButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 65))
            NSLayoutConstraint.activate(constraintsArray)
            
            view.layoutIfNeeded()
            
            return subButton
        }
        
        return nil
    }
    
    private func getFloatingButtonsArray()-> [SubPlussButtonView]{
        let array = RouterVC().getFloatingButtonsArray()
        var buttonsArray = [SubPlussButtonView]()
        for type in array{
            switch type{
            case .floatingButtonCreateAlbum:
                buttonsArray.append(albumBtn)
            case .floatingButtonCreateAStory:
                buttonsArray.append(storyBtn)
            case .floatingButtonNewFolder:
                buttonsArray.append(folderBtn)
            case .floatingButtonTakeAPhoto:
                buttonsArray.append(photoBtn)
            case .floatingButtonUpload:
                buttonsArray.append(uploadBtn)
            case .floatingButtonUploadFromLifebox:
                buttonsArray.append(uploadFromLifebox)
            }
        }
        
        if (buttonsArray.count == 0) || (buttonsArray.count > 4){
            return [SubPlussButtonView]()
        }
        
        return buttonsArray
    }
    
    private func getAllFloatingButtonsArray()-> [SubPlussButtonView]{
        var buttonsArray = [SubPlussButtonView]()
        buttonsArray.append(albumBtn)
        buttonsArray.append(storyBtn)
        buttonsArray.append(folderBtn)
        buttonsArray.append(photoBtn)
        buttonsArray.append(uploadBtn)
        buttonsArray.append(uploadFromLifebox)
        return buttonsArray
    }
    
    static let bottomSpace: CGFloat = 7
    static let spaceBeetwenbuttons: CGFloat = 3
    
    private func showButtonRainbow() {
        
        let buttonsArray = getFloatingButtonsArray()
        let count = buttonsArray.count
        
        if count == 1{
            let obj0 = buttonsArray[0]
            obj0.centerXConstraint!.constant = 0
            obj0.bottomConstraint!.constant = -obj0.frame.size.height - tabBar.frame.size.height - TabBarViewController.bottomSpace
        }
        if count == 2{
            let obj0 = buttonsArray[0]
            let obj1 = buttonsArray[1]
            
            obj0.centerXConstraint!.constant = -obj0.frame.size.width * 0.75
            obj0.bottomConstraint!.constant = -obj0.frame.size.height * 0.75 - tabBar.frame.size.height - TabBarViewController.bottomSpace - TabBarViewController.spaceBeetwenbuttons
            
            obj1.centerXConstraint!.constant = obj0.frame.size.width * 0.75
            obj1.bottomConstraint!.constant = -obj0.frame.size.height * 0.75 - tabBar.frame.size.height - TabBarViewController.bottomSpace - TabBarViewController.spaceBeetwenbuttons
        }
        if count == 3{
            let obj0 = buttonsArray[0]
            let obj1 = buttonsArray[1]
            let obj2 = buttonsArray[2]
            
            obj0.centerXConstraint!.constant = -obj0.frame.size.width
            obj0.bottomConstraint!.constant = -tabBar.frame.size.height - TabBarViewController.bottomSpace
            
            obj1.centerXConstraint!.constant = 0
            obj1.bottomConstraint!.constant = -obj0.frame.size.height - tabBar.frame.size.height - TabBarViewController.bottomSpace - TabBarViewController.spaceBeetwenbuttons
            
            obj2.centerXConstraint!.constant = obj0.frame.size.width
            obj2.bottomConstraint!.constant = -tabBar.frame.size.height - TabBarViewController.bottomSpace
        }
        if count == 4{
            let obj0 = buttonsArray[0]
            let obj1 = buttonsArray[1]
            let obj2 = buttonsArray[2]
            let obj3 = buttonsArray[3]
            
            obj0.centerXConstraint!.constant = -obj0.frame.size.width
            obj0.bottomConstraint!.constant = -tabBar.frame.size.height - TabBarViewController.bottomSpace
            
            obj1.centerXConstraint!.constant = -obj0.frame.size.width * 0.5
            obj1.bottomConstraint!.constant = -obj0.frame.size.height - tabBar.frame.size.height - TabBarViewController.bottomSpace - TabBarViewController.spaceBeetwenbuttons
            
            obj2.centerXConstraint!.constant = obj0.frame.size.width * 0.5
            obj2.bottomConstraint!.constant = -obj3.frame.size.height - tabBar.frame.size.height - TabBarViewController.bottomSpace - TabBarViewController.spaceBeetwenbuttons
            
            obj3.centerXConstraint!.constant = obj0.frame.size.width
            obj3.bottomConstraint!.constant = -tabBar.frame.size.height - TabBarViewController.bottomSpace
            
            
        }
        changeButtonsAppearance(toHidden: false, withAnimation: true, forButtons: buttonsArray)
        //view.layoutIfNeeded()
    }
    
    private func hideButtonRainbow() {
        let buttonsArray = getAllFloatingButtonsArray()
        changeButtonsAppearance(toHidden: true, withAnimation: true, forButtons: buttonsArray)
    }
    
    private func changeButtonsAppearance(toHidden hidden: Bool, withAnimation animate: Bool, forButtons buttons:[SubPlussButtonView]) {
        if buttons.count == 0 {
            return
        }
        
        UIView.animate(withDuration: NumericConstants.animationDuration, delay: 0.0, options: .showHideTransitionViews, animations: {
            for button in buttons{
                button.changeVisability(toHidden: hidden)
            }
            self.view.layoutIfNeeded()
        }, completion: { _ in })
    }
    
    private func setupOriginalPlustBtnConstraint(forView unconstrainedView: SubPlussButtonView) {
//        let centerX = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: unconstrainedView.button, attribute: .centerX, multiplier: 1, constant: 0)
//        let bot = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: unconstrainedView, attribute: .bottom, multiplier: 1, constant: 10)
//        unconstrainedView.centerXConstraint = centerX
//        unconstrainedView.botConstraint = bot
//        view.addConstraints([centerX, bot])
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
            let nController = UINavigationController(rootViewController: controller)
            router.presentViewController(controller: nController)
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
            let navigation = UINavigationController(rootViewController: controller)
            
            navigation.navigationBar.isHidden = false
            router.presentViewController(controller: navigation)
            
            return
        }
        if (button == albumBtn){
            //создание альбома
            let router = RouterVC()
            let controller = router.createNewAlbum()
            let nController = UINavigationController(rootViewController: controller)
            router.presentViewController(controller: nController)
            return
        }
        if (button == uploadFromLifebox){
            //копия файла в текущую папку на сервере
            let router = RouterVC()
            let parentFolder = router.getParentUUID()
            let controller = router.uploadFromLifeBox(folderUUID: parentFolder)
            let navigationController = UINavigationController(rootViewController: controller)
            navigationController.navigationBar.isHidden = false
            
            router.presentViewController(controller: navigationController)
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
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let data = UIImageJPEGRepresentation(image.imageWithFixedOrientation, 0.9)
            else { return }
        
        /// IF WILL BE NEED TO SAVE FILE
        //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        WrapItemOperatonManager.default.startOperationWith(type: .upload, allOperations: 1, completedOperations: 0)
        let parentUUID = RouterVC().getParentUUID()
        let isPhotoAlbum = RouterVC().isRootViewControllerAlbumDetail()
        let isFavorites = RouterVC().isOnFavoritesView()
        UploadService.default.upload(imageData: data, parentUUID: parentUUID, isFaorites: isFavorites) { result in
            WrapItemOperatonManager.default.stopOperationWithType(type: .upload)
            switch result {
            case .success(let fhotoUploadResponce):
                DispatchQueue.main.async {
                    CustomPopUp.sharedInstance.showCustomInfoAlert(withTitle: "Success", withText: "Photo uploaded", okButtonText: "OK")
                }
                
                if isPhotoAlbum{
                    let item = Item.init(remote: fhotoUploadResponce)
                    let parameter = AddPhotosToAlbum(albumUUID: parentUUID, photos: [item])
                    PhotosAlbumService().addPhotosToAlbum(parameters: parameter, success: {
                        
                    }, fail: { (error) in
                        
                    })
                }
                
            case .failed(let error):
                DispatchQueue.main.async {
                    CustomPopUp.sharedInstance.showCustomAlert(withText: error.localizedDescription, okButtonText: "OK")
                }
            }
            
        }
        
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
