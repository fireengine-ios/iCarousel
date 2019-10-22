//
//  LandingPageViewController.swift
//  lifedrive
//
//  Created by Andrei Novikau on 10/21/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class LandingPageViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var pageControl: UIPageControl! {
        willSet {
            newValue.numberOfPages = NumericConstants.langingPageCount
            newValue.currentPageIndicatorTintColor = ColorConstants.billoBlue
            newValue.pageIndicatorTintColor = ColorConstants.lightGray
        }
    }
    
    @IBOutlet private weak var startButton: BlueButtonWithMediumWhiteText! {
        willSet {
            newValue.setTitle(TextConstants.landingStartUsing, for: .normal)
        }
    }

    private lazy var dataSource = LandingPageCollectionViewDataSource(collectionView: collectionView, delegate: self)
    
    private lazy var autoSyncRoutingService = AutoSyncRoutingService()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var router = RouterVC()
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
    @IBAction func pageControlChangeValue(_ sender: UIPageControl) {
        dataSource.scroll(to: sender.currentPage)
    }
    
    @IBAction private func onStartUsingButton() {
//        let storageVars: StorageVars = factory.resolve()
//        storageVars.isNewAppVersionFirstLaunchTurkcellLanding = false
        
        let settings = router.onboardingScreen
        router.setNavigationController(controller: settings)
    }
    
}

// MARK: - LandingPageCollectionViewDataSourceDelegate

extension LandingPageViewController: LandingPageCollectionViewDataSourceDelegate {
    func pageIndexDidChange(_ newIndex: Int) {
        pageControl.currentPage = newIndex
    }
}
