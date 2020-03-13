//
//  DataChunkProvider.swift
//  Depo
//
//  Created by Konstantin Studilin on 10/02/2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation


typealias DataChunk = (data: Data, range: Range<Int>)


final class DataChunkProviderFactory {
    static func createWithSource(source: URL, bufferCapacity: Int) -> DataChunkProvider? {
        let fileManager = FileManager.default

        let fileSize: Int
        do {
            fileSize = try fileManager.sizeOfInputFile(src: source)
        } catch let error {
            #if MAIN_APP
            debugLog("chunker: can't get file size. \(error.description)")
            #endif
            assertionFailure("chunker: can't get file size.")
            return nil
        }
        

        guard fileSize < NumericConstants.fourGigabytes else {
            assertionFailure(TextConstants.syncFourGbVideo)
            return nil
        }

        guard let fileStream = InputStream(url: source) else {
            let message = "chunker: Can't create InputStream"
            #if MAIN_APP
            debugLog(message)
            #endif
            assertionFailure(message)
            return nil
        }

        return DataChunkProviderStream(stream: fileStream, fileSize: fileSize, bufferCapacity: bufferCapacity)
    }
    
    
    static func createWithSource(source: Data, bufferCapacity: Int) -> DataChunkProvider? {
        guard source.count < NumericConstants.fourGigabytes else {
            assertionFailure(TextConstants.syncFourGbVideo)
            return nil
        }
        
        return DataChunkProviderData(data: source, bufferCapacity: bufferCapacity)
    }
    
    private init() {}
}

protocol DataChunkProvider {
    var lastRange: Range<Int> { get }
    var fileSize: Int { get }
    
    func nextChunk() -> DataChunk?
    func nextChunk(skipping: Int) -> DataChunk?
}


private final class DataChunkProviderStream: DataChunkProvider {
    private let bufferCapacity: Int
    
    private let fileStream: InputStream
    private (set) var lastRange = 0..<0
    private (set) var fileSize: Int
    
    
    fileprivate init(stream: InputStream, fileSize: Int, bufferCapacity: Int) {
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
            #if MAIN_APP
            debugLog("chunker: streamIsAvailable == false")
            #endif
            return nil
        }

        guard fileStream.hasBytesAvailable else {
            #if MAIN_APP
            debugLog("chunker: hasBytesAvailable == false")
            #endif
            return nil
        }
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferCapacity)
        defer {
            buffer.deallocate()
        }
        
        let chunkSize = fileStream.read(buffer, maxLength: bufferCapacity)
        
        guard chunkSize > 0 else {
            if chunkSize < 0 {
                let message = "chunker: error while reading from stream"
                #if MAIN_APP
                debugLog(message)
                #endif
                assertionFailure(message)
            }
            return nil
        }
        
        lastRange = lastRange.upperBound..<(lastRange.upperBound + chunkSize)
        
        let data = Data(bytes: buffer, count: chunkSize)
        
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

private final class DataChunkProviderData: DataChunkProvider {
    private var data: Data
    private let bufferCapacity: Int
    
    private (set) var lastRange = 0..<0
    private (set) var fileSize: Int
    

    fileprivate init(data: Data, bufferCapacity: Int) {
        self.data = data
        self.fileSize = data.count
        self.bufferCapacity = bufferCapacity
    }

    func nextChunk(skipping: Int) -> DataChunk? {
        let bytesLeft = data.count - skipping
        
        guard bytesLeft > 0 else {
            return nil
        }
        
        data = data.suffix(bytesLeft)
        lastRange = 0..<skipping
        
        return nextChunk()
    }
    
    func nextChunk() -> DataChunk? {
        guard data.count > 0 else {
            return nil
        }
        
        let chunkData = data.prefix(bufferCapacity)
        let chunkSize = chunkData.count
        let bytesLeft = data.count - chunkSize
        
        data = data.suffix(bytesLeft)
        lastRange = lastRange.upperBound..<(lastRange.upperBound + chunkSize)
        
        return DataChunk(chunkData, lastRange)
    }
}


extension FileManager {
    func sizeOfInputFile(src: URL) throws -> Int {
        let fileSize = try attributesOfItem(atPath: src.path)
        return fileSize[.size] as? Int ?? 0
    }
}
