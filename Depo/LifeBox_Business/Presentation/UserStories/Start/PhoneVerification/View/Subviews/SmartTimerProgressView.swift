//
//  SmartTimerProgressView.swift
//  Depo
//
//  Created by Anton Ignatovich on 04.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol SmartTimerProgressViewDelegate: class {
    func didPassedRequestedTimeInterval(_ vview: SmartTimerProgressView)
}

final class SmartTimerProgressView: UIView {

    weak var delegate: SmartTimerProgressViewDelegate?

    private lazy var lineProgressView: LineProgressView = {
        let lineProgressView = LineProgressView()
        lineProgressView.translatesAutoresizingMaskIntoConstraints = false
        lineProgressView.targetValue = 1
        lineProgressView.set(progress: 0)
        lineProgressView.set(lineBackgroundColor: ColorConstants.infoPageSeparator)
        lineProgressView.set(lineColor: ColorConstants.a2FAActiveProgress)
        lineProgressView.setContentCompressionResistancePriority(.required, for: .vertical)
        lineProgressView.lineWidth = 8
        return lineProgressView
    }()

    private lazy var smartTimerLabel: SmartTimerLabel = {
        let smartTimerLabel = SmartTimerLabel()
        smartTimerLabel.translatesAutoresizingMaskIntoConstraints = false
        smartTimerLabel.font = UIFont.GTAmericaStandardMediumFont(size: 16)
        smartTimerLabel.textColor = ColorConstants.accessListItemName
        smartTimerLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        smartTimerLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        smartTimerLabel.delegate = self
        return smartTimerLabel
    }()

    var isShowMessageWithDropTimer: Bool {
        get {
            return smartTimerLabel.isShowMessageWithDropTimer
        }

        set {
            smartTimerLabel.isShowMessageWithDropTimer = newValue
        }
    }

    var isDead: Bool {
        return smartTimerLabel.isDead
    }

    private var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        baseSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        baseSetup()
    }

    private func baseSetup() {
        backgroundColor = .clear
        addSubview(containerStackView)
        containerStackView.pinToSuperviewEdges()
        containerStackView.addArrangedSubview(lineProgressView)
        containerStackView.addArrangedSubview(smartTimerLabel)
        smartTimerLabel.widthAnchor.constraint(equalToConstant: 50).activate()
    }

    func setupProgressViewWithTimer(timerLimit lifetime: Int) {
        smartTimerLabel.setupTimer(timerLimit: lifetime)
        lineProgressView.resetProgress()
        lineProgressView.targetValue = CGFloat(lifetime)
    }

    func dropTimer() {
        smartTimerLabel.dropTimer()
        lineProgressView.targetValue = 1
        lineProgressView.set(progress: 1)
    }
}

// MARK: - SmartTimerLabelDelegate
extension SmartTimerProgressView: SmartTimerLabelDelegate {
    func timerDidTick(currentCycle: Int, ofTotalDuration: Int, label: SmartTimerLabel) {
        lineProgressView.set(progress: currentCycle)
    }

    func timerDidFinishRunning() {
        delegate?.didPassedRequestedTimeInterval(self)
    }
}
