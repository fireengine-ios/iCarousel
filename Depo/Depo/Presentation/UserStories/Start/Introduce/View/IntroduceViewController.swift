//
//  IntroduceIntroduceViewController.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import QuartzCore
import WidgetKit

class IntroduceViewController: ViewController, IntroduceViewInput, IntroduceDataSourceEventsDelegate {

    var output: IntroduceViewOutput!
    var dataSource = IntroduceDataSource()
    
    @IBOutlet private weak var startUsingLifeBoxButton: RoundedInsetsButton!
    @IBOutlet private weak var haveAccountButton: RoundedInsetsButton!
    @IBOutlet private weak var haveAccountLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var pageControll: UIPageControl!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        } 
        scrollView.delegate = dataSource
        dataSource.scrollView = scrollView
        dataSource.pageControll = pageControll
        dataSource.delegate = self
        configurateView()
        output.viewIsReady()
    }
    
    func configurateView() {
        navigationBarHidden = true
        
        startUsingLifeBoxButton.setTitle(TextConstants.itroViewGoToRegisterButtonText, for: .normal)
        startUsingLifeBoxButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
        startUsingLifeBoxButton.backgroundColor = AppColor.marineTwoAndTealish.color
        startUsingLifeBoxButton.setTitleColor(.white, for: .normal)
        startUsingLifeBoxButton.insets = UIEdgeInsets(topBottom: 0, rightLeft: 12)
        startUsingLifeBoxButton.adjustsFontSizeToFitWidth()
        
        haveAccountLabel.text = TextConstants.alreadyHaveAccountTitle
        haveAccountLabel.font = UIFont.TurkcellSaturaDemFont(size: 15)
        haveAccountLabel.textColor = .white
        
        
        haveAccountButton.setTitle(TextConstants.introViewGoToLoginButtonText, for: .normal)
        haveAccountButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
        haveAccountButton.backgroundColor = .white
        haveAccountButton.setTitleColor(ColorConstants.marineTwo, for: .normal)
        haveAccountButton.insets = UIEdgeInsets(topBottom: 0, rightLeft: 12)
        haveAccountButton.adjustsFontSizeToFitWidth()
        
        backButtonForNavigationItem(title: TextConstants.backTitle)
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
