//
//  SegmentedController.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

protocol SegmentedChildController: class {
    func setTitle(_ title: String)
    func setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool)
    func setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool)
}
extension SegmentedChildController where Self: UIViewController {
    
    private var parentVC: SegmentedController? {
        return parent as? SegmentedController
    }
    
    func setTitle(_ title: String) {
        parentVC?.navigationItem.title = title
    }
    
    func setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        parentVC?.navigationItem.setLeftBarButtonItems(items, animated: animated)
    }
    
    func setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        parentVC?.navigationItem.setRightBarButtonItems(items, animated: animated)
    }
}

//protocol SegmentedControllerDelegate: class {
//    func segmentedControllerEndEditMode()
//}

final class SegmentedController: UIViewController, NibInit {
    
    static func initWithControllers(_ controllers: [UIViewController]) -> SegmentedController {
        let controller = SegmentedController.initFromNib()
        controller.setup(with: controllers)
        return controller
    } 
    
    @IBOutlet private weak var contanerView: UIView!
    
    @IBOutlet private weak var segmentedControl: UISegmentedControl! {
        willSet {
            newValue.tintColor = ColorConstants.darcBlueColor
            newValue.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.TurkcellSaturaRegFont(size: 14)],
                                            for: .normal)
            
        }
    }
    
    private var viewControllers: [UIViewController] = []
    
    // TODO: - make safe -
    var currentController: UIViewController {
        return viewControllers[segmentedControl.selectedSegmentIndex]
    }
    
//    weak var delegate: SegmentedControllerDelegate?
    
//    private lazy var cancelSelectionButton = UIBarButtonItem(
//        title: TextConstants.cancelSelectionButtonTitle,
//        font: .TurkcellSaturaDemFont(size: 19.0),
//        target: self,
//        selector: #selector(onCancelSelectionButton))
    
//    @objc private func onCancelSelectionButton() {
//        delegate?.segmentedControllerEndEditMode()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homePageNavigationBarStyle()//without refactor
//        navigationBarWithGradientStyle()
//        needShowTabBar = true
        setupSegmentedControl()
    }
    
    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        
        guard !viewControllers.isEmpty else {
            assertionFailure()
            return
        }
        
        for (index, controller) in viewControllers.enumerated() {
            segmentedControl.insertSegment(withTitle: controller.title, at: index, animated: false)
        }
        
        /// selectedSegmentIndex == -1 after removeAllSegments
        segmentedControl.selectedSegmentIndex = 0
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

//extension SegmentedController: PhotoVideoDataSourceDelegate {
//    func selectedModeDidChange(_ selectingMode: Bool) {
//        if selectingMode {
//            navigationItem.leftBarButtonItem = cancelSelectionButton
//        } else {
//            navigationItem.leftBarButtonItem = nil
//        }
//    }
//}

extension UIViewController {
    
    func removeFromParentVC() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }
}

