//
//  StreamReaderWriter.swift
//  Depo
//
//  Created by Andrei Novikau on 05/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

/// https://gist.github.com/mingsai/dddce65c98753ace216c
final class StreamReaderWriter {
    
    typealias ProgressCallBack = (_ copySize: Double, _ percent: Double) -> Void
    
    func copyFile(from fromURL: URL, to toURL: URL, progress: ProgressCallBack? = nil, completion: @escaping ResponseVoid) {
        guard
            let copyOutput = OutputStream(url: toURL, append: false),
            let fileInput = InputStream(url: fromURL)
        else {
            completion(ResponseResult.failed(CustomErrors.unknown))
            return
        }
        
        let freeSpace = Device.getFreeDiskSpaceInBytes()
        
        let fileSize: Int
        do {
            fileSize = try sizeOfInputFile(src: fromURL)
        } catch {
            return completion(ResponseResult.failed(error))
        }

        guard fileSize < NumericConstants.fourGigabytes else {
            completion(ResponseResult.failed(CustomErrors.text(TextConstants.syncFourGbVideo)))
            return
        }
        
        guard fileSize < freeSpace else {
            completion(ResponseResult.failed(CustomErrors.text(TextConstants.syncNotEnoughMemory)))
            return
        }
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: NumericConstants.copyVideoBufferSize)
        var bytesToWrite = 0
        var bytesWritten = 0
        var counter = 0
        var copySize: Int64 = 0
        
        fileInput.open()
        copyOutput.open()
        
        while fileInput.hasBytesAvailable {
            repeat {
                bytesToWrite = fileInput.read(buffer, maxLength: NumericConstants.copyVideoBufferSize)
                bytesWritten = copyOutput.write(buffer, maxLength: NumericConstants.copyVideoBufferSize)
                
                if bytesToWrite < 0 {
                    debugPrint("bytesToWrite", fileInput.streamStatus.rawValue)
                }
                //move read pointer to next section
                bytesToWrite -= bytesWritten
                copySize += Int64(bytesWritten)
                
                if bytesToWrite > 0 {
                    //move block of memory
                    memmove(buffer, buffer + bytesWritten, bytesToWrite)
                }
                
            } while bytesToWrite > 0
            
            counter += 1
            if counter.remainderReportingOverflow(dividingBy: 10).partialValue == 0, fileSize != 0 {
                let percent = Double(copySize) * Double(100/fileSize)
                progress?(Double(copySize), percent)
            }
        }
        
        completion(ResponseResult.success(()))
        
        //close streams
        if fileInput.streamStatus == .atEnd {
            fileInput.close()
        }
        if copyOutput.streamStatus != .writing && copyOutput.streamStatus != .error {
            copyOutput.close()
        }
    }
    
    private func sizeOfInputFile(src: URL) throws -> Int {
        let fileSize = try FileManager.default.attributesOfItem(atPath: src.path)
        return fileSize[.size] as? Int ?? 0
    }
}
