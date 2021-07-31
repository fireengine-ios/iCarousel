//
//  SilentPushApiService.swift
//  Depo
//
//  Created by Alper Kırdök on 30.06.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Alamofire
import XCGLogger

final class SilentPushApiService: BaseRequestService {

    //MARK: -Properties
    private var logData: Data?
    private var widgetLogData: Data?
    private let logPath = Device.documentsFolderUrl(withComponent: XCGLogger.lifeboxLogFileName)
    private let widgetLogUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedConstants.groupIdentifier)!
                                                                .appendingPathComponent("home_widget.log")

    func uploadLog() {
        var bgTask = UIBackgroundTaskIdentifier.invalid
        bgTask = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(bgTask)
        }

        let endTask = {
            if bgTask != .invalid {
                UIApplication.shared.endBackgroundTask(bgTask)
            }
        }

        MediaItemOperationsService.shared.logItemsForSyncCounts {
            self.performUploadLog {
                endTask()
            }
        }
    }

    private func performUploadLog(completion: @escaping () -> Void) {
        let parameters = createInfoParameters()
        logData = try? Data(contentsOf: logPath)
        widgetLogData = try? Data(contentsOf: widgetLogUrl)

        let formData: (MultipartFormData) -> Void = {
            if let logData = self.logData {
                $0.append(logData, withName: "files", fileName: "logs.txt", mimeType: "text/plain")
            }

            if let widgetLogData = self.widgetLogData {
                $0.append(widgetLogData, withName: "files", fileName: "widget_logs.txt", mimeType: "text/plain")
            }

            for (key, value) in parameters {
                $0.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }
        SessionManager
            .customDefault
            .upload(multipartFormData: formData, to: RouteRequests.feedbackLog) { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload
                        .customValidate()
                        .responseData { response in
                            completion()
                        }
                case .failure(let encodingError):
                    debugLog("Silent push is failed: \(encodingError)")
                    completion()
                }
            }
    }

    private func createInfoParameters() -> [String:String] {
        let appVersion = Device.deviceInfo["appVersion"] as? String
        let carrier = Device.carrier
        let model = Device.deviceInfo["name"] as? String
        let manufacturer = Device.manufacturer
        let device = Device.modelName
        let deviceOs = Device.systemVersion
        let language = Device.deviceInfo["language"] as? String
        let networkStatus = ReachabilityService.shared.connectionType

        var infoText = "Application Version: \(appVersion ?? "") \n"
        infoText.append("Carrier: \(carrier ?? "") \n")
        infoText.append("Model: \(model ?? "") \n")
        infoText.append("Manufacturer: \(manufacturer) \n")
        infoText.append("Device: \(device) \n")
        infoText.append("DeviceOs: \(deviceOs) \n")
        infoText.append("Language: \(language ?? "") \n")
        infoText.append("NetworkStatus: \(networkStatus) \n")
        return ["client_info": infoText]
    }
}
