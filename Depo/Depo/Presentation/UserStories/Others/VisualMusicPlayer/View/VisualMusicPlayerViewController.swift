//
//  VisualMusicPlayerVisualMusicPlayerViewController.swift
//  Depo
//
//  Created by AlexanderP on 11/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import iCarousel
import SDWebImage
import MediaPlayer

class VisualMusicPlayerViewController: ViewController, VisualMusicPlayerViewInput {
    var output: VisualMusicPlayerViewOutput!
    
    lazy var player: MediaPlayer = factory.resolve()
    private let alert = AlertFilesActionsSheetPresenterModuleInitialiser().createModule()
    private let carouselItemFrameWidth: CGFloat = 220
    
    var editingTabBar: BottomSelectionTabBarViewController?

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var passedTimeLabel: UILabel!
    @IBOutlet weak var leftTimeLabel: UILabel!
    
    @IBOutlet weak var musicName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var carouselView: iCarousel!
    
    @IBOutlet weak var bottomView: UIView!
    
    private let shuffleButtonOffColor = UIColor.lightGray
    @IBOutlet weak var shuffleButton: UIButton! {
        didSet {
            updateShuffleButton()
        }
    }
    
    var currentDuration: Float = 0 {
        didSet {
            playbackSlider.maximumValue = currentDuration - 1
            passedTimeLabel.text = "00:00"
            leftTimeLabel.text = currentDuration.minutesSecondsString
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCarousel()
        playButton.isSelected = !player.isPlaying
        player.delegates.add(self)
        
        currentDuration = player.duration
        musicName.text = player.currentMusicName
        artistName.text = player.currentArtist
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        editingTabBar?.view.layoutIfNeeded()
        
        output.viewIsReady(view: bottomView, alert: alert)
        hidenNavigationBarStyle()
    }
    
    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }
    
    private func setupCarousel() {
        carouselView.type = .custom
        carouselView.delegate = self
        carouselView.dataSource = self
        carouselView.isPagingEnabled = true
        carouselView.scrollToItem(at: player.currentIndex, animated: false)
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = BackButtonItem { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        let moreButton = UIBarButtonItem(image: #imageLiteral(resourceName: "more"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(actionMoreButton(_:)))
        moreButton.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = moreButton
    }
    
    private func updateShuffleButton() {
        if player.playMode == .shaffle {
            shuffleButton.tintColor = UIColor.white
        } else {
            shuffleButton.tintColor = shuffleButtonOffColor
        }
    }
    
    // MARK: - Actions
    
    @IBAction func actionPlayButton(_ sender: UIButton) {
        player.togglePlayPause()
    }
    @IBAction func actionNextButton(_ sender: UIButton) {
        let nextIndex = player.playNext()
        if nextIndex >= 0 {
            carouselView.scrollToItem(at: nextIndex, animated: true)
        }
    }
    @IBAction func actionPrevButton(_ sender: UIButton) {
        
        if player.currentTime > 5 {
            player.resetTime()
        } else {
            let previousIndex = player.playPrevious()
            if previousIndex >= 0 {
                carouselView.scrollToItem(at: previousIndex, animated: true)
            }
        }
    }
    
    @IBAction func playbackSliderDidEndChanging(_ sender: UISlider) {
        player.seek(to: sender.value)
    }
    @IBAction func playbackSliderDidChanged(_ sender: UISlider) {
        passedTimeLabel.text = sender.value.minutesSecondsString
        leftTimeLabel.text = (sender.value - currentDuration).minutesSecondsString
    }
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func actionMoreButton(_ sender: UIButton) {
        guard let item = player.currentItem else { return }
        alert.showSpecifiedMusicAlertSheet(with: item, presentedBy: sender, onSourceView: nil, viewController: self)
    }
    @IBAction func actionShuffleButton(_ sender: UIButton) {
        player.togglePlayMode()
        updateShuffleButton()
    }
}
extension VisualMusicPlayerViewController: MediaPlayerDelegate {
    func mediaPlayer(_ mediaPlayer: MediaPlayer, didStartItemWith duration: Float) {
        currentDuration = duration
        musicName.text = player.currentMusicName
        artistName.text = player.currentArtist
        carouselView.scrollToItem(at: player.currentIndex, animated: true)
    }
    func mediaPlayer(_ musicPlayer: MediaPlayer, changedCurrentTime time: Float) {
        if playbackSlider.state == .normal { /// highlighted
            playbackSlider.setValue(time, animated: true)
            passedTimeLabel.text = time.minutesSecondsString
            leftTimeLabel.text = (time - currentDuration).minutesSecondsString
        }
    }
    func didStartMediaPlayer(_ mediaPlayer: MediaPlayer) {
        playButton.isSelected = false
    }
    func didStopMediaPlayer(_ mediaPlayer: MediaPlayer) {
        playButton.isSelected = true
    }
    func changedListItemsInMediaPlayer(_ mediaPlayer: MediaPlayer) {
        carouselView.reloadData()
    }
    func closeMediaPlayer() {
        output.closeMediaPlayer()
    }
}


// MARK: - Carousel

extension VisualMusicPlayerViewController: iCarouselDataSource, iCarouselDelegate {

    func numberOfItems(in carousel: iCarousel) -> Int {
        return player.list.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        
        let itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: carouselItemFrameWidth, height: carouselItemFrameWidth))
        itemView.contentMode = .scaleAspectFit
        let image = UIImage(named: "headphone1")
        
        if let url = player.list[index].metaData?.mediumUrl {
            itemView.sd_setImage(with: url, placeholderImage: image)
        } else {
            itemView.image = image
        }
        
        return itemView
    }
    
    func carouselDidEndDecelerating(_ carousel: iCarousel) {
        player.play(at: carousel.currentItemIndex)
    }
    
    func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        let z = -CGFloat(fmin(1.0, fabs(offset))) * 130
        return CATransform3DTranslate(transform, offset * carousel.itemWidth, 0, z)
    }
    
    func carouselItemWidth(_ carousel: iCarousel) -> CGFloat {
        return carouselItemFrameWidth + 40
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.3
        }
        if (option == .visibleItems) {
            return 5
        }
        return value
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        if index != carousel.currentItemIndex {
            carousel.scrollToItem(at: index, animated: true)
            player.play(at: index)
        }
    }
}


private extension Float {
    var minutesSecondsString: String {
        let s = Int(abs(self))
        let seconds = s % 60
        let minutes = s / 60
        let format = minutes < 100 ? "%02i:%02i" : "%i:%02i"
        let result = self < 0 ? "-\(format)" : format
        return String(format: result, minutes, seconds)
    }
}
