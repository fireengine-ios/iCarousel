//
//  StreamReaderWriter.swift
//  Depo
//
//  Created by Andrei Novikau on 05/04/2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

final class StreamReaderWriter {
    
    typealias ProgressCallBack = (_ copySize: Double, _ percent: Double) -> Void
    typealias CompleteCallBack = (_ success: Bool) -> Void
    
    static func copyFile(fromURL: URL, toURL: URL, progress: ProgressCallBack? = nil, completion: CompleteCallBack) {
        guard let copyOutput = OutputStream(url: toURL, append: false),
            let fileInput = InputStream(url: fromURL),
            let fileSize = StreamReaderWriter.sizeOfInputFile(src: fromURL),
            let freeSpace = Device.getFreeDiskSpaceInBytes() else {
                completion(false)
                return
        }
        
        guard fileSize < NumericConstants.fourGigabytes else {
            UIApplication.showErrorAlert(message: TextConstants.syncFourGbVideo)
            completion(false)
            return
        }
        
        guard fileSize < freeSpace else {
            UIApplication.showErrorAlert(message: TextConstants.syncNotEnoughMemory)
            completion(false)
            return
        }
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: NumericConstants.copyVideoBufferSize)
        var bytesToWrite = 0
        var bytesWritten = 0
        var counter = 0
        var copySize = 0
        
        fileInput.open()
        copyOutput.open()
        
        while fileInput.hasBytesAvailable {
            repeat {
                bytesToWrite = fileInput.read(buffer, maxLength: NumericConstants.copyVideoBufferSize)
                bytesWritten = copyOutput.write(buffer, maxLength: NumericConstants.copyVideoBufferSize)
                
                if bytesToWrite < 0 {
                    print(fileInput.streamStatus.rawValue)
                }
                if bytesWritten == -1 {
                    print(copyOutput.streamStatus.rawValue)
                }
                //move read pointer to next section
                bytesToWrite -= bytesWritten
                copySize += bytesWritten
                
                if bytesToWrite > 0 {
                    //move block of memory
                    memmove(buffer, buffer + bytesWritten, bytesToWrite)
                }
                
            } while bytesToWrite > 0
            
            counter += 1
            if counter % 10 == 0 {
                let percent = Double(copySize * 100/fileSize)
                progress?(Double(copySize), percent)
            }
        }
        
        completion(true)
        
        //close streams
        if fileInput.streamStatus == .atEnd {
            fileInput.close()
        }
        if copyOutput.streamStatus != .writing && copyOutput.streamStatus != .error {
            copyOutput.close()
        }
    }
    
    private static func sizeOfInputFile(src: URL) -> Int? {
        do {
            let fileSize = try FileManager.default.attributesOfItem(atPath: src.path)
            return fileSize[FileAttributeKey.size] as? Int
        } catch  {
           
        }
        return nil
    }
}
