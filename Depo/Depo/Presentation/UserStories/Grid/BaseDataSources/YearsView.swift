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
    
    private let handleViewHalfHeight: CGFloat = 32
    
    private var labels = [UILabel]()
    private var labelsOffsetRatio = [CGFloat]()
    private var selfWidth: CGFloat = 85
    
    private var cellHeight: CGFloat = 1
    private var headerHeight: CGFloat = 1
    private var lineSpaceHeight: CGFloat = 1
    private var numberOfColumns = 1
    
    private var additionalSections: [(name: String, count: Int)] = []
    
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
        
        frame = CGRect(x: scrollView.frame.width - selfWidth,
                       y: scrollView.contentOffset.y,
                       width: selfWidth,
                       height: scrollView.frame.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        lock.lock()
//        defer { lock.unlock() }
        
        var lastLabelOffset: CGFloat = 0
        
        for (label, offsetRatio) in zip(labels, labelsOffsetRatio) {
            let offet: CGFloat
            if offsetRatio == 0 {
                offet = handleViewHalfHeight - label.frame.height * 0.5
            } else {
                /// 0.98 is magic number to correct offset
                offet = offsetRatio * 0.98 * (frame.height - handleViewHalfHeight) + label.frame.height * 0.5
            }
            
            if lastLabelOffset > offet {
                label.isHidden = true
                continue
            }
            label.isHidden = false
            
            label.frame = CGRect(x: 0, y: offet, width: label.frame.width, height: label.frame.height)
            lastLabelOffset = offet + label.frame.height
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
    
    func update(by yearMonthValues: [YearMonthTuple]) {
//        lock.lock()
//        defer { lock.unlock() }
        
        if yearMonthValues.isEmpty {
            return
        }
        
        let yearsArray = getYearsArray(from: yearMonthValues)
        let newYearsArray = updateLabelsOffsetRatio(from: yearsArray)
        udpateLabels(from: newYearsArray)
    }
    
    func update(cellHeight: CGFloat, headerHeight: CGFloat, numberOfColumns: Int) {
        self.cellHeight = cellHeight
        self.headerHeight = headerHeight
        self.numberOfColumns = numberOfColumns
        
        /// we need to attach labels to the left side of last column
        selfWidth = cellHeight
    }
    
    func update(additionalSections: [(name: String, count: Int)]) {
        self.additionalSections = additionalSections
    }
    
    private func getYearsArray(from yearMonthValues: [YearMonthTuple]) -> YearsArray {
        var yearByMonthNumberOfDays: [Int: [Int: Int]] = [:]
        
        for date in yearMonthValues {
            
            let year = date.year
            let month = date.month
            
            if yearByMonthNumberOfDays[year] == nil {
                yearByMonthNumberOfDays[year] = [month: 1]
            } else {
                if yearByMonthNumberOfDays[year]![month] == nil {
                    yearByMonthNumberOfDays[year]![month] = 1 
                } else {
                    yearByMonthNumberOfDays[year]![month]! += 1
                }
            }
        }
        
        var yearByMonthNumberLinesNumber: [Int: (monthNumber: Int, lines: Int)] = [:]
        
        yearByMonthNumberOfDays.forEach { (year, month) in
            let monthLines = month.reduce(0, { (sum, month) in
                let daysNumber = month.value
                let addtionalLine = (daysNumber % numberOfColumns == 0) ? 0 : 1 
                return sum + daysNumber / numberOfColumns + addtionalLine
            })
            
            yearByMonthNumberLinesNumber[year, default: (0, 0)].lines += monthLines
            yearByMonthNumberLinesNumber[year, default: (0, 0)].monthNumber += month.keys.count
        }
        
        let yearsArray = yearByMonthNumberLinesNumber.sorted { year1, year2 in
            year1.key > year2.key
        }
        
        return yearsArray
    }
    
    private func updateLabelsOffsetRatio(from yearsArray: YearsArray) -> YearsArray {
        
        let totalLines = yearsArray.reduce(0) { sum, arg in
            sum + arg.value.lines
        }
        
        let totalMonthes = yearsArray.reduce(0) { sum, arg in
            sum + arg.value.monthNumber
        }
        
        let additionalSectionsLines = additionalSections.map { section -> Int in
            let addtionalLine = (section.count % numberOfColumns == 0) ? 0 : 1 
            return section.count / numberOfColumns + addtionalLine
        }
        
        let totalAdditionalSectionsLines = additionalSectionsLines.reduce(0) { $0 + $1 }
        
        let totalSpace = CGFloat(totalLines + totalAdditionalSectionsLines) * cellHeight + headerHeight * CGFloat(totalMonthes + additionalSections.count) + lineSpaceHeight * CGFloat(totalLines + totalMonthes + additionalSections.count + totalAdditionalSectionsLines)
        
        var previusOffsetRation: CGFloat = 0
        labelsOffsetRatio = [0]
        
        for year in yearsArray {
            let linesSpaceHeight = lineSpaceHeight * CGFloat(year.value.lines + year.value.monthNumber)
            let headersHeight = CGFloat(year.value.monthNumber) * headerHeight
            let cellsHeight = CGFloat(year.value.lines) * cellHeight
            let yearRatio = (cellsHeight + headersHeight + linesSpaceHeight) / totalSpace
            
            let yearContentRatio = yearRatio + previusOffsetRation
            
            previusOffsetRation = yearContentRatio
            labelsOffsetRatio.append(yearContentRatio)
        }
        
        /// dropLast bcz we put 0 to labelsOffsetRatio
        for additionalSectionLinesNumber in additionalSectionsLines.dropLast() {
            let linesSpaceHeight = lineSpaceHeight * CGFloat(additionalSectionLinesNumber + 1) /// +1 for section header
            let headersHeight = headerHeight
            let cellsHeight = CGFloat(additionalSectionLinesNumber) * cellHeight
            let yearRatio = (cellsHeight + headersHeight + linesSpaceHeight) / totalSpace
            
            let yearContentRatio = yearRatio + previusOffsetRation
            
            previusOffsetRation = yearContentRatio
            labelsOffsetRatio.append(yearContentRatio)
        }
        
        return yearsArray
    }
    
    private func udpateLabels(from yearsArray: YearsArray) {
        DispatchQueue.main.async {
//            self.lock.lock()
            
            self.labels.forEach { $0.removeFromSuperview() }
            self.labels.removeAll()
            
            for year in yearsArray {
                let label = self.createLabel(for: "\(year.key)")
                self.addSubview(label)
                self.labels.append(label)
            }
            
            for section in self.additionalSections {
                let label = self.createLabel(for: section.name)
                self.addSubview(label)
                self.labels.append(label)
            }
//            self.lock.unlock()
        }
    }
    
    private func createLabel(for text: String) -> UILabel {
        let label = TextInsetsLabel()
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.TurkcellSaturaDemFont(size: 12)
        label.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        label.textColor = UIColor.lrTealishTwo
        label.textInsets = UIEdgeInsets(top: 3, left: 10, bottom: 3, right: 10)
        label.sizeToFit()
        label.layer.cornerRadius = label.frame.height * 0.5
        label.layer.masksToBounds = true
        return label
    }
}
