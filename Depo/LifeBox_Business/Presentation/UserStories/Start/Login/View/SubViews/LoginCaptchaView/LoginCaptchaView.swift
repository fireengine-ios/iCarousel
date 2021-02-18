//
//  LoginCaptchaView.swift
//  Depo
//
//  Created by Anton Ignatovich on 15.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class LoginCaptchaView: UIView, FromNib {

    @IBOutlet private weak var noErrorTextfieldToBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var withErrorLabelToBottomconstraint: NSLayoutConstraint!

    @IBOutlet private weak var captchaImageView: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFit
        }
    }

    @IBOutlet private weak var soundCaptchaButton: UIButton! {
        willSet {
            newValue.isExclusiveTouch = true
            newValue.isOpaque = true
            newValue.imageView?.contentMode = .scaleToFill
        }
    }

    @IBOutlet private weak var refreshCaptchaButton: UIButton! {
        willSet {
            newValue.isExclusiveTouch = true
            newValue.isOpaque = true
            newValue.imageView?.contentMode = .scaleToFill
        }
    }

    @IBOutlet private(set) weak var captchaAnswerTextField: BorderedWithInsetsTextField! {
        willSet {
            newValue.returnKeyType = .done
            newValue.autocorrectionType = .no
            newValue.autocapitalizationType = .none
            newValue.spellCheckingType = .no
            newValue.enablesReturnKeyAutomatically = true
            newValue.smartQuotesType = .no
            newValue.smartDashesType = .no
            newValue.attributedPlaceholder = NSAttributedString(string: TextConstants.captchaViewTextfieldPlaceholder,
                                                                attributes: [NSAttributedStringKey.foregroundColor: ColorConstants.loginTextfieldPlaceholderColor])
            newValue.textColor = ColorConstants.loginTextfieldTextColor
        }
    }

    @IBOutlet private weak var captchaErrorLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.loginErrorLabelTextColor
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 12)
            newValue.textAlignment = .left
        }
    }

    @IBAction private func onRefreshCaptchaButton(_ sender: UIButton) {
        updateCaptcha()
    }

    @IBAction private func onSoundCaptchaButton(_ sender: UIButton) {
        getAudioCaptcha()
        clearCaptchaAnswer()
    }

    private lazy var analyticsService: AnalyticsService = factory.resolve()

    var currentCaptchaUUID = ""

    private let captchaService = CaptchaService()
    private var player: AVAudioPlayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        setupFromNib()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        getImageCaptcha()
    }

    func updateCaptcha() {
        clearCaptchaAnswer()
        getImageCaptcha()
    }

    func clearCaptchaAnswer() {
        captchaAnswerTextField.text = ""
    }

    func showError(_ error: String?) {
        guard let error = error else {
            noErrorTextfieldToBottomConstraint.priority = .defaultHigh
            withErrorLabelToBottomconstraint.priority = .defaultLow
            captchaErrorLabel.isHidden = true
            return
        }
        noErrorTextfieldToBottomConstraint.priority = .defaultLow
        withErrorLabelToBottomconstraint.priority = .defaultHigh
        captchaErrorLabel.isHidden = false
        captchaErrorLabel.text = error
    }

    private func generateCaptchaUUID() {
        currentCaptchaUUID = UUID().uuidString
    }

    private func getImageCaptcha() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .captcha,
                                            eventLabel: .captcha(.changeClick))

        generateCaptchaUUID()

        captchaService.getCaptcha(uuid: currentCaptchaUUID, type: .image, sucess: { [weak self] response in
            if let captchaResponse = response as? CaptchaResponse,
                let _ = captchaResponse.type,
                let captchaData = captchaResponse.data,
                let captchaImage = UIImage(data: captchaData) {
                /// image size (240.0, 60.0)
                DispatchQueue.main.async { [weak self] in
                    self?.captchaImageView.image = captchaImage
                }
            }

            }, fail: { [weak self] error in
                /// When you open the LoginViewController, another request is made to the server, which will already show 503 error
                let topController = UIApplication.topController()
                if !((topController is LoginViewController) || (topController is RegistrationViewController)) {
                    if !error.isServerUnderMaintenance {
                        DispatchQueue.main.async {
                            UIApplication.showErrorAlert(message: error.description)
                        }
                    }
                }
        })
    }

    private func getAudioCaptcha() {
        analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                            eventActions: .captcha,
                                            eventLabel: .captcha(.voiceClick))

        generateCaptchaUUID()

        captchaService.getCaptcha(uuid: currentCaptchaUUID, type: .audio, sucess: { [weak self] response in
            if let captchaResponse = response as? CaptchaResponse,
                let _ = captchaResponse.type,
                let captchaData = captchaResponse.data {
                DispatchQueue.main.async {
                    self?.playCaptchaAudio(from: captchaData)
                }
            }
            }, fail: { [weak self] error in
                 let topController = UIApplication.topController()
                if !((topController is LoginViewController) || (topController is RegistrationViewController)) {
                    DispatchQueue.main.async {
                        UIApplication.showErrorAlert(message: error.description)
                    }
                }
        })
    }

    private func playCaptchaAudio(from data: Data) {
        player?.stop()
        player = try? AVAudioPlayer(data: data)
        player?.prepareToPlay()
        player?.play()
    }
}
