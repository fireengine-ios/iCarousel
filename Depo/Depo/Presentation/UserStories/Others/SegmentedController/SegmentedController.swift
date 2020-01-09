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
        parentVC?.navigationItem.leftBarButtonItems = nil
        parentVC?.navigationItem.setLeftBarButtonItems(items, animated: animated)
    }

    func setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        parentVC?.navigationItem.rightBarButtonItems = nil
        parentVC?.navigationItem.setRightBarButtonItems(items, animated: animated)
    }
}

//protocol SegmentedControllerDelegate: class {
//    func segmentedControllerEndEditMode()
//}

class SegmentedController: BaseViewController, NibInit {
    
    enum Alignment {
        case center
        case adjustToWidth
    }
    
    static func initWithControllers(_ controllers: [UIViewController], alignment: Alignment) -> SegmentedController {
        let controller = SegmentedController.initFromNib()
        controller.setup(with: controllers, alignment: alignment)
        return controller
    }
    
    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet private weak var segmentedControlContainer: UIView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl! {
        willSet {
            newValue.tintColor = ColorConstants.darkBlueColor
            newValue.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.TurkcellSaturaRegFont(size: 14)],
                                            for: .normal)
        }
    }
    
    @IBOutlet private var lefttAnchor: NSLayoutConstraint!
    @IBOutlet private var rightAnchor: NSLayoutConstraint!
    
    private(set) var viewControllers = [BaseViewController]()
    private var alignment: Alignment = .center
    
    var currentController: UIViewController {
        return viewControllers[safe: segmentedControl.selectedSegmentIndex] ?? UIViewController()
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

        needToShowTabBar = true
        setupSegmentedControl()
        setupAlignment()
    }
    
    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        
        guard !viewControllers.isEmpty else {
            assertionFailure()
            return
        }
        
        for (index, controller) in viewControllers.enumerated() {
            if let image = controller.segmentImage?.image {
                segmentedControl.insertSegment(with: image, at: index, animated: false)
            } else {
                segmentedControl.insertSegment(withTitle: controller.title, at: index, animated: false)
            }
        }
        
        /// selectedSegmentIndex == -1 after removeAllSegments
        segmentedControl.selectedSegmentIndex = 0
        setupSelectedController(viewControllers[segmentedControl.selectedSegmentIndex])
    }
    
    func setup(with controllers: [UIViewController], alignment: Alignment) {
        guard !controllers.isEmpty, let controllers = controllers as? [BaseViewController] else {
            assertionFailure()
            return
        }
        viewControllers = controllers
        self.alignment = alignment
    }
    
    private func setupAlignment() {
        switch alignment {
        case .center:
            segmentedControl.leadingAnchor.constraint(greaterThanOrEqualTo: segmentedControlContainer.leadingAnchor, constant: 16).activate()
            segmentedControlContainer.trailingAnchor.constraint(greaterThanOrEqualTo: segmentedControl.trailingAnchor, constant: 16).activate()
        case .adjustToWidth:
            segmentedControl.leadingAnchor.constraint(equalTo: segmentedControlContainer.leadingAnchor, constant: 16).activate()
            segmentedControlContainer.trailingAnchor.constraint(equalTo: segmentedControl.trailingAnchor, constant: 16).activate()
        }
    }
    
    func switchSegment(to index: Int) {
        if segmentedControl.numberOfSegments > index {
            segmentedControl.selectedSegmentIndex = index
            segmentDidChange(segmentedControl)
        }
    }
    
    @IBAction private func segmentDidChange(_ sender: UISegmentedControl) {
        
        let selectedIndex = sender.selectedSegmentIndex
        
        guard selectedIndex < viewControllers.count else {
            assertionFailure()
            return
        }
        
        childViewControllers.forEach { $0.removeFromParentVC() }
        setupSelectedController(viewControllers[selectedIndex])
    }
    
    private func setupSelectedController(_ controller: BaseViewController) {
        add(childController: controller)
        floatingButtonsArray = controller.floatingButtonsArray
    }
    
    private func add(childController: UIViewController) {
        addChildViewController(childController)
        childController.view.frame = containerView.bounds
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.addSubview(childController.view)
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

