//
//  SynchronizedDictionary.swift
//  Depo
//
//  Created by Alex on 2/27/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

//fileprivate protocol Value {
//  init(symbol: String, info: [String : AnyObject])
//}

public struct SynchronizedDictionary<K,V> where K: Hashable {
    
    private let queue = DispatchQueue(label: DispatchQueueLabels.syncronizedArray, attributes: .concurrent)
    private var dictionary = [K:V]()
    
//    init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key, Value)
    
    init() {
    }
    
    init(dictionary: [K:V]) {
        self.dictionary = dictionary
    }
    
    public func test2222() {
        debugPrint(dictionary)
    }
    
    subscript(key: K) -> V? {
        set {
            dictionary[key] = newValue
        }
        get {
           return dictionary[key]
        }
    }
    
//    func updateValue(_ value: Value, forKey key: Key) -> Value? {
//
//    }
//    func merge<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value)
//    mutating func merge(_ other: [Key : Value], uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows
//    func merging<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Key : Value] where S : Sequence, S.Element == (Key, Value)
//    func merging(_ other: [Key : Value], uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> [Key : Value]
    
    
    
//    public mutating func remove(at index: Dictionary<Key, Value>.Index) -> [Key : Value].Element
//     public mutating func removeValue(forKey key: Key) -> Value?
//    func removeAll(keepingCapacity keepCapacity: Bool = false)
    
    
    
//    init() {
//        dictionary
//    }
    
//    init<K,V>() {
//
//    }
    
    
    
}
