//
//  LandingPageViewController.swift
//  lifedrive
//
//  Created by Andrei Novikau on 10/21/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class LandingPageViewController: ViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var pageControl: BorderDotsPageControl! {
        willSet {
            newValue.numberOfPages = NumericConstants.langingPageCount
            newValue.currentPageIndicatorTintColor = ColorConstants.billoBlue
            newValue.pageIndicatorTintColor = .clear
            newValue.borderColor = ColorConstants.billoBlue
        }
    }
    
    @IBOutlet private weak var startButton: BlueButtonWithMediumWhiteText! {
        willSet {
            newValue.setTitle(TextConstants.landingStartButton, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: Device.isIpad ? 20 : 15)//UIFont.RobotoRegularFont(size: Device.isIpad ? 20 : 15)
        }
    }

    private lazy var dataSource = LandingPageCollectionViewDataSource(collectionView: collectionView, delegate: self)
    
    private lazy var autoSyncRoutingService = AutoSyncRoutingService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var router = RouterVC()
    
    private let isTurkcell: Bool
    
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
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarHiddenForLandscapeIfNeed(true)
        trackScreen(pageNum: 1)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        dataSource.updateCollectionViewLayout()
    }

    private func openAutoSyncIfNeeded() {
        showSpinner()
        
        autoSyncRoutingService.checkNeededOpenAutoSync(success: { [weak self] needToOpenAutoSync in
            self?.hideSpinner()
            
            if needToOpenAutoSync {
                self?.goToSyncSettingsView()
            }
        }, error: { [weak self] error in
            self?.hideSpinner()
        })
    }
    
    private func goToSyncSettingsView() {
        let router = RouterVC()
        router.setNavigationController(controller: router.synchronyseScreen)
    }
    
    private func trackScreen(pageNum: Int) {
        analyticsService.logScreen(screen: .welcomePage(pageNum))
    }
    
    //MARK: Actions
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
        dataSource.scroll(to: sender.currentPage)
    }
    
    @IBAction private func onStartButton(_ sender: UIButton) {
        let storageVars: StorageVars = factory.resolve()
        storageVars.isNewAppVersionFirstLaunchTurkcellLanding = false
        
        if isTurkcell {
            openAutoSyncIfNeeded()
        } else {
            let settings = router.onboardingScreen
            router.setNavigationController(controller: settings)
        }
    }
}

// MARK: - LandingPageCollectionViewDataSourceDelegate

extension LandingPageViewController: LandingPageCollectionViewDataSourceDelegate {
    func pageIndexDidChange(_ newIndex: Int) {
        pageControl.currentPage = newIndex
        trackScreen(pageNum: newIndex + 1)
    }
}
