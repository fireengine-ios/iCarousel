//
//  AudioPlayer.swift
//  LifeBox-new
//
//  Created by Bondar Yaroslav on 14/10/2017.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit
import MediaPlayer
import SDWebImage

enum MediaPlayerPlayMode {
    case normal
    case shaffle
}

final class MediaPlayer: NSObject {
    
    var currentItem: Item? {
        didSet {
            currentMetaData = currentItem?.metaData
        }
    }
    
    var currentArtwork: MPMediaItemArtwork?
    
    private var currentMetaData: BaseMetaData? {
        didSet {
            currentMusicName = currentMetaData?.title ?? currentItem?.name ?? " "
            currentArtist = currentMetaData?.artist ?? " "
            currentArtwork = nil
            
            SDWebImageManager.shared().loadImage(with: currentMetaData?.mediumUrl, options: [], progress: nil) { [weak self] image, data, error, type, result, url in
                
                if url == self?.currentMetaData?.mediumUrl, let image = image {
                    self?.currentArtwork = MPMediaItemArtwork(image: image)
                }
            }
        }
    }
    var currentArtist = " "
    var currentMusicName = " "
    
    var list = [Item]()
    
    private var items = [AVPlayerItem]()
    private var urls = [URL]()
    private var player: AVPlayer!
    private var playerTimeObserver: Any?
    private let playDidEndNotification = Notification.Name.AVPlayerItemDidPlayToEndTime
    private var enabledBackground = false
    
    // MARK: - Setup
    
    override init() {
        super.init()
        
        setup(player: AVPlayer())
        setupFinishedPlayingObserver()
    }
    
    /// Add Capabilities - Background modes - Audio...
    private func enableBackground() {
        if !enabledBackground {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try? AVAudioSession.sharedInstance().setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            enabledBackground = true
        }
    }
    
