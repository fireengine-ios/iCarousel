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
    @IBOutlet private weak var startUsingButton: UIButton! {
        willSet {
            newValue.setTitle(TextConstants.landingStartUsing, for: .normal)
            newValue.titleLabel?.font = .appFont(.bold, size: 14)
            newValue.setTitleColor(.white, for: .normal)
            newValue.setBackgroundColor(AppColor.landingButton.color, for: .normal)
            newValue.layer.cornerRadius = 23
            newValue.layer.masksToBounds = true
        }
    }
    
    lazy var dots: UIStackView = {
       let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 6
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()
    
    private lazy var autoSyncRoutingService = AutoSyncRoutingService()
    
    private var analyticsService: AnalyticsService = factory.resolve()
    
    private var isTurkcell: Bool
    
    private var currentPage: Int = 0 {
        willSet {
            if currentPage != newValue {
                trackScreen(pageNum: newValue + 1)
            }
        }
        didSet {
            updateDots()
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
  
        view.addSubview(dots)
        dots.translatesAutoresizingMaskIntoConstraints = false
        dots.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dots.widthAnchor.constraint(equalToConstant: 66).isActive = true
        dots.heightAnchor.constraint(equalToConstant: 6).isActive = true
        dots.bottomAnchor.constraint(equalTo: startUsingButton.topAnchor, constant: -20).isActive = true
        
        dots.addArrangedSubview(getCurrentPageView())
        dots.addArrangedSubview(getDefaultPageView())
        dots.addArrangedSubview(getDefaultPageView())
        dots.addArrangedSubview(getDefaultPageView())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ///For tracking first Welcome Page by GA when view controller appears
        trackScreen(pageNum: 1)
        
        let count = 4
        for i in 0..<count {
            let contr = PageForLanding(nibName: "PageForLanding", bundle: nil)
            contr.view.frame = CGRect(x: CGFloat(i) * scrollView.frame.size.width,
                                      y: 0,
                                      width: scrollView.frame.size.width,
                                      height: scrollView.frame.size.height)
            
            scrollView.addSubview(contr.view)
            contr.configurateForIndex(index: i)
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(count), height: scrollView.frame.size.height)
        
        scrollView.isPagingEnabled = true
    }
    
    //MARK: Utility Methods (public)
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let positionX = scrollView.contentOffset.x
        let page = Int(positionX/scrollView.frame.size.width)
        currentPage = page
    }
    
    //MARK: Utility Methods (private)
    private func scrollToPage(_ page: Int) {
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.size.width * CGFloat(page), y: 0), animated: true)
    }
    
    func updateDots() {
        dots.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        for i in 0..<4 {
            if i == currentPage {
                dots.addArrangedSubview(getCurrentPageView())
            } else {
                dots.addArrangedSubview(getDefaultPageView())
            }
        }
    }
    
    private func getDefaultPageView() -> UIView {
        let view = UIView()
        view.backgroundColor = AppColor.landingPageIndicator.color
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 6).isActive = true
        view.heightAnchor.constraint(equalToConstant: 6).isActive = true
        return view
    }
    
    private func getCurrentPageView() -> UIView {
        let view = UIView()
        view.backgroundColor = AppColor.landingPageIndicator.color
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.heightAnchor.constraint(equalToConstant: 6).isActive = true
        return view
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
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.WelcomePage(pageNum: pageNum))
        analyticsService.logScreen(screen: .welcomePage(pageNum))
    }
    
    @IBAction private func onStartUsingButton() {
        let storageVars: StorageVars = factory.resolve()
        storageVars.isShownLanding = true
        
        if isTurkcell {
            openAutoSyncIfNeeded()
        } else {
            let router = RouterVC()
            let settings = router.onboardingScreen
            router.setNavigationController(controller: settings)
        }
    }
    
}
