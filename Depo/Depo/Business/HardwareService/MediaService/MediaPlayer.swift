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

enum MediaPlayerRepeateMode {
    case none
    case one
    case all
}

final class MediaPlayer: NSObject {
    
    var currentItem: Item? {
        didSet {
            currentMetaData = currentItem?.metaData
        }
    }
    private var currentMetaData: BaseMetaData? {
        didSet {
            currentArtist = currentMetaData?.artist ?? "Artist \(duration)"
            currentMusicName = currentMetaData?.title ?? "Title \(duration)"
            
            SDWebImageManager.shared().loadImage(with: currentMetaData?.mediumUrl, options: [], progress: nil) { [weak self] (image, data, error, type, result, url) in
                
                if url == self?.currentMetaData?.mediumUrl, let image = image {
                    let artwork = MPMediaItemArtwork(image: image)
                    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
                } else {
                    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = nil
                }
            }
        }
    }
    var currentArtist = ""
    var currentMusicName = ""
    
    var list = [Item]()
    
    private var items = [AVPlayerItem]()
    private var urls = [URL]()
    private var player: AVPlayer!
    private var playerTimeObserver: Any?
    private let playDidEndNotification = NSNotification.Name.AVPlayerItemDidPlayToEndTime
    
    // MARK: - Setup
    
    override init() {
        super.init()
        
        setup(player: AVPlayer())
        setupFinishedPlayingObserver()
        enableBackground()
    }
    
    /// Add Capabilities - Background modes - Audio...
    private func enableBackground() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    private func setup(player: AVPlayer) {
        self.player?.replaceCurrentItem(with: nil)
        removePeriodicTimeObserver()
        removePlayerObservers()
        self.player = nil
        self.player = player
        player.volume = 1
        
        if #available(iOS 10.0, *) {
            player.automaticallyWaitsToMinimizeStalling = false
        }
        
        //player.appliesMediaSelectionCriteriaAutomatically = false
        setupPlayerTimeObserver()
        setupPlayerObservers()
    }
    
    private func setupPlayerTimeObserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playerTimeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
            [weak self] time in
            
            guard let guardSelf = self else { return }
            let currentTime = Float(CMTimeGetSeconds(time))
            
            guardSelf.delegates.invoke { delegate in
                delegate.mediaPlayer(guardSelf, changedCurrentTime: currentTime)
            }
            guardSelf.updateNowPlayingInfoCenter(with: currentTime)
        }
    }
    
    private func setupPlayerObservers() {
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), options: [.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status), options: [.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.isPlaybackLikelyToKeepUp), options: [.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.isPlaybackBufferEmpty), options: [.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        guard keyPath != nil else {
//            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//        }
        
        if keyPath == #keyPath(AVPlayer.status) {
            play()
        }
        else if keyPath == #keyPath(AVPlayer.currentItem) {
            let index = chooseIndex(for: currentIndex)
            let duration = Float(CMTimeGetSeconds(items[index].asset.duration))
            self.duration = duration
            currentItem = list[index]
            
            delegates.invoke { delegate in
                delegate.mediaPlayer(self, didStartItemWith: duration)
            }
            
            play()
        }
        else if keyPath == #keyPath(AVPlayer.currentItem.isPlaybackLikelyToKeepUp), player.currentItem?.status == .readyToPlay, isPlaying {
            play()
        }
        else if keyPath == #keyPath(AVPlayer.currentItem.isPlaybackBufferEmpty), player.currentItem?.status == .readyToPlay {
            play()
        }
    }
    
    private func setupFinishedPlayingObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(finishedPlaying),
                                               name: playDidEndNotification,
                                               object: nil)
    }
    
    @objc private func finishedPlaying(_ notification: NSNotification) {
        guard let item = notification.object as? AVPlayerItem, item == player.currentItem else { return }
        
        if playNext() {
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
        guard let player = self.player else { return }
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.status))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem.isPlaybackLikelyToKeepUp))
    }
    
    // MARK: - Start actions
    
    func remove(listItems: [Item]) {
        var deleteIndexes = [Int]()
        
        /// find delete indexes
        for (i, item) in list.enumerated() {
            for deleteItem in listItems {
                if deleteItem.urlToFile == item.urlToFile {
                    deleteIndexes.append(i)
                    break
                }
            }
        }
        
        deleteIndexes.forEach { i in
            list.remove(at: i)
            urls.remove(at: i)
            items.remove(at: i)
            self.shuffleCurrentList()
        }
        
        /// check current playing item for delete indexes
        if deleteIndexes.contains(currentIndex) {
            // TODO: CHECK ALL STATES
            if play(at: currentIndex) {
                currentIndex -= 1
            } else if list.count > 0 {
                currentIndex = list.count - 1
                play(at: currentIndex)
            } else {
                currentIndex = 0
                stop()
            }
        }
        
        delegates.invoke { delegate in
            delegate.changedListItemsInMediaPlayer(self)
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
            delegates.invoke { delegate in
                delegate.mediaPlayer(self, didStartItemWith: duration)
            }
        } else {
            player.replaceCurrentItem(with: item)
        }
        
        resetTime()
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
        if #available(iOS 10.0, *) {
            player.playImmediately(atRate: 1)
        } else {
            player.play()
        }
        delegates.invoke { delegate in
            delegate.didStartMediaPlayer(self)
        }
    }
    
    func pause() {
        player.pause()
        
        delegates.invoke { delegate in
            delegate.didStopMediaPlayer(self)
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
    func playNext() -> Bool {
        if list.isEmpty {
            delegates.invoke { delegate in
                delegate.closeMediaPlayer()
            }
            return false
        }
        if currentIndex == items.count - 1 { return false }
        
        currentIndex += 1
        setupPlayerWithItem(at: chooseIndex(for: currentIndex))
        return true
    }

    
    @discardableResult
    func playPrevious() -> Bool {
        if currentIndex == 0 { return false }
        currentIndex -= 1
        setupPlayerWithItem(at: chooseIndex(for: currentIndex))
        return true
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
        delegates.invoke { delegate in
            delegate.mediaPlayer(self, changedCurrentTime: 0)
        }
    }
    
    func clearCurrentItem() {
        currentItem = nil
        player?.replaceCurrentItem(with: nil)
    }
    
    func seek(to time: Float) {
        let showingTime = CMTimeMake(Int64(time) * 1000, 1000)
        player.seek(to: showingTime)
//        { [weak self] result in
//            self?.play()
//        }
    }
    
    func resetTime() {
        player.seek(to: kCMTimeZero)
    }
    
    
    var repeateMode: MediaPlayerRepeateMode = .none
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
        if list.count == 0 || currentIndex == list.count {
            return
        }
        
        shuffledIndexes = Array(repeating: 0, count: list.count)
        for i in 0..<list.count {
            shuffledIndexes[i] = i
        }
        
        shuffledList.removeAll()
        shuffledList.append(list[currentIndex])
        
        shuffledIndexes.swapAt(0, currentIndex)
//        currentIndex = 0
        
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
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: currentMusicName,
            MPMediaItemPropertyArtist: currentArtist,
            MPMediaItemPropertyPlaybackDuration: duration as CFNumber,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: time as CFNumber
        ]
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
