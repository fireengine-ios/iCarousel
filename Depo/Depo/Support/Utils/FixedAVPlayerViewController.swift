//
//  FixedAVPlayerViewController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 7/30/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import AVKit

/// https://stackoverflow.com/a/48065188
final class FixedAVPlayerViewController: AVPlayerViewController {
    override var prefersStatusBarHidden: Bool {
        return false
    }
}
