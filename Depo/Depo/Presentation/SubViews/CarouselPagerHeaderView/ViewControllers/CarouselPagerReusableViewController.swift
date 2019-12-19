//
//  CarouselPagerReusableViewController.swift
//  Depo_LifeTech
//
//  Created by ÜNAL ÖZTÜRK on 12.12.2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CarouselPagerReusableViewController: UICollectionReusableView, UIScrollViewDelegate {
    
    private var carouselPageModels = [CarouselPageModel]()
    var maxHeight : CGFloat = 0
    
    @IBOutlet private weak var contentView: UIView! {
        willSet {
            newValue.layer.masksToBounds = false
            newValue.layer.cornerRadius = 4
            newValue.layer.shadowRadius = 5
            newValue.layer.shadowOpacity = 0.2
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOffset = .zero
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var pageControl: UIPageControl! {
        willSet {
            newValue.currentPage = 0
            newValue.hidesForSinglePage = true
            newValue.isUserInteractionEnabled = false
            newValue.pageIndicatorTintColor = ColorConstants.profileGrayColor
            newValue.currentPageIndicatorTintColor = ColorConstants.lightGrayColor
        }
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        setup()
    }
    
    private func setup() {
        scrollView.delegate = self
        
        carouselPageModels = CarouselPagerDataSource.getCarouselPageModels()
        configurateScrollView()
    }
    
    func configurateScrollView() {
        let width = scrollView.frame.width
        var x: CGFloat = 0
        
        for model in carouselPageModels {
            let subView = CarouselPageView(frame: CGRect(x: x, y: 0, width: width, height: maxHeight))
            x = x + width
            subView.setModel(model: model)
            scrollView.addSubview(subView)
        }
        
        scrollView.contentSize = CGSize(width: x, height: maxHeight)
        pageControl.numberOfPages = carouselPageModels.count
        pageControl.addTarget(self, action: #selector(valueChanged), for: UIControlEvents.valueChanged)
        
        pageControl.isHidden = (carouselPageModels.count <= 1)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let page = x / scrollView.frame.width
        pageControl.currentPage = Int(page)
    }
    
    @objc func valueChanged() {
        let page = pageControl.currentPage
        let x = CGFloat(page) * scrollView.frame.width
        let rect = CGRect(x: x, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
}
