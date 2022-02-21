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
}

class PublicShareDownloader: NSObject {
    static var shared = PublicShareDownloader()

    private var urlSession: URLSession?
    private var task: URLSessionDownloadTask?
    private var fileName: String = ""
    weak var delegate: PublicShareDownloaderDelegate?

    override private init() {
        super.init()

        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
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
        if error != nil {
            if let error = error as NSError?, error.localizedDescription == "cancelled" {
                delegate?.publicShareDownloadCancelled()
                return
            }
            delegate?.publicShareDownloadCompleted(isSuccess: false, url: nil)
            task.cancel()
        }
    }
}


