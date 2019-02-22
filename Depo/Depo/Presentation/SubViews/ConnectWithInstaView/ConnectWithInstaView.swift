//
//  ConnectWithInstaView.swift
//  Depo
//
//  Created by Harbros 3 on 1/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol ConnectWithInstaViewDelegate: class {
    func onConnectWithLoginInstaTap()
    func onConnectTap()
}

final class ConnectWithInstaView: UIView {

    @IBOutlet private weak var instagramImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private var view: UIView!
    
    weak var delegate: ConnectWithInstaViewDelegate?
    
    private var isLoginInsta = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupDesign()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height * 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    // MARK: Utility methods(Public)
    func configure(instaNickname: String? = nil) {
        isLoginInsta = instaNickname != nil

        setupFontsAndTextColors()

        nameLabel.isHidden = instaNickname == nil || Device.isIpad
        
        if let instaNickname = instaNickname {
            if let text = titleLabel.text, Device.isIpad {
                titleLabel.text = text + " @\(instaNickname)"
            } else {
                nameLabel.text = "@\(instaNickname)"
            }
        }
    }
    
    // MARK: Utility methods(Private)
    private func setupView() {
        let nibNamed = String(describing: ConnectWithInstaView.self)
        Bundle(for: ConnectWithInstaView.self).loadNibNamed(nibNamed, owner: self, options: nil)
        guard let view = view else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
    
    private func setupDesign() {
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = ColorConstants.lightGrayColor.cgColor
    }
    
    private func setupFontsAndTextColors() {
        titleLabel.textColor = ColorConstants.darkBlueColor
        nameLabel.textColor = ColorConstants.darkBlueColor
        
        nameLabel.font = UIFont.TurkcellSaturaMedFont(size: 16)
        
        titleLabel.text = isLoginInsta ? TextConstants.instaPickConnectedWithInstagramName : TextConstants.instaPickConnectedWithInstagram
        titleLabel.font = UIFont.TurkcellSaturaMedFont(size: isLoginInsta ? 16 : 18)
    }
    
    // MARK: Actions
    @IBAction private func onConnectTap(_ sender: UIButton) {
        if isLoginInsta {
            delegate?.onConnectWithLoginInstaTap()
        } else {
            delegate?.onConnectTap()
        }
    }
    
}
