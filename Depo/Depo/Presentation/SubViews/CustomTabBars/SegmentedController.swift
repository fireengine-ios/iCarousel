//
//  SegmentedController.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class SegmentedController: UIViewController, NibInit {
    
    static func initWithControllers(_ controllers: [UIViewController]) -> SegmentedController {
        let controller = SegmentedController.initFromNib()
        controller.setup(with: controllers)
        return controller
    } 
    
    @IBOutlet private weak var contanerView: UIView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    private var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarWithGradientStyle()
//        needShowTabBar = true
        
        add(childController: viewControllers[segmentedControl.selectedSegmentIndex])
    }
    
    private func setup(with controllers: [UIViewController]) {
        guard !controllers.isEmpty else {
            return
        }
        viewControllers = controllers
    }
    
    @IBAction private func segmentDidChange(_ sender: UISegmentedControl) {
        
        let selectedIndex = sender.selectedSegmentIndex
        
        guard selectedIndex < viewControllers.count else {
            return
        }
        
        childViewControllers.forEach { $0.removeFromParentVC() }
        add(childController: viewControllers[selectedIndex])
    }
    
    private func add(childController: UIViewController) {
        addChildViewController(childController)
        childController.view.frame = contanerView.bounds
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contanerView.addSubview(childController.view)
        childController.didMove(toParentViewController: self)
    }
}

extension UIViewController {
    
    func removeFromParentVC() {
        view.removeFromSuperview()
        removeFromParentViewController()
    }
}

