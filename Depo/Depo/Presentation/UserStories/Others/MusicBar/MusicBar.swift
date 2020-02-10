//
//  MusicBar.swift
//  Depo
//
//  Created by Aleksandr on 8/11/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol MusicBarDelegate: class {
    func musicBarZoomWillOpen()
}

class MusicBar: UIView {
    
    lazy var player: MediaPlayer = factory.resolve()
    
    weak var delegate: MusicBarDelegate?

    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var zoomUpButton: UIButton!
    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var progressViewContainer: GradientView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet var contentView: UIView!
    
    var status: ItemStatus = .active
    
    @IBAction func actionZoomUpButton(_ sender: UIButton) {
        delegate?.musicBarZoomWillOpen()
        
        let router = RouterVC()
        let controller = router.musicPlayer(status: status)
        let navigation = NavigationController(rootViewController: controller)
        navigation.navigationBar.isHidden = false
        router.presentViewController(controller: navigation)
    }
    
    @IBAction func actionPlayPauseButton(_ sender: UIButton) {
        player.togglePlayPause()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MusicBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSwipeRecognition()
        setupGradientView()
        player.delegates.add(self)
        
        musicNameLabel.text = player.currentMusicName
        artistLabel.text = player.currentArtist
        
        makeProgress(value: 0)
    }
    
    private func setupGradientView() {
        gradientView.setup(withFrame: bounds,
                           startColor: UIColor.lrRedOrange,
                           endColoer: UIColor.lrYellowSun,
                           startPoint: CGPoint(x: 0, y: 0.5),
                           endPoint: CGPoint(x: 1, y: 0.5))

        let progressViewRect = CGRect(x: 0, y: 0, width: Device.winSize.width, height: progressViewContainer.bounds.height)
        progressViewContainer.setup(withFrame: progressViewRect,
                                    startColor: UIColor.lrSLightPink,
                                    endColoer: UIColor.lrLightYellow,
                                    startPoint: CGPoint(x: 0, y: 0.5),
                                    endPoint: CGPoint(x: 1, y: 0.5))
    }
    
    private func makeProgress(value: Float) {
        progressView.isHidden = value == 0

        progressView.frame = CGRect(x: 0, y: 0, width: progressViewContainer.bounds.width * CGFloat(value), height: progressViewContainer.bounds.height)
    }

    deinit {
        player.delegates.remove(self)
    }

    private func addSwipeRecognition() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .left
        addGestureRecognizer(swipeLeft)
    }

    @objc func respondToSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        
        if gesture.direction == .right {
            UIView.animate(withDuration: 0.1, animations: {
                self.frame.origin.x += Device.winSize.width
            }, completion: { _ in
                self.removePlayer()
            })
            
        } else if gesture.direction == .left {
            UIView.animate(withDuration: 0.1, animations: {
                self.frame.origin.x -= Device.winSize.width
            }, completion: { _ in
                self.removePlayer()
            })
        }
    }

    private func removePlayer() {
        player.stop()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TabBarViewController.notificationMusicDrop), object: nil)
    }

    func configurateFromPLayer() {
        frame.origin.x = 0
    }
}

extension MusicBar: MediaPlayerDelegate {
    func mediaPlayer(_ mediaPlayer: MediaPlayer, didStartItemWith duration: Float) {
        musicNameLabel.text = player.currentMusicName
        artistLabel.text = player.currentArtist
    }
    
    func mediaPlayer(_ musicPlayer: MediaPlayer, changedCurrentTime time: Float) {
        if musicPlayer.duration != 0 {
            makeProgress(value: time / musicPlayer.duration)
        }
    }
    
    func didStartMediaPlayer(_ mediaPlayer: MediaPlayer) {
        playPauseButton.isSelected = false
    }
    
    func didStopMediaPlayer(_ mediaPlayer: MediaPlayer) {
        playPauseButton.isSelected = true
    }
    
    func changedListItemsInMediaPlayer(_ mediaPlayer: MediaPlayer) {
        if player.list.isEmpty {
            removePlayer()
        }
    }
}
