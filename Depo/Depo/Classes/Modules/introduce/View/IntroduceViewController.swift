//
//  IntroduceIntroduceViewController.swift
//  Depo
//
//  Created by Oleg on 12/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit
import QuartzCore

class IntroduceViewController: UIViewController, IntroduceViewInput {

    var output: IntroduceViewOutput!
    var dataSource = IntroduceDataSource()
    
    @IBOutlet weak var startUsingLifeBoxButton: UIButton!
    @IBOutlet weak var haveAccountButton: ButtonWithCorner!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControll: UIPageControl!

    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = dataSource
        dataSource.scrollView = scrollView
        dataSource.pageControll = pageControll
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configurateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        output.viewIsReady()
    }
    
    func configurateView(){
        navigationController?.navigationBar.isHidden = true
        
        startUsingLifeBoxButton.setTitle(TextConstants.itroViewGoToRegisterButtonText,
                                              for: UIControlState.normal)
        startUsingLifeBoxButton.backgroundColor = ColorConstants.whiteColor
        startUsingLifeBoxButton.setTitleColor(ColorConstants.blueColor,
                                                   for: UIControlState.normal)
        startUsingLifeBoxButton.titleLabel?.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 20)
        startUsingLifeBoxButton.layer.cornerRadius = startUsingLifeBoxButton.frame.size.height * 0.5
        
        haveAccountButton.setTitle(TextConstants.introViewGoToLoginButtonText, for: UIControlState.normal)
        haveAccountButton.backgroundColor = UIColor.clear
        haveAccountButton.setTitleColor(ColorConstants.whiteColor, for: UIControlState.normal)
        haveAccountButton.titleLabel?.font = UIFont(name: FontNamesConstant.turkcellSaturaBol, size: 12)
    }


    // MARK: IntroduceViewInput
    func setupInitialState(models : [IntroduceModel]){
        dataSource.configurateScrollViewWithModels(models: models)
    }
    
    // MARK: Actions
    
    @IBAction func onStartUsingLifeBoxButton(){
        output.onStartUsingLifeBox()
    }
    
    @IBAction func onHaveAccountButton(){
        output.onLoginButton()
    }
    
}
