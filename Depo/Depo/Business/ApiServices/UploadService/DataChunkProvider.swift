//
//  DataChunkProvider.swift
//  Depo
//
//  Created by Konstantin Studilin on 10/02/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation


typealias DataChunk = (data: Data, range: Range<Int>)


final class DataChunkProvider {
    
    static func createWithStream(url: URL, bufferCapacity: Int) -> DataChunkProvider? {
        let fileManager = FileManager.default
        
        let fileSize: Int
        do {
            fileSize = try fileManager.sizeOfInputFile(src: url)
        } catch {
            assertionFailure(error.description)
            return nil
        }
        
        guard fileSize < NumericConstants.fourGigabytes else {
            assertionFailure(TextConstants.syncFourGbVideo)
            return nil
        }
        
        guard let fileStream = InputStream(url: url) else {
            assertionFailure("Can't create InputStream")
            return nil
        }
            
        return DataChunkProvider(stream: fileStream, fileSize: fileSize, bufferCapacity: bufferCapacity)
    }
    
    
    private let bufferCapacity: Int
    
    private let fileStream: InputStream
    private var lastRange = 0..<0
    private (set) var fileSize: Int
    
    
    init(stream: InputStream, fileSize: Int, bufferCapacity: Int) {
        self.fileStream = stream
        self.fileSize = fileSize
        self.bufferCapacity = bufferCapacity
    }
    
    deinit {
        fileStream.close()
    }
    
    func nextChunk(skipping: Int) -> DataChunk? {
        guard streamIsAvailable() else {
            return nil
        }

        guard fileStream.hasBytesAvailable else {
            return nil
        }
        
        guard skipping < fileSize else {
            return nil
        }
        
        if skipping > 0 {
             skip(bytesToSkip: skipping)
        }
        
        return nextChunk()
    }
    
    private func skip(bytesToSkip: Int) {
        var currentCapacity = min(bytesToSkip, bufferCapacity)
        var bytesSkipped = 0
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: currentCapacity)
        defer {
            buffer.deallocate()
        }

        while currentCapacity > 0, fileStream.hasBytesAvailable {
            bytesSkipped += fileStream.read(buffer, maxLength: currentCapacity)
            currentCapacity = min(bytesToSkip - bytesSkipped, bufferCapacity)
        }
        
        lastRange = 0..<bytesToSkip
    }
    
    
    func nextChunk() -> DataChunk? {
        guard streamIsAvailable() else {
            return nil
        }

        guard fileStream.hasBytesAvailable else {
            return nil
        }
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferCapacity)
        defer {
            buffer.deallocate()
        }
        
        let chunkSize = fileStream.read(buffer, maxLength: bufferCapacity)
        
        guard chunkSize > 0 else {
            if chunkSize < 0 {
                assertionFailure("error while reading from stream")
            }
            return nil
        }
        
        lastRange = lastRange.upperBound..<(lastRange.upperBound + chunkSize)
        
        let data = Data(bytes: buffer, count: chunkSize)
//        let data = Data(bytesNoCopy: buffer, count: chunkSize, deallocator: .none)
        
        return DataChunk(data, lastRange)
    }
    
    private func streamIsAvailable() -> Bool {
        let result: Bool
        
        switch fileStream.streamStatus {
        case .notOpen:
            fileStream.open()
            result = true
        case .atEnd, .error:
            fileStream.close()
            result = false
        default:
            result = true
        }
        
        return result
    }
}

extension FileManager {
    func sizeOfInputFile(src: URL) throws -> Int {
        let fileSize = try attributesOfItem(atPath: src.path)
        return fileSize[.size] as? Int ?? 0
    }
}
