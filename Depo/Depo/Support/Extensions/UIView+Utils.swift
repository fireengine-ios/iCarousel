//
//  UIView+Utils.swift
//  Depo_LifeTech
//
//  Created by Harbros Agency on 1/23/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit
import MBProgressHUD

extension UIView {
    var safeTopAnchor: NSLayoutYAxisAnchor {
        return safeAreaLayoutGuide.topAnchor
    }

    var safeLeadingAnchor: NSLayoutXAxisAnchor {
      return safeAreaLayoutGuide.leadingAnchor
    }

    var safeTrailingAnchor: NSLayoutXAxisAnchor {
        return safeAreaLayoutGuide.trailingAnchor
    }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        return safeAreaLayoutGuide.bottomAnchor
    }

    var frameOnWindow: CGRect {
        guard let superview = superview, let window = window else {
            return frame
        }
        return superview.convert(frame, to: window)
    }
    
    func setSubviewsHidden(_ isHidden: Bool) {
        subviews.forEach({ $0.isHidden = isHidden })
    }
    
    func pinToSuperviewEdges(offset: CGFloat = 0.0) {
        guard let superview = superview else {
            assertionFailure()
            return
        }
        topAnchor.constraint(equalTo: superview.topAnchor, constant: offset).activate()
        bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -offset).activate()
        leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: offset).activate()
        trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -offset).activate()
    }
    
    func pinToSuperviewEdges(offset: UIEdgeInsets) {
        guard let superview = superview else {
            assertionFailure()
            return
        }
        topAnchor.constraint(equalTo: superview.topAnchor, constant: offset.top).activate()
        bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -offset.bottom).activate()
        leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: offset.left).activate()
        trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -offset.right).activate()
    }
    
    /// returns all subviews except self
    func allSubviews<T: UIView>(of: T.Type) -> [T] {
        var typeSubviews = [T]()
        
        func checkViewForType(_ view: UIView) {
            if let view = view as? T {
                typeSubviews.append(view)
            }
            view.subviews.forEach { checkViewForType($0) }
        }
        
        subviews.forEach { checkViewForType($0) }
        return typeSubviews
    }
    
    func firstSubview<T: UIView>(of: T.Type) -> T? {
        var viewWeAreLookingFor: T?
        
        func checkViewForType(_ view: UIView) {
            guard viewWeAreLookingFor == nil else {
                return
            }
            if let view = view as? T {
                viewWeAreLookingFor = view
                return
            }
            view.subviews.forEach {
                checkViewForType($0)
            }
        }
        subviews.forEach { checkViewForType($0) }
        return viewWeAreLookingFor
    }
    
    func sizeToFit(width: CGFloat) -> CGSize {
        // need for correct calculation
        bounds.size.width = width
        layoutIfNeeded()
        
        let fittingSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        return systemLayoutSizeFitting(fittingSize,
                                       withHorizontalFittingPriority: .required,
                                       verticalFittingPriority: .defaultLow)
    }
    
    static func makeSeparator(width: CGFloat, offset: CGFloat) -> UIView {
        var frame = CGRect(origin: .zero, size: CGSize(width: width, height: 1))
        let view = UIView(frame: frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        frame.origin.x = offset
        frame.size.width -= offset * 2
        let separator = UIView(frame: frame)
        separator.backgroundColor = ColorConstants.darkBorder.withAlphaComponent(0.3)
        view.addSubview(separator)
        separator.autoresizingMask = [.flexibleWidth]
        return view
    }
}

extension UIView: Waiting {
    func showSpinerWithCancelClosure(_ cancel: @escaping VoidHandler) {

    }

    func showFullscreenHUD(with text: String?, and cancelHandler: @escaping VoidHandler) {
        
    }

    func showSpinner() {
        DispatchQueue.main.async {
            _ = MBProgressHUD.showAdded(to: self, animated: true)
        }
    }

    func showSpinnerOnView(_ view: UIView) {
        DispatchQueue.main.async {
            _ = MBProgressHUD.showAdded(to: view, animated: true)
        }
    }

    func showSpinnerIncludeNavigationBar() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
            let hud = MBProgressHUD.showAdded(to: window, animated: true)
            window.addSubview(hud)
        }
    }

    func hideSpinnerIncludeNavigationBar() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return }
            MBProgressHUD.hideAllHUDs(for: window, animated: true)
        }
    }

    func hideSpinner() {
        DispatchQueue.main.async {
            MBProgressHUD.hideAllHUDs(for: self, animated: true)
        }
    }

    func hideSpinerForView(_ view: UIView) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
}
