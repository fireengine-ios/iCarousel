//
//  IntroduceIntroduceViewController.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import QuartzCore

class IntroduceViewController: ViewController, IntroduceViewInput, IntroduceDataSourceEventsDelegate {

    var output: IntroduceViewOutput!
    var dataSource = IntroduceDataSource()
    
    @IBOutlet weak var startUsingLifeBoxButton: WhiteButtonWithRoundedCorner!
    @IBOutlet weak var haveAccountButton: ButtonWithCorner!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControll: UIPageControl!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = dataSource
        dataSource.scrollView = scrollView
        dataSource.pageControll = pageControll
        dataSource.delegate = self
        configurateView()
        output.viewIsReady()
    }
    
    func configurateView() {
        hidenNavigationBarStyle()
        startUsingLifeBoxButton.setTitle(TextConstants.itroViewGoToRegisterButtonText, for: .normal)
        haveAccountButton.setTitle(TextConstants.introViewGoToLoginButtonText, for: .normal)
        backButtonForNavigationItem(title: TextConstants.backTitle)
    }

    override var preferredNavigationBarStyle: NavigationBarStyle {
        return .clear
    }

    // MARK: IntroduceViewInput
    func setupInitialState(models: [IntroduceModel]) {
        dataSource.configurateScrollViewWithModels(models: models)
    }
    
    // MARK: Actions
    
    @IBAction func onStartUsingLifeBoxButton() {
        output.onStartUsingLifeBox()
    }
    
    @IBAction func onHaveAccountButton() {
        output.onLoginButton()
    }
    
    func pageChanged(page: Int) {
        output.pageChanged(page: page)
    }
    
}