    private func guardAudioSession() {
        if AVAudioSession.sharedInstance().category != AVAudioSessionCategoryPlayback {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
    }
    
    private func setup(player: AVPlayer) {
        self.player?.replaceCurrentItem(with: nil)
        removePeriodicTimeObserver()
        removePlayerObservers()
        self.player = nil
        self.player = player
        player.volume = 1
        player.automaticallyWaitsToMinimizeStalling = false
        
        //player.appliesMediaSelectionCriteriaAutomatically = false
        setupPlayerTimeObserver()
        setupPlayerObservers()
        setupHeadphoneObserver()
        guardAudioSession()
    }
    
    private func setupPlayerTimeObserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playerTimeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
            [weak self] time in
            
            guard let `self` = self else {
                return
            }
            let currentTime = Float(CMTimeGetSeconds(self.player.currentTime()))
            let newTime = Float(CMTimeGetSeconds(time))
            
            guard abs(currentTime - newTime) < 2 else {
                return
            }
        
            DispatchQueue.main.async {
                self.delegates.invoke { $0.mediaPlayer(self, changedCurrentTime: newTime) }
            }
            self.updateNowPlayingInfoCenter(with: newTime)
        }
    }
    
    private func setupPlayerObservers() {
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), options: [.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options: [.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.isPlaybackLikelyToKeepUp), options: [.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.isPlaybackBufferEmpty), options: [.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
//        guard keyPath != nil else {
//            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//        }
        
        if keyPath == #keyPath(AVPlayer.status), isPlaying {
            play()
        } else if keyPath == #keyPath(AVPlayer.currentItem) {
            let index = chooseIndex(for: currentIndex)
            if items.count <= index || index < 0 {
                return
            }
        
            currentItem = list[index]
            if let duration = list[index].durationValue {
                self.duration = Float(duration)
            } else {
                let duration = Float(CMTimeGetSeconds(items[index].asset.duration))
                self.duration = duration
            }

            DispatchQueue.main.async {
                self.delegates.invoke { $0.mediaPlayer(self, didStartItemWith: self.duration) }
            }
            
            if isPlaying {
                play()
            }
        } else if keyPath == #keyPath(AVPlayer.currentItem.isPlaybackLikelyToKeepUp), player.currentItem?.status == .readyToPlay, isPlaying {
            play()
        } else if keyPath == #keyPath(AVPlayer.currentItem.isPlaybackBufferEmpty), player.currentItem?.status == .readyToPlay, isPlaying {
            play()
        }
    }
    
    private func setupHeadphoneObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(headphoneRemoved),
                                               name: Notification.Name.AVAudioSessionRouteChange,
                                               object: nil)
    }
    
    @objc private func headphoneRemoved(_ notification: Notification) {
        guard
            let audioRouteChangeReasonRaw = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let changeReason = AVAudioSessionRouteChangeReason(rawValue: audioRouteChangeReasonRaw)
        else {
            return
        }
        
        switch changeReason {
        case .oldDeviceUnavailable:
            DispatchQueue.main.async {
                self.pause()
            }
        default:
            break
        }
    }
    
    private func setupFinishedPlayingObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(finishedPlaying),
                                               name: playDidEndNotification,
                                               object: nil)
    }
    
    @objc private func finishedPlaying(_ notification: Notification) {
        guard let item = notification.object as? AVPlayerItem, item == player.currentItem else {
            return
        }
        
        resetTime()
        if playNext() >= 0 {
            play()
        } else {
            stop()
        }
    }
    
    deinit {
        removePeriodicTimeObserver()
        removePlayerObservers()
    }
    
    private func removePeriodicTimeObserver() {
        if let observer = playerTimeObserver {
            player?.removeTimeObserver(observer)
            playerTimeObserver = nil
        }
    }
    
    private func removePlayerObservers() {
        NotificationCenter.default.removeObserver(self, name: playDidEndNotification, object: nil)
        guard let player = player else {
            return
        }
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.isPlaybackLikelyToKeepUp))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.isPlaybackBufferEmpty))
    }
    
    // MARK: - Start actions
    
    func remove(listItems: [Item]) {
        var deleteIndexes = [Int]()
        
        /// find delete indexes
        for (i, item) in list.enumerated() {
            for deleteItem in listItems {
                if deleteItem.uuid == item.uuid {
                    deleteIndexes.append(i)
                    break
                }
            }
        }
        
        let savedCurrentIndex = currentIndex
        deleteIndexes.reversed().forEach { i in
            list.remove(at: i)
            urls.remove(at: i)
            items.remove(at: i)
            
            if i < currentIndex, currentIndex != 0 {
                currentIndex -= 1
            }
        }
        
        shuffleCurrentList()
        
        /// check current playing item for delete indexes
        if deleteIndexes.contains(savedCurrentIndex) {
            if play(at: currentIndex) {
                if deleteIndexes.count > 1, currentIndex > 0 {
                    currentIndex -= 1
                }
            } else if list.count > 0 {
                currentIndex = list.count - 1
                play(at: currentIndex)
            } else {
                currentIndex = 0
                stop()
            }
        }
        
        DispatchQueue.main.async {
            self.delegates.invoke { $0.changedListItemsInMediaPlayer(self) }
        }
        
    }
    
    func play(list: [Item], startAt index: Int) {
        self.list = list
        let newUrls = list.flatMap { $0.urlToFile }
        play(urls: newUrls, startAt: index)
    }
    
    private func play(urls: [URL], startAt index: Int) {
        setup(newUrls: urls)
        currentIndex = index
        if playMode == .shaffle {
            shuffleCurrentList()
            currentIndex = 0
        }
        setupPlayerWithItem(at: chooseIndex(for: currentIndex))
        play()
    }
    
    private func setup(newUrls urls: [URL]) {
        if self.urls != urls {
            self.urls = urls
            self.items = urls.map { AVPlayerItem(url: $0) }
        }
    }
    
    private func setupPlayerWithItem(at index: Int) {
        validateItem(at: index)
        validatePlayer()
        let item = items[index]
        
        /// need bcz of player.replaceCurrentItem(with: item)
        /// if item of player == newItem, will not call observeValue(forKeyPath
        if currentItem?.urlToFile == list[index].urlToFile {
            DispatchQueue.main.async {
                self.delegates.invoke { $0.mediaPlayer(self, didStartItemWith: self.duration) }
            }
        } else {
            player.replaceCurrentItem(with: nil)
            player.replaceCurrentItem(with: item)
        }
        
        resetTime()
        enableBackground()
    }
    
    private func validateItem(at index: Int) {
        if items[index].status == .failed {
            let asset = AVAsset(url: urls[index])
            items[index] = AVPlayerItem(asset: asset)
        }
    }
    
    private func validatePlayer() {
        if player.status == .failed {
            self.items = urls.map { AVPlayerItem(url: $0) }
            setup(player: AVPlayer())
        }
    }
    
    // MARK: - Properties
    
    var currentIndex = 0
    
    var isPlaying: Bool {
        return player.rate != 0
    }
    
    var duration: Float = 0
    
    var currentTime: Float {
        return Float(CMTimeGetSeconds(player.currentTime()))
    }
    
    var delegates = MulticastDelegate<MediaPlayerDelegate>()
    
    // MARK: - Actions
    
    func play() {
        if isPlaying {
            return
        }
        player.playImmediately(atRate: 1)
        
        DispatchQueue.main.async {
            self.delegates.invoke { $0.didStartMediaPlayer(self) }
        }
    }
    
    func pause() {
        player.pause()
        
        DispatchQueue.main.async {
            self.delegates.invoke { $0.didStopMediaPlayer(self) }
        }
    }
    
    func togglePlayPause() {
        isPlaying ? pause() : play()
    }
    
    
    func chooseIndex(for currentIndex: Int) -> Int {
        switch playMode {
        case .normal:
            return currentIndex
        case .shaffle:
            return shuffledIndexes[currentIndex]
        }
    }
    
    @discardableResult
    func playNext() -> Int {
        if list.isEmpty {
            DispatchQueue.main.async {
                self.delegates.invoke { $0.closeMediaPlayer() }
            }
            return -1
        }
        
        let isPlayListEnded = currentIndex == items.count - 1
        if isPlayListEnded {
            currentIndex = 0
        } else {
            currentIndex += 1
        }
        
        let nextIndex = chooseIndex(for: currentIndex)
        setupPlayerWithItem(at: nextIndex)
        return nextIndex
    }

    
    @discardableResult
    func playPrevious() -> Int {
        let isPlayItemBeforeFirst = currentIndex == 0 
        if isPlayItemBeforeFirst {
            currentIndex = list.count - 1
        } else {
            currentIndex -= 1
        }
        
        let previousIndex = chooseIndex(for: currentIndex)
        setupPlayerWithItem(at: previousIndex)
        return previousIndex
    }
    
    @discardableResult
    func play(at index: Int) -> Bool {
        if index > urls.count - 1 || index < 0 { return false }
        currentIndex = index
        setupPlayerWithItem(at: chooseIndex(for: currentIndex))
        return true
    }
    
    func stop() {
        pause()
        resetTime()
        DispatchQueue.main.async {
            self.delegates.invoke { $0.mediaPlayer(self, changedCurrentTime: 0) }
        }
    }
    
    func seek(to time: Float) {
        let showingTime = CMTimeMake(Int64(time) * 1000, 1000)
        player.seek(to: showingTime)
    }
    
    func resetTime() {
        player.seek(to: kCMTimeZero)
    }
    
    var playMode: MediaPlayerPlayMode = .normal {
        didSet {
            switch playMode {
            case .normal:
                if let item = currentItem, let index = list.index(of: item) {
                    currentIndex = index
                } else {
                    currentIndex = 0
                }
                
            case .shaffle:
                shuffleCurrentList()
            }
        }
    }
    func togglePlayMode() {
        playMode = (playMode == .normal) ? .shaffle : .normal
    }
    
    var shuffledList = [Item]()
    var shuffledIndexes = [Int]()
    
    func shuffleCurrentList() {
        if list.count == 0 || currentIndex == list.count || currentIndex < 0 {
            return
        }
        
        shuffledIndexes = Array(repeating: 0, count: list.count)
        for i in 0..<list.count {
            shuffledIndexes[i] = i
        }
        
        shuffledList.removeAll()
        shuffledList.append(list[currentIndex])
        
        shuffledIndexes.swapAt(0, currentIndex)
        
        /// generated random indexes array
        for i in 1..<list.count {
            let randomIndex = Int(arc4random_uniform(UInt32(list.count - i))) + i
            guard i != randomIndex else { continue }
            shuffledIndexes.swapAt(i, randomIndex)
        }
        
        /// fill shuffledList with originial by shuffledIndexes
        for i in 1..<list.count {
            shuffledList.append(list[shuffledIndexes[i]])
        }
    }
    
    @objc func handle(event: UIEvent?) {
        guard let type = event?.subtype else { return }
        switch type {
        case .remoteControlPlay:
            play()
        case .remoteControlPause:
            pause()
        case .remoteControlNextTrack:
            playNext()
        case .remoteControlPreviousTrack:
            playPrevious()
        case .remoteControlTogglePlayPause:
            togglePlayPause()
        case .remoteControlStop:
            pause()
            resetTime()
        default:
            break
        }
    }
    
    func updateNowPlayingInfoCenter(with time: Float) {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: currentMusicName,
            MPMediaItemPropertyArtist: currentArtist,
            MPMediaItemPropertyPlaybackDuration: duration as CFNumber,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: time as CFNumber
        ]
        
        if let artwork = currentArtwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork 
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

// MARK: - MediaPlayerDelegate
protocol MediaPlayerDelegate {
    func mediaPlayer(_ mediaPlayer: MediaPlayer, didStartItemWith duration: Float)
    func mediaPlayer(_ musicPlayer: MediaPlayer, changedCurrentTime time: Float)
    func didStartMediaPlayer(_ mediaPlayer: MediaPlayer)
    func didStopMediaPlayer(_ mediaPlayer: MediaPlayer)
    func changedListItemsInMediaPlayer(_ mediaPlayer: MediaPlayer)
    func closeMediaPlayer()
}
extension MediaPlayerDelegate {
    func mediaPlayer(_ mediaPlayer: MediaPlayer, didStartItemWith duration: Float) {}
    func mediaPlayer(_ musicPlayer: MediaPlayer, changedCurrentTime time: Float) {}
    func didStartMediaPlayer(_ mediaPlayer: MediaPlayer) {}
    func didStopMediaPlayer(_ mediaPlayer: MediaPlayer) {}
    func changedListItemsInMediaPlayer(_ mediaPlayer: MediaPlayer) {}
    func closeMediaPlayer() {}
}
