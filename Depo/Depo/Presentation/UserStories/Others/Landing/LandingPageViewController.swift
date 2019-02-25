//
//  LandingPageViewController.swift
//  Depo
//
//  Created by Oleg on 03.05.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class LandingPageViewController: ViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControll: UIPageControl!
    
    private lazy var autoSyncRoutingService = AutoSyncRoutingService()
    
    @IBOutlet private weak var startUsingButton: BlueButtonWithMediumWhiteText! {
        didSet {
            startUsingButton.setTitle(TextConstants.landingStartUsing, for: .normal)
        }
    }
    
    @IBAction func onStartUsingButton() {
        let storageVars: StorageVars = factory.resolve()
        storageVars.isNewAppVersionFirstLaunchTurkcellLanding = false
        let router = RouterVC()
        if isTurkcell {
            router.setNavigationController(controller: router.synchronyseScreen)
        } else {
            let settings = router.onboardingScreen
            router.setNavigationController(controller: settings)
        }
        
    }

    var isTurkcell = false
    
    private var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarHiddenForLandscapeIfNeed(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let count = 6
        for i in 0...count {
            let contr = PageForLanding(nibName: "PageForLanding", bundle: nil)
            
            contr.view.frame = CGRect(x: CGFloat(i) * scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
            
            scrollView.addSubview(contr.view)
            contr.configurateForIndex(index: i)
        }
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(count + 1), height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true
        pageControll.numberOfPages = count + 1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let positionX = scrollView.contentOffset.x
        let page = Int(positionX/scrollView.frame.size.width)
        pageControll.currentPage = page
        currentPage = page
        if page == 0 {
            pageControll.pageIndicatorTintColor = ColorConstants.whiteColor
            pageControll.currentPageIndicatorTintColor = ColorConstants.lightGrayColor
        } else {
            pageControll.pageIndicatorTintColor = ColorConstants.blueColor
            pageControll.currentPageIndicatorTintColor = ColorConstants.darcBlueColor
        }
    }

    @IBAction func pageControlChangeValue(_ sender: UIPageControl) {
        currentPage = sender.currentPage
        scrollToPage(currentPage)
    }

    // MARK: - Utility methods
    private func scrollToPage(_ page: Int) {
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.size.width * CGFloat(currentPage), y: 0), animated: true)
    }
    
}
