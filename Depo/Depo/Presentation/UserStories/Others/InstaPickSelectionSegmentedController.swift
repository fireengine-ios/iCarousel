//
//  InstaPickSelectionSegmentedController.swift
//  Depo_LifeTech
//
//  Created by Yaroslav Bondar on 15/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickSelectionSegmentedController: UIViewController {
    
    private let maxSelectingLimit = 5
    private var selectingLimit = 0
    
    private let topView = UIView()
    private let containerView = UIView()
    private let transparentGradientView = TransparentGradientView(style: .vertical, mainColor: .white)
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.tintColor = ColorConstants.darcBlueColor
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.TurkcellSaturaRegFont(size: 14)],
                                                for: .normal)
        return segmentedControl
    }()
    
    private let analyzeButton: BlueButtonWithWhiteText = {
        let analyzeButton = BlueButtonWithWhiteText()
        analyzeButton.isExclusiveTouch = true
        analyzeButton.setTitle(TextConstants.analyzeWithInstapick, for: .normal)
        return analyzeButton
    }()
    
    private var viewControllers: [UIViewController] = []
    
    private let instapickService: InstapickService = factory.resolve()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        topView.backgroundColor = .white
        containerView.backgroundColor = .white
        
        segmentedControl.addTarget(self, action: #selector(controllerDidChange), for: .valueChanged)
        analyzeButton.addTarget(self, action: #selector(analyzeWithInstapick), for: .touchUpInside)
        
        setupLayout()
        
        // TODO: localize
        navigationItem.title = "Photos Selected (\(0))"
        
        let cancelButton = UIBarButtonItem(title: "Cancel",
                                           font: UIFont.TurkcellSaturaDemFont(size: 19),
                                           tintColor: UIColor.white,
                                           accessibilityLabel: "Cancel",
                                           style: .plain,
                                           target: self,
                                           selector: #selector(closeSelf))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    private func setupLayout() {
        view.addSubview(topView)
        topView.addSubview(segmentedControl)
        view.addSubview(containerView)
        view.addSubview(transparentGradientView)
        view.addSubview(analyzeButton)
        
        let edgeOffset: CGFloat = 35
        let transparentGradientViewHeight = NumericConstants.instaPickSelectionSegmentedTransparentGradientViewHeight
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: edgeOffset).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -edgeOffset).isActive = true
        segmentedControl.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        transparentGradientView.translatesAutoresizingMaskIntoConstraints = false
        transparentGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        transparentGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        transparentGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        transparentGradientView.heightAnchor.constraint(equalToConstant: transparentGradientViewHeight).isActive = true
        
        analyzeButton.translatesAutoresizingMaskIntoConstraints = false
        analyzeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgeOffset).isActive = true
        analyzeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgeOffset).isActive = true
        analyzeButton.centerYAnchor.constraint(equalTo: transparentGradientView.centerYAnchor).isActive = true
        analyzeButton.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSelectingLimitAndStart()
    }
    
    /// one time called
    private func getSelectingLimitAndStart() {
        instapickService.getAnalyzesCount { [weak self] result in
            guard let `self` = self else {
                return
            }
            
            switch result {
            case .success(let analyzesCount):
                
                if analyzesCount.left < self.maxSelectingLimit {
                    self.selectingLimit = analyzesCount.left
                } else {
                    self.selectingLimit = self.maxSelectingLimit
                }
                self.setupScreenWithSelectingLimit(self.selectingLimit)
                
            case .failed(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    /// one time called
    private func setupScreenWithSelectingLimit(_ selectingLimit: Int) {
        viewControllers = [PhotoSelectionController(title: "Photos", selectingLimit: selectingLimit)]
        
        /// temp code
        // TODO: remove
        let vc1 = UIViewController()
        vc1.view.backgroundColor = .red
        vc1.title = "Placeholder 1"
        viewControllers.append(vc1)
        
        let vc2 = UIViewController()
        vc2.view.backgroundColor = .blue
        vc2.title = "Placeholder 2"
        viewControllers.append(vc2)
        
        DispatchQueue.toMain {
            self.selectController(at: 0)
            self.setupSegmentedControl()
        }
    }
    
    private func setupSegmentedControl() {
        assert(!viewControllers.isEmpty, "should not be empty")
        
        for (index, controller) in viewControllers.enumerated() {
            segmentedControl.insertSegment(withTitle: controller.title, at: index, animated: false)
        }
        
        /// selectedSegmentIndex == -1 after removeAllSegments
        segmentedControl.selectedSegmentIndex = 0
    }
    
    @objc private func closeSelf() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func analyzeWithInstapick() {
        
        // TODO: refactor
        guard let selectionController = childViewControllers.first as? PhotoSelectionController,
            let selectedItems = selectionController.selectedItems() else {
            assertionFailure()
            return
        }
        
        guard !selectedItems.isEmpty else {
            return
        }
        
        dismiss(animated: true, completion: {
            
            let imagesUrls = selectedItems.flatMap({ $0.metadata?.mediumUrl })
            let ids = selectedItems.flatMap({ $0.uuid })
            
            let topTexts = [TextConstants.instaPickAnalyzingText_0,
                            TextConstants.instaPickAnalyzingText_1,
                            TextConstants.instaPickAnalyzingText_2,
                            TextConstants.instaPickAnalyzingText_3,
                            TextConstants.instaPickAnalyzingText_4]
            
            let bottomText = TextConstants.instaPickAnalyzingBottomText
            if let currentController = UIApplication.topController() {
                let controller = InstaPickProgressPopup.createPopup(with: imagesUrls, topTexts: topTexts, bottomText: bottomText)
                currentController.present(controller, animated: true, completion: nil)
                
                let instapickService: InstapickService = factory.resolve()
                instapickService.startAnalyze(ids: ids, popupToDissmiss: controller)
            }
        })
    }
    
    @objc private func controllerDidChange(_ sender: UISegmentedControl) {
        selectController(at: sender.selectedSegmentIndex)
    }
    
    private func selectController(at selectedIndex: Int) {
        guard selectedIndex < viewControllers.count else {
            assertionFailure()
            return
        }
        
        childViewControllers.forEach { $0.removeFromParentVC() }
        add(childController: viewControllers[selectedIndex])
    }
    
    private func add(childController: UIViewController) {
        addChildViewController(childController)
        childController.view.frame = containerView.bounds
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.addSubview(childController.view)
        childController.didMove(toParentViewController: self)
    }
}

// MARK: - Static
extension InstaPickSelectionSegmentedController {
    static func controllerToPresent() -> UIViewController {
        let vc = InstaPickSelectionSegmentedController()
        let navVC = UINavigationController(rootViewController: vc)
        
        let navigationBar = navVC.navigationBar
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.TurkcellSaturaDemFont(size: 19)
        ]
        
        navigationBar.titleTextAttributes = textAttributes
        navigationBar.barTintColor = UIColor.lrTealish //bar's background
        navigationBar.barStyle = .black
        navigationBar.isTranslucent = false
        
        return navVC
    }
}
