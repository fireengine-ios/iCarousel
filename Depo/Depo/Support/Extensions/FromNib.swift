//
//  FromNib.swift
//  Passcode
//
//  Created by Bondar Yaroslav on 10/2/17.
//  Copyright © 2017 Bondar Yaroslav. All rights reserved.
//

import UIKit

/// for embedded views from nib
protocol FromNib: class {
    func setupFromNib()
}

extension FromNib where Self: UIView {
    func setupFromNib() {
        let view = loadFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)
    }
    
    private func loadFromNib() -> UIView {
        let nibName = String(describing: type(of: self))
        let nib = UINib(nibName: nibName, bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}


protocol NibInit {}
extension NibInit where Self: UIView {
    static func initFromNib() -> Self {
        let nibName = String(describing: Self.self)
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! Self
    }
}
extension NibInit where Self: UIViewController {
    static func initFromNib() -> Self {
        let nibName = String(describing: Self.self)
        return self.init(nibName: nibName, bundle: nil)
    }
}
