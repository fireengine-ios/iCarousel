//
//  VolumeSlider.swift
//  ScreenBrightness
//
//  Created by zdaecqze zdaecq on 13.08.16.
//  Copyright © 2016 Bondar Yaroslav. All rights reserved.
//

import UIKit
import MediaPlayer

final class VolumeSlider: UIView {
    
    // prop
    
    private var volumeView: MPVolumeView!
    var slider: UISlider!
    var showsRouteButton = false
    
    var value: Float {
        get { return slider.value }
        set { slider.value = newValue }
    }
    
    // init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        volumeView = MPVolumeView(frame: bounds)
        volumeView.showsRouteButton = showsRouteButton
        volumeView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(volumeView)
        backgroundColor = UIColor.clear
        setupSlider()
    }
    
    private func setupSlider() {
        slider = getVolumeSlider()
        slider.minimumValueImage = Image.iconPlayLowSound.image
        slider.maximumValueImage = Image.iconSound.image
    }
    
    fileprivate func getVolumeSlider() -> UISlider {
        guard let slider = volumeView.subviews.first as? UISlider else {
            debugLog("VolumeSlider getVolumeSlider ERROR: something went wrong with MPVolumeView volume slider")
            print("ERROR: something went wrong with MPVolumeView volume slider")
            return UISlider()
        }
        return slider
    }
}
