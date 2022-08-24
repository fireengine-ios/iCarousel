//
//  YearsView.swift
//  ScrollBar
//
//  Created by Bondar Yaroslav on 10/4/18.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import UIKit

final class YearsView: UIView {
    
    typealias YearsArray = [(key: Int, value: (monthNumber: Int, lines: Int))]
    
    private var scrollView: UIScrollView?

    private var labels = [UILabel]()
    private var labelsOffsetRatio = [CGFloat]()
    private var selfWidth: CGFloat = 85
    
    private let lock = NSLock()
    
    private let animationDuration = 0.3
    private let hideAnimationDelay = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        alpha = 0 /// intial state is hidden
    }
    
    // MARK: - UIScrollView
    
    func add(to scrollView: UIScrollView) {
        if self.scrollView == scrollView {
            return
        }
        
        freeScrollView()
        self.scrollView = scrollView
        
        config(scrollView: scrollView)
        scrollView.addSubview(self)
        layoutInScrollView()
        
    }
    
    private func config(scrollView: UIScrollView?) {
        guard let scrollView = scrollView else {
            return
        }
        
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: [.new], context: nil)
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: [.new], context: nil)
    }
    
    /// https://stackoverflow.com/a/51800670/5893286
    func freeScrollView() {
        guard let scrollView = scrollView else {
            return
        }
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
        self.scrollView = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        layoutInScrollView()
        setNeedsLayout()
    }
    
    private func layoutInScrollView() {
        guard let scrollView = scrollView else {
            return
        }

        frame.origin = CGPoint(x: scrollView.frame.width - selfWidth,
                               y: scrollView.contentOffset.y + scrollView.adjustedContentInset.top)
        frame.size = CGSize(width: selfWidth, height: scrollView.frame.height - (scrollView.adjustedContentInset.top + scrollView.adjustedContentInset.bottom))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lock.lock()
        defer { lock.unlock() }
        

        let minimumSpacingBetweenLabels: CGFloat = 2
        let availableSpace: CGFloat = frame.height - minimumSpacingBetweenLabels * (CGFloat(labels.count) - 1) - (labels.last?.frame.height ?? 0)

        var previousLabelOffset: CGFloat = 0
        for (label, offsetRatio) in zip(labels, labelsOffsetRatio) {
            var offset = offsetRatio * availableSpace

            if offset != 0 && offset <= previousLabelOffset {
                offset = previousLabelOffset + minimumSpacingBetweenLabels
            }

            label.frame = CGRect(x: 0, y: offset, width: label.frame.width, height: label.frame.height)
            previousLabelOffset = offset + label.frame.height

            label.isHidden = label.frame.maxY > frame.height
        }
    }
    
    func hideAnimated() {
        UIView.animate(withDuration: animationDuration, delay: hideAnimationDelay, animations: { 
            self.alpha = 0
        }, completion: nil)
    }
    
    func showAnimated() {
        UIView.animate(withDuration: self.animationDuration) { 
            self.alpha = 1
        }
    }
    
    // MARK: - Dates
    
    func update(by years: [YearHeightTuple]) {
        lock.lock()
        defer { lock.unlock() }

        updateLabelsOffsetRatio(from: years)
        udpateLabels(from: years)
    }

    private func updateLabelsOffsetRatio(from years: [YearHeightTuple]) {
        let totalSpace = scrollView?.contentSize.height ?? .zero

        var previusOffsetRatio: CGFloat = 0
        labelsOffsetRatio = [0]
        
        for year in years {
            let yearRatio = year.height / totalSpace
            
            let yearContentRatio = yearRatio + previusOffsetRatio
            
            previusOffsetRatio = yearContentRatio
            labelsOffsetRatio.append(yearContentRatio)
        }
    }
    
    private func udpateLabels(from yearsArray: [YearHeightTuple]) {
        DispatchQueue.main.async {
            self.lock.lock()
            
            self.labels.forEach { $0.removeFromSuperview() }
            self.labels.removeAll()
            
            for entry in yearsArray {
                let labelText: String
                if let year = entry.year {
                    labelText = String(year)
                } else {
                    labelText = TextConstants.photosVideosViewMissingDatesHeaderText
                }
                let label = self.createLabel(for: labelText)
                self.addSubview(label)
                self.labels.append(label)
            }
            
            self.lock.unlock()
        }
    }
    
    private func createLabel(for text: String) -> UILabel {
        let label = TextInsetsLabel()
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.appFont(.regular, size: 12)
        label.backgroundColor = AppColor.secondaryBackground.withAlphaComponent(0.7)
        label.textColor = AppColor.label.color
        label.textInsets = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
        label.sizeToFit()
        label.layer.cornerRadius = label.frame.height * 0.5
        label.layer.masksToBounds = true
        return label
    }
}
