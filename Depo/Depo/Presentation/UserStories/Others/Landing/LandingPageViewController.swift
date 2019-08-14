//
//  LandingPageViewController.swift
//  Depo
//
//  Created by Oleg on 03.05.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class LandingPageViewController: ViewController, UIScrollViewDelegate {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var pageControll: UIPageControl!
    @IBOutlet private weak var startUsingButton: BlueButtonWithMediumWhiteText! {
        didSet {
            startUsingButton.setTitle(TextConstants.landingStartUsing, for: .normal)
        }
    }
    
    private lazy var autoSyncRoutingService = AutoSyncRoutingService()
    
    private var analyticsService: AnalyticsService = factory.resolve()
    
    private var isTurkcell: Bool
    
    private var currentPage: Int = 0 {
        willSet {
            if currentPage != newValue {
                trackScreen(pageNum: newValue+1)
            }
        }
    }
    
    //MARK: lifecycle
    init(isTurkcell: Bool) {
        self.isTurkcell = isTurkcell
        
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        isTurkcell = false
        
        assertionFailure("called from xib")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarHiddenForLandscapeIfNeed(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ///For tracking first Welcome Page by GA when view controller appears
        trackScreen(pageNum: 1)
        
        let count = 6
        for i in 0...count {
            
            let contr = PageForLanding(nibName: "PageForLanding", bundle: nil)
            contr.view.frame = CGRect(x: CGFloat(i) * scrollView.frame.size.width,
                                      y: 0,
                                      width: scrollView.frame.size.width,
                                      height: scrollView.frame.size.height)
            
            scrollView.addSubview(contr.view)
            contr.configurateForIndex(index: i)
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(count + 1),
                                        height: scrollView.frame.size.height)
        
        scrollView.isPagingEnabled = true
        pageControll.numberOfPages = count + 1
    }
    
    //MARK: Utility Methods (public)
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
            pageControll.currentPageIndicatorTintColor = ColorConstants.darkBlueColor
        }
    }
    
    //MARK: Utility Methods (private)
    private func scrollToPage(_ page: Int) {
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.size.width * CGFloat(page),
                                            y: 0),
                                    animated: true)
    }
    
    private func openAutoSyncIfNeeded() {
        showSpinner()
        
        autoSyncRoutingService.checkNeededOpenAutoSync(success: { [weak self] needToOpenAutoSync in
            self?.hideSpinner()
            
            if needToOpenAutoSync {
                self?.goToSyncSettingsView()
            }
        }) { [weak self] error in
            self?.hideSpinner()
        }
    }
    
    private func goToSyncSettingsView() {
        let router = RouterVC()
        router.setNavigationController(controller: router.synchronyseScreen)
    }
    
    private func trackScreen(pageNum: Int) {
        analyticsService.logScreen(screen: .welcomePage(pageNum))
    }
    
    //MARK: Actions
    @IBAction func pageControlChangeValue(_ sender: UIPageControl) {
        scrollToPage(sender.currentPage)
    }
    
    @IBAction private func onStartUsingButton() {
        let storageVars: StorageVars = factory.resolve()
        storageVars.isNewAppVersionFirstLaunchTurkcellLanding = false
        
        if isTurkcell {
            openAutoSyncIfNeeded()
        } else {
            let router = RouterVC()
            let settings = router.onboardingScreen
            router.setNavigationController(controller: settings)
        }
    }
    
}
