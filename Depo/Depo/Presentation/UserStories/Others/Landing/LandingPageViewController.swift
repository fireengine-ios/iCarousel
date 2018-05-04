//
//  LandingPageViewController.swift
//  Depo
//
//  Created by Oleg on 03.05.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

class LandingPageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControll: UIPageControl!
    
    @IBOutlet private weak var startUsingButton: BlueButtonWithWhiteText! {
        didSet {
            startUsingButton.setTitle("!!sdfsfsfd!", for: .normal)
        }
    }
    
    @IBAction func onStartUsingButton() {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView.showsHorizontalScrollIndicator = true
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
        if page == 0 {
            pageControll.pageIndicatorTintColor = ColorConstants.whiteColor
            pageControll.currentPageIndicatorTintColor = ColorConstants.lightGrayColor
        } else {
            pageControll.pageIndicatorTintColor = ColorConstants.blueColor
            pageControll.currentPageIndicatorTintColor = ColorConstants.darcBlueColor
        }
    }

}
