//
//  ConnectedDeviceViewController.swift
//  Lifebox
//
//  Created by Ozan Salman on 27.12.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit
import AVFoundation

final class ConnectedDeviceViewController: BaseViewController {
    
    var output: ConnectedDeviceViewOutput!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeView = UIView()
    var viewWidth = CGFloat()
    var viewHeight = CGFloat()
    
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = Image.iconInfo.image
        return view
    }()
    
    private lazy var infoLabel: UILabel = {
       let view = UILabel()
        view.text = localized(.scanQrCodeInfo)
        view.numberOfLines = 2
        view.font = .appFont(.medium, size: 14)
        view.textColor = AppColor.label.color
        view.textAlignment = .left
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWidth = view.frame.width
        viewHeight = view.frame.height
        
        setTitle(withString: localized(.scanQrCode))
        view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
        pageSetup()
        setupCamera()
    }
    
}

extension ConnectedDeviceViewController: ConnectedDeviceViewInput {
    func readQRCodeSuccess() {
        hideIndicator()
        self.navigationController?.popViewController(animated: true)
    }
    
    func readQRCodeFail() {
        hideIndicator()
        let popup = PopUpController.with(title: nil,
                                         message: localized(.qrCodeTryAgain),
                                         image: .error,
                                         buttonTitle: TextConstants.ok) { [weak self] vc in
                                         self?.startSession()
                                            vc.close()
                                         }
        popup.open()
    }
}

extension ConnectedDeviceViewController {
    private func pageSetup() {
        view.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).activate()
        iconImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).activate()
        iconImageView.widthAnchor.constraint(equalToConstant: 20).activate()
        iconImageView.heightAnchor.constraint(equalToConstant: 20).activate()
        
        view.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8).activate()
        infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8).activate()
        infoLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).activate()
    }
}

extension ConnectedDeviceViewController: AVCaptureMetadataOutputObjectsDelegate {
    func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 60, width: viewWidth, height: viewHeight - 150)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.backgroundColor = UIColor.black.withAlphaComponent(1).cgColor
        previewLayer.opacity = 0.7
        view.layer.addSublayer(previewLayer)
        
        qrCodeView = QrReadView(frame: CGRect(x: 100, y: 120, width: previewLayer.frame.width - 200, height: previewLayer.frame.width - 200)) as UIView
        qrCodeView.layer.opacity = 1
        qrCodeView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.addSubview(qrCodeView)
        
        startSession()
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            let transformedMetadataObject = previewLayer.transformedMetadataObject(for: metadataObject)
            let readFrame = transformedMetadataObject!.bounds
            
            if self.qrCodeView.frame.contains(CGRect(x: readFrame.minX, y: readFrame.minY + 40.0, width: readFrame.width, height: readFrame.height)) {
                successQRCodeForCamera(value: stringValue)
            }
        }
    }
    
    func successQRCodeForCamera(value: String) {
        captureSession.stopRunning()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        showIndicator()
        self.output.callReadQRCode(referenceToken: value)
    }
    
}
