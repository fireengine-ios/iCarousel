//
//  PublicShareDownloadManager.swift
//  Lifebox
//
//  Created by Burak Donat on 10.02.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

protocol PublicShareDownloaderDelegate: AnyObject {
    func publicShareDownloadCompleted(isSuccess: Bool, url: URL?)
    func publicShareDownloadContinue(downloadedByte: String)
    func publicShareDownloadCancelled()
    func publicShareDownloadNotEnoughSpace()
}

class PublicShareDownloader: NSObject {
    static var shared = PublicShareDownloader()

    private var urlSession: URLSession?
    private var task: URLSessionDownloadTask?
    private var fileName: String = ""
    private let reachabilityService = ReachabilityService.shared
    private var isReachable = true
    weak var delegate: PublicShareDownloaderDelegate?

    override private init() {
        super.init()

        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        reachabilityService.delegates.add(self)
    }

    func startDownload(url: URL, fileName: String) {
        self.fileName = fileName
        task = urlSession?.downloadTask(with: url)
        task?.resume()
    }

    func stopDownload() {
        task?.cancel()
    }
}

extension PublicShareDownloader: URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let downloadedByte = ByteCountFormatter.string(fromByteCount: totalBytesWritten, countStyle: .file)
        delegate?.publicShareDownloadContinue(downloadedByte: downloadedByte)
    }
    
    func urlSession(_: URLSession, downloadTask _: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let destinationURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }
        let url = destinationURL.appendingPathComponent("\(fileName)", isDirectory: false)
        
        FileManager.secureCopyItem(at: location, to: url) { isSuccess in
            delegate?.publicShareDownloadCompleted(isSuccess: isSuccess, url: url)
        }
    }

    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard error == nil else {
            if let nsError = error as NSError? {
                if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                    isReachable == false ? delegate?.publicShareDownloadCompleted(isSuccess: false, url: nil) : delegate?.publicShareDownloadCancelled()
                    return
                } else if (nsError.domain == NSPOSIXErrorDomain && nsError.code == POSIXErrorCode.ENOSPC.rawValue) {
                    delegate?.publicShareDownloadNotEnoughSpace()
                    return
                }
            }
            
            delegate?.publicShareDownloadCompleted(isSuccess: false, url: nil)
            return
        }
        
        if let httpResponse = task.response as? HTTPURLResponse {
            if !(200...299).contains(httpResponse.statusCode) {
                delegate?.publicShareDownloadCompleted(isSuccess: false, url: nil)
            }
        }
    }
}

extension PublicShareDownloader: ReachabilityServiceDelegate {
    func reachabilityDidChanged(_ service: ReachabilityService) {
        if !service.isReachableViaWWAN && !service.isReachableViaWiFi {
            isReachable = false
            task?.cancel()
        } else {
            isReachable = true
        }
    }
}
