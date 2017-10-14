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

protocol VisualMusicPlayerViewControllerDelegate: class {
    func playPauseButtonGotSelected(selected: Bool)
}

class VisualMusicPlayerViewController: UIViewController, VisualMusicPlayerViewInput {
    
    var output: VisualMusicPlayerViewOutput!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var playBackButton: UIButton!
    
    @IBOutlet weak var playForwardButton: UIButton!
    
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBOutlet weak var carouselView: iCarousel!
    
    @IBOutlet weak var musicSlider: UISlider!
   
    @IBOutlet weak var currentMusicOffseetLabel: UILabel!
    
    @IBOutlet weak var totalDurationLabel: UILabel!
    
    @IBOutlet weak var musicName: UILabel!
    
    @IBOutlet weak var artistName: UILabel!
    
    var isPlaying: Bool = true
    
    weak var delegate: VisualMusicPlayerViewControllerDelegate?
    
    var currentItemDuration: Double {
        return SingleSong.default.getCurrentItemDuration() ?? 0
    }
    
    let carouselItemFrameWidth: CGFloat = 232
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        output.viewIsReady()
        setupInitialConfig()
    }
    
    private func setupInitialConfig() {
        volumeSlider.addTarget(self, action: #selector(volumeSliderValueChanged(slider:)), for: .valueChanged)
        musicSlider.addTarget(self, action: #selector(musicSliderValueChanged(slider:)), for: .valueChanged)
        
        volumeSlider.setValue(SingleSong.default.volume, animated: false)
        
        setupCarousel()
        
    }
    
    private func setupCarousel() {
        carouselView.type = .custom
        carouselView.delegate = self
        carouselView.dataSource = self
        carouselView.isPagingEnabled = true
    }
    
    func setupPlayerConfig() {
        
        setupUI()
        
//        carouselView.currentItemIndex = SingleSong.default.getCurrentItemIndex() ?? 0
        let playerItemIndex = SingleSong.default.getCurrentItemIndex() ?? 0
        if carouselView.currentItemIndex != playerItemIndex {
            carouselView.scrollToItem(at: playerItemIndex, animated: true)
        }
    }

    fileprivate func setupUI() {
        
        if SingleSong.default.itemsInStack().count != carouselView.numberOfItems {
            carouselView.reloadData()
        }
        
        playPauseButton.isSelected = !SingleSong.default.isPlaying()
        
        guard let currentItem = SingleSong.default.getCurrentItemModel() else {
            return
        }
        if let totatlDuration = currentItem.duration {
            totalDurationLabel.text = totatlDuration
        }
        if let metadata = currentItem.metaData, let actualMeta = metadata.medaData as? MusicMetaData {
            
            if let name = actualMeta.title {
                musicName.text = name
            }
            if let artist = actualMeta.artist {
                artistName.text = artist
            }
            
        }
        
        //TODO: if there is only one track in the stack - disable forward and backword buttons
        
    }
    
    func setProgress(secondsPassed: Double) {
        if musicSlider == nil { //FIXME: find another architecture solution
            return
        }
        let persantage = secondsPassed/self.currentItemDuration
        self.musicSlider.setValue(Float(persantage), animated: false)
        
        let min = Int(secondsPassed) / 60
        let sec = Int(secondsPassed) % 60
        self.currentMusicOffseetLabel.text = String(format: "%02i:%02i", min, sec)
    }
    

    fileprivate func centeredItemStill() {
        SingleSong.default.playTrack(fromIndex: carouselView.currentItemIndex)
    }
    
    
    //MARK: - Sliders
    
    @objc private func volumeSliderValueChanged(slider: UISlider) {
        SingleSong.default.volume = slider.value
    }
    
    @objc private func musicSliderValueChanged(slider: UISlider) {
        var newPosition: Double = 0

        let totalValue = slider.maximumValue - slider.minimumValue
        let persantage = slider.value/totalValue
        let persantageToDuration = currentItemDuration*Double(fabs(persantage))
        
        newPosition = persantageToDuration
        
        SingleSong.default.changePosition(to: newPosition, play: !playPauseButton.isSelected)
    }
    
    
    // MARK: - VisualMusicPlayerViewInput
    
    func setupInitialState() {
        
    }
    
    
    //MARK: - Button Actions
    
    private func changePlayPauseStatus() {
        
        playPauseButton.isSelected = !playPauseButton.isSelected
        delegate?.playPauseButtonGotSelected(selected: playPauseButton.isSelected)
        if !playPauseButton.isSelected {
            SingleSong.default.play()
        } else {
            SingleSong.default.pause()
        }
    }
    
    @IBAction func pausePlayAction(_ sender: Any) {
        changePlayPauseStatus()
    }
    
    @IBAction func forwardAction(_ sender: Any) {
        SingleSong.default.playNext()
    }
    
    @IBAction func backAction(_ sender: Any) {
        SingleSong.default.playBefore()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - Crousel

extension VisualMusicPlayerViewController: iCarouselDataSource, iCarouselDelegate {

    func numberOfItems(in carousel: iCarousel) -> Int {
        return SingleSong.default.itemsInStack().count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
    
        var currentURL: URL? = URL(string: "")
        
        switch SingleSong.default.itemsInStack()[index].patchToPreview {
        case .remoteUrl(let remotrURL):
            currentURL = remotrURL
        default:
            break
        }
        
        let itemView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: carouselItemFrameWidth, height: carouselItemFrameWidth))
//        itemView.backgroundColor = UIColor.white
        
        if currentURL == nil {
            itemView.image = UIImage(named: "headphone1")
        } else {
            itemView.sd_setImage(with: currentURL, placeholderImage: UIImage(named: "headphone1"))
        }
        
        return itemView
    }
    
    func carouselDidEndDecelerating(_ carousel: iCarousel) {
        centeredItemStill()
    }
    
    func carousel(_ carousel: iCarousel, itemTransformForOffset offset: CGFloat, baseTransform transform: CATransform3D) -> CATransform3D {
        let distance: CGFloat = 130
        let z: CGFloat = -CGFloat(fminf(1.0, fabs(Float(offset)))) * distance
        return CATransform3DTranslate(transform, offset * carousel.itemWidth, 0.0, z)
    }
    
    func carouselItemWidth(_ carousel: iCarousel) -> CGFloat {
        return carouselItemFrameWidth * 1.3
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
//        if (option == .spacing) {
//            return value * 1.1
//        }
        if (option == .visibleItems) {
            return 5
        }
        return value
    }
}
