//
//  MediaService.swift
//  Depo
//
//  Created by Alexander Gurin on 6/23/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

typealias PlayerProgressClousure = (CMTime) -> Void

protocol PlayerDelegate: class {
   
    func itemStoppedPlaying(currentItem: Item)
    
    func itemStartedPlaying(currentItem: Item)
    
    func trackChanged()
}

class SingleSong: NSObject {
    
    @objc static let `default` = SingleSong()
    
    weak var delegate: PlayerDelegate?
    
    private var player: AVPlayer
    
    fileprivate var list = [WrapData]()
    
    let interval = CMTimeMakeWithSeconds(1.0, 1)//1 second
    
    var volume: Float {
        didSet { player.volume = volume }
    }
    
    fileprivate var isPlayerPlaying: Bool = true {
        didSet {
            debugPrint("isPlaying is ", isPlayerPlaying)
        }
    }
    
    private var currentItemModel: Item?
    
    private var musicProgressClousure: PlayerProgressClousure!

    private var outsideProgressClousure: PlayerProgressClousure?
    
    private var currentItemIndex: Int? {
        guard let unwrapedCurrentItem = currentItemModel else {
            return nil
        }
        return list.index(of: unwrapedCurrentItem)
    }

    override init() {
        player = AVPlayer()
        volume = 1.0
        
        super.init()
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }

//    override func remoteControlReceived(with event: UIEvent?) { // *
//        let rc = event!.subtype
//        let p = self.player//.player!
//        print("received remote control \(rc.rawValue)") // 101 = pause, 100 = play
//        switch rc {
//        case .remoteControlTogglePlayPause:
//            if p.isPlayerPlaying { p.pause() } else { p.play() }
//        case .remoteControlPlay:
//            p.play()
//        case .remoteControlPause:
//            p.pause()
//        default:break
//        }
//    }
//    func remoteControlReceivedWithEvent
    
    private func setupProgressObserving() {
        musicProgressClousure = { [weak self] time in
            guard let `self` = self else {
                return
            }
//            MPNowPlayingInfoCenter.default().nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackProgress] = String(time)
            
            self.outsideProgressClousure?(time)
        }
//        player.removeTimeObserver(self)
        player.addPeriodicTimeObserver(forInterval: interval,
                                       queue: nil, using: musicProgressClousure)
        
    }
    
    @objc private func currentItemFinishedPlaying(notification: Notification) {
        debugPrint("Player: Current ITEM finished Playing")
        guard let currentItmModelUnwraped = currentItemModel else {
            return
        }
        delegate?.itemStoppedPlaying(currentItem: currentItmModelUnwraped)
        guard let currentIndex = currentItemIndex else {
            return
        }
        if list.count <= 1 || currentIndex + 1 >= list.count{
            isPlayerPlaying = false
        } else {
            playNext()
        }
    }
    
    func playWithItem(object:Item) {
        list.removeAll()
        list.append(contentsOf: [object])
        
        playItem(item: object)
        
        NotificationCenter.default.post(name:
            NSNotification.Name(rawValue: TabBarViewController.notificationMusicStartedPlaying),
                                        object: nil)
    }
    
    func addProgressClousure(progressClousure: @escaping PlayerProgressClousure) {
        outsideProgressClousure = progressClousure
    }
    
    fileprivate func playItem(item: Item) {
        
        if let currentModel = currentItemModel, currentModel.urlToFile == item.urlToFile {
            play()
            return
        }
        
        currentItemModel = item
        
        if let currentAVItem = player.currentItem {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: currentAVItem)
        }
        
        let url = item.urlToFile
        let playerItem = AVPlayerItem(url:url!)
        
//        player = AVPlayer(playerItem: playerItem)
        player.replaceCurrentItem(with: playerItem)
        
        
//        player.prepareToPlay()
        
        player.volume = volume

        player.play()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.currentItemFinishedPlaying(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
        setupProgressObserving()
        
        let mpic = MPNowPlayingInfoCenter.default()
        var musicName = "TEST"
        var artistName = "TEST"
        if let metadata = item.metaData, let actualMeta = metadata.medaData as? MusicMetaData {
            
            if let name = actualMeta.title {
                musicName = name
            }
            if let artist = actualMeta.artist {
                artistName = artist
            }
            _ = actualMeta.duration
        }
        
        let artwork = UIImage(named: "headphone1")

        let _ = MPMediaItemArtwork(image: artwork!)
        
        mpic.nowPlayingInfo = [
            MPMediaItemPropertyTitle: musicName,
            MPMediaItemPropertyArtist: artistName,
            MPMediaItemPropertyPlaybackDuration: player.currentItem?.duration.seconds ?? 20
        ]
    }
    
    func playWithItems(list: [Item], startItem: Item) {
        self.list.removeAll()
        self.list.append(contentsOf: list)
        
        playItem(item: startItem)
        
        NotificationCenter.default.post(name:
            NSNotification.Name(rawValue: TabBarViewController.notificationMusicStartedPlaying),
                                        object: nil)
    }
    
    func playTrack(fromIndex itemIndex: Int) {
        guard itemIndex < list.count, itemIndex >= 0 else {
            return
        }
        guard let currentIndx = currentItemIndex, currentIndx != itemIndex else {
            return
        }
        
        playItem(item: list[itemIndex])
        delegate?.trackChanged()
    }
    
    @objc func pause() {
        isPlayerPlaying = false
        player.pause()
    }
    
    @objc func play() {
        isPlayerPlaying = true
        player.play()
    }
    
    @objc func stop() {
        isPlayerPlaying = false
        player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        player.pause()
    }
    
    func changePosition(to time: Double, play: Bool) {
        player.seek(to: CMTime(seconds: time, preferredTimescale: 1))
        play ? player.play() : player.pause()
    }
    
    func getCurrentItemDuration() -> Double? {
        return player.currentItem?.duration.seconds
    }
    
    func getCurrentItemModel() -> Item? {
        return currentItemModel
    }
 
    func getCurrentItemIndex() -> Int? {
        return currentItemIndex
    }
    
    func isPlaying() -> Bool {
        return isPlayerPlaying
    }
    
    func itemsInStack() -> [Item] {
        return list
    }
    
    @objc func playNext() {
        changeSong(forward: true)
    }
    
    @objc func playBefore() {
        changeSong(forward: false)
    }
    
    private func changeSong(forward: Bool) {
        guard let currentIndex = currentItemIndex else {
            return
        }
        let value = forward ? 1 : -1
        playTrack(fromIndex: currentIndex + value)
    }
}

class SmallBasePlayer: SingleSong {
    override  func playWithItem(object: Item) {
        list = [object]
        isPlayerPlaying = true
        playItem(item: object)
    }
}
