//
//  InstaPickSelectionSegmentedController.swift
//  Depo_LifeTech
//
//  Created by Yaroslav Bondar on 15/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickSelectionSegmentedController: UIViewController {
    
    private let topView = UIView()
    private let contanerView = UIView()
    private let transparentGradientView = TransparentGradientView(style: .vertical, mainColor: .white)
    
    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.tintColor = ColorConstants.darcBlueColor
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.TurkcellSaturaRegFont(size: 14)],
                                                for: .normal)
        return segmentedControl
    }()
    
    private var viewControllers: [UIViewController] = [PhotoSelectionController()]
    
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
        contanerView.backgroundColor = .white
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(topView)
        topView.addSubview(segmentedControl)
        view.addSubview(contanerView)
        let edgeOffset: CGFloat = 35
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        contanerView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        topView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        segmentedControl.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: edgeOffset).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -edgeOffset).isActive = true
        segmentedControl.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        
        contanerView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        contanerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contanerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contanerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        segmentedControl.addTarget(self, action: #selector(controllerDidChange), for: .valueChanged)
        
        view.addSubview(transparentGradientView)
        let transparentGradientViewHeight = NumericConstants.instaPickSelectionSegmentedTransparentGradientViewHeight
        transparentGradientView.translatesAutoresizingMaskIntoConstraints = false
        transparentGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        transparentGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        transparentGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        transparentGradientView.heightAnchor.constraint(equalToConstant: transparentGradientViewHeight).isActive = true
        
        let button = BlueButtonWithWhiteText()
        button.isExclusiveTouch = true
        button.setTitle(TextConstants.analyzeWithInstapick, for: .normal)
        button.addTarget(self, action: #selector(analyzeWithInstapick), for: .touchUpInside)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edgeOffset).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edgeOffset).isActive = true
        button.centerYAnchor.constraint(equalTo: transparentGradientView.centerYAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// test code
//        let vc1 = UIViewController()
//        vc1.view.backgroundColor = .red
//        vc1.title = "Title 1"
//        viewControllers.append(vc1)
//
//        let vc2 = UIViewController()
//        vc2.view.backgroundColor = .blue
//        vc2.title = "Title 2"
//        viewControllers.append(vc2)
        
        selectController(at: 0)
        setupSegmentedControl()
    }
    
    private func setupSegmentedControl() {
        assert(!viewControllers.isEmpty, "should not be empty")
        
        for (index, controller) in viewControllers.enumerated() {
            segmentedControl.insertSegment(withTitle: controller.title, at: index, animated: false)
        }
        
        /// selectedSegmentIndex == -1 after removeAllSegments
        segmentedControl.selectedSegmentIndex = 0
    }
    
    @objc private func analyzeWithInstapick() {
        print("analyzeWithInstapick")
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
        childController.view.frame = contanerView.bounds
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contanerView.addSubview(childController.view)
        childController.didMove(toParentViewController: self)
    }
}
