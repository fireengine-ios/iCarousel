//
//  MusicBar.swift
//  Depo
//
//  Created by Aleksandr on 8/11/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

class MusicBar: UIView {
    static let standardHeight: CGFloat = 90
    lazy var player: MediaPlayer = factory.resolve()

    @IBOutlet weak var artistLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 14)
            newValue.textColor = AppColor.secondaryTint.color
        }
    }
    
    @IBOutlet weak var musicNameLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.regular, size: 12)
            newValue.textColor = AppColor.secondaryTint.color
        }
    }
    
    @IBOutlet weak var playPauseButton: UIButton! {
        willSet {
            newValue.setImage(Image.iconPlay.image, for: .selected)
            newValue.setImage(Image.iconPause.image, for: .normal)
            newValue.tintColor = .white
        }
    }
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var slider: UISlider! {
        willSet {
            newValue.setThumbImage(UIImage(), for: .normal)
            newValue.minimumTrackTintColor = AppColor.secondaryTint.color
            newValue.maximumTrackTintColor = .white.withAlphaComponent(0.3)
            newValue.maximumValue = 1
            newValue.isEnabled = false
        }
    }
    
    var status: ItemStatus = .active
    
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
        player.delegates.add(self)
        
        musicNameLabel.text = player.currentMusicName
        artistLabel.text = player.currentArtist
        
        makeProgress(value: 0)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(actionZoomUpButton))
        addGestureRecognizer(gesture)
        
        layer.cornerRadius = 16
        clipsToBounds = true
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    private func makeProgress(value: Float) {
        DispatchQueue.main.async() { [weak self] in
            self?.slider.setValue(value, animated: true)
        }
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
    
    @objc func actionZoomUpButton(_ sender: UITapGestureRecognizer) {
        let router = RouterVC()
        let controller = router.musicPlayer(status: status)
        let navigation = NavigationController(rootViewController: controller)
        navigation.navigationBar.isHidden = false
        router.presentViewController(controller: navigation)
    }

    private func removePlayer() {
        player.stop()
        NotificationCenter.default.post(name: .musicDrop, object: nil)
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
