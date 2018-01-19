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
    @IBOutlet weak var progressViewContainer: UIView!
    
    @IBAction func actionZoomUpButton(_ sender: UIButton) {
        delegate?.musicBarZoomWillOpen()
        
        let vc = VisualMusicPlayerModuleInitializer.initializeVisualMusicPlayerController(with: "VisualMusicPlayerViewController")
        let navigation = UINavigationController(rootViewController: vc)
        navigation.navigationBar.isHidden = false
        RouterVC().presentViewController(controller: navigation)
    }
    
    @IBAction func actionPlayPauseButton(_ sender: UIButton) {
        player.togglePlayPause()
    }
    
    private var configureVisualMusicPlayerModule: VisualMusicPlayerModuleInitializer?
    
    class func initFromXib() -> MusicBar {
        return UINib(nibName: "MusicBar", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! MusicBar
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSwipeRecognition()
        setupGradientView()
        player.delegates.add(self)
        
        musicNameLabel.text = player.currentMusicName
        artistLabel.text = player.currentArtist
    }
    
    private func setupGradientView() {
        let rect = CGRect(x: 0, y: 0, width: Device.winSize.width, height: bounds.height)
        gradientView.setup(withFrame: rect,
                           startColor: UIColor.lrRedOrange,
                           endColoer: UIColor.lrYellowSun,
                           startPoint: CGPoint(x: 0, y: 0.5),
                           endPoint: CGPoint(x: 1, y: 0.5))
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
//        player.play(at: player.currentIndex)
//        guard let currentItem = SingleSong.default.getCurrentItemModel() else {
//            return
//        }
//        playPauseButton.isSelected = false
//        if let metadata = currentItem.metaData, let actualMeta = metadata.medaData as? MusicMetaData {
//
//            if let name = actualMeta.title {
//                musicNameLabel.text = name
//            }
//            if let artist = actualMeta.artist {
//                artistLabel.text = artist
//            }
//        }
        frame.origin.x = 0
    }
}

extension MusicBar: MediaPlayerDelegate {
    func mediaPlayer(_ mediaPlayer: MediaPlayer, didStartItemWith duration: Float) {
        musicNameLabel.text = player.currentMusicName
        artistLabel.text = player.currentArtist
    }
    func mediaPlayer(_ musicPlayer: MediaPlayer, changedCurrentTime time: Float) {
        
    }
    func didStartMediaPlayer(_ mediaPlayer: MediaPlayer) {
        playPauseButton.isSelected = false
    }
    func didStopMediaPlayer(_ mediaPlayer: MediaPlayer) {
        playPauseButton.isSelected = true
    }
}
