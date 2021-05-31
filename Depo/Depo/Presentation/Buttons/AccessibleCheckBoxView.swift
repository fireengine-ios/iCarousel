//
//  AccessibleCheckBoxView.swift
//  Depo
//
//  Created by Hady on 5/28/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

/// A container view for a label & checkbox button that is accessible
class AccessibleCheckBoxView: UIStackView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    private var textObservation: NSKeyValueObservation?

    override func awakeFromNib() {
        super.awakeFromNib()

        isAccessibilityElement = true
        updateTraits()

        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        textObservation = label.observe(\.text) { [weak self] label, _ in
            self?.accessibilityLabel = label.text
        }
    }

    @objc private func buttonTapped() {
        updateTraits()
    }

    override func accessibilityActivate() -> Bool {
        button.sendActions(for: .touchUpInside)
        return true
    }

    private func updateTraits() {
        var traits = UIAccessibilityTraitButton
        if button.isSelected {
            traits |= UIAccessibilityTraitSelected
        }

        accessibilityTraits = traits
    }
}
