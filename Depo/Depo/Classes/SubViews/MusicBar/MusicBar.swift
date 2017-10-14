//
//  MusicBar.swift
//  Depo
//
//  Created by Aleksandr on 8/11/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class MusicBar: UIView, VisualMusicPlayerViewControllerDelegate, PlayerDelegate {
    
    @IBOutlet weak var gradientView: GradientView!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var zoomUpButton: UIButton!
    
    @IBOutlet weak var musicNameLabel: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var progressViewContainer: UIView!
    
    private var insideProgressClousure: PlayerProgressClousure!
    private var outsideProgressClousure: PlayerProgressClousure?
    
    private let playerFullScreenVC = VisualMusicPlayerViewController(nibName: "VisualMusicPlayerViewController", bundle: nil)
    
    class func initFromXib() -> MusicBar{
        let view = UINib(nibName: "MusicBar", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MusicBar
        view.setupItinialConfig()
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupItinialConfig()
    }
    
    func setupItinialConfig() {
        translatesAutoresizingMaskIntoConstraints = false
        
        gradientView.setup(withFrame: CGRect(x: 0, y: 0,
                                             width: Device.winSize.width,
                                             height: bounds.height),
                           startColor: UIColor.lrRedOrange,
                           endColoer: UIColor.lrYellowSun,
                           startPoint: CGPoint(x: 0, y: 0.5),
                           endPoint: CGPoint(x: 1, y: 0.5))
        addSwipeRecognition()
        
        playerFullScreenVC.delegate = self
        playerFullScreenVC.isModalInPopover = false
        
        setupPlayerProgress()
        
        playerFullScreenVC.view.layoutIfNeeded()//.layoutIfNeeded()
        
        SingleSong.default.delegate = self
    }
    
    private func setupPlayerProgress() {
        insideProgressClousure = { [weak self] time in
            
            self?.playerFullScreenVC.setProgress(secondsPassed: time.seconds)
            
        }
        
        SingleSong.default.addProgressClousure(progressClousure: insideProgressClousure)
    }
    
    private func addSwipeRecognition() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.addGestureRecognizer(swipeRight)
        
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.left
        self.addGestureRecognizer(swipeLeft)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                UIView.animate(withDuration: 0.1, animations: {
                    self.frame.origin.x = self.frame.origin.x + Device.winSize.width
                }, completion: { _ in
                     self.removePlayer()
                })
                
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
                UIView.animate(withDuration: 0.1, animations: {
                    self.frame.origin.x = self.frame.origin.x - Device.winSize.width
                }, completion: { _ in
                    self.removePlayer()
                })
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    private func removePlayer() {
        SingleSong.default.stop()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationMusicDrop), object: nil)
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        
        changePlayPauseState(selected: !playPauseButton.isSelected)
    }
    
    private func changePlayPauseState(selected: Bool) {
        playPauseButton.isSelected = selected
        if !playPauseButton.isSelected {
            SingleSong.default.play()
        } else {
            SingleSong.default.pause()
        }
    }
    
    @IBAction func zoomUpAction(_ sender: Any) {
        
//        let playerNAVController = UINavigationController(rootViewController: playerVC)
//        playerNAVController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        let backButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(self.dismissCaller(sender:)))
//        backButtonItem.title = "Cancel"
//        backButtonItem.tintColor = UIColor.white
//        playerNAVController.navigationItem.backBarButtonItem = backButtonItem
        
        
//        playerFullScreenVC.isPlaying = !playPauseButton.isSelected
        
        playerFullScreenVC.setupPlayerConfig()
        let router = RouterVC()
        router.rootViewController?.present(playerFullScreenVC, animated: true, completion: nil)
    }
    
    func dismissCaller(sender: Any) {
        
    }
    
    func configurateFromPLayer() {
        guard let currentItem = SingleSong.default.getCurrentItemModel() else {
            return
        }
        playPauseButton.isSelected = false
        if let metadata = currentItem.metaData, let actualMeta = metadata.medaData as? MusicMetaData {
            
            if let name = actualMeta.title {
                musicNameLabel.text = name
            }
            if let artist = actualMeta.artist {
                artistLabel.text = artist
            }
            
        }
        frame.origin.x = 0
    }
    
    
    //MARK: - FullScreen Player delegate
    
    func playPauseButtonGotSelected(selected: Bool) {
        playPauseButton.isSelected = selected
    }
    
    
    //MARK: - Player delegate 
    
    func itemStoppedPlaying(currentItem: Item) {
         playPauseButton.isSelected = !SingleSong.default.isPlaying()
//        playerFullScreenVC.playPauseButton.isSelected = !SingleSong.default.isPlaying()
    }
    
    func itemStartedPlaying(currentItem: Item) {
         playPauseButton.isSelected = SingleSong.default.isPlaying()
//        playerFullScreenVC.playPauseButton.isSelected = SingleSong.default.isPlaying()
    }
    
    func trackChanged() {
        playerFullScreenVC.setupPlayerConfig()
//        debugPrint("MUSIC BAR: trackChanged")
        configurateFromPLayer()
    }
}
