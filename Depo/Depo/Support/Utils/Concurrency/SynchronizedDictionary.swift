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


func + <K, V>(left: SynchronizedDictionary<K, V>, right: SynchronizedDictionary<K, V>) -> SynchronizedDictionary<K, V> {
    var map = left.dictionaryCopy
    for (k, v) in right {
        map[k] = v
    }
    return SynchronizedDictionary<K,V>(dictionary: map)
}

func + <K, V>(left: SynchronizedDictionary<K, V>, right: Dictionary<K, V>) -> SynchronizedDictionary<K, V> {
    var map = left.dictionaryCopy
    for (k, v) in right {
        map[k] = v
    }
    return SynchronizedDictionary<K,V>(dictionary: map)
}

public final class SynchronizedDictionary<K,V> where K: Hashable {
    
    public typealias Element = (key: K, value: V)
    
    private let queue = DispatchQueue(label: DispatchQueueLabels.syncronizedArray, attributes: .concurrent)
    /*private*/ var dictionary = [K:V]()
    
    private var iteratorIndex: Dictionary<K, V>.Index?
    
//    init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (Key, Value)
    
    init() {
        iteratorIndex = dictionary.startIndex
    }
    
    init(dictionary: [K:V]) {
        self.dictionary = dictionary
        
        iteratorIndex = dictionary.startIndex
    }

    subscript(key: K) -> V? {
        set {
//            queue.async(flags: .barrier) {
                self.dictionary[key] = newValue
//            }
        }
        get {
//            queue.sync {
                return self.dictionary[key]
//            }
        }
    }
    
    var keys: Dictionary<K, V>.Keys {
        return dictionary.keys
    }
    
    var value: Dictionary<K, V>.Values {
        return dictionary.values
    }
    
    func merge(with dictionary: Dictionary<K, V>) {
        self.dictionary = self.dictionary + dictionary
    }
    
    var dictionaryCopy: Dictionary<K,V> {
        return dictionary
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

extension SynchronizedDictionary: Sequence, IteratorProtocol {
    
    
//           if count == 0 {
//               return nil
//           } else {
//               defer { count -= 1 }
//               return count
//           }
    public func next() -> SynchronizedDictionary.Element? {
        guard let iteratorIndex = iteratorIndex,
            iteratorIndex < dictionary.endIndex else {
            return nil
        }
        defer {
            self.iteratorIndex = dictionary.index(after: iteratorIndex)
            
//            lastCalledElement =  dictionary.keys[]
        }
        
        return dictionary[iteratorIndex]
    }

}

//struct SynchronizedDictionaryIterator: IteratorProtocol {
//    mutating func next() -> SynchronizedDictionaryIterator? {
//        <#code#>
//    }
//
//    typealias Element = SynchronizedDictionaryIterator//<K:V> where K : Hashable
//
//
//}

//extension SynchronizedDictionary: Sequence {
//    /// Returns an iterator over the dictionary's key-value pairs.
//    ///
//    /// Iterating over a dictionary yields the key-value pairs as two-element
//    /// tuples. You can decompose the tuple in a `for`-`in` loop, which calls
//    /// `makeIterator()` behind the scenes, or when calling the iterator's
//    /// `next()` method directly.
//    ///
//    ///     let hues = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
//    ///     for (name, hueValue) in hues {
//    ///         print("The hue of \(name) is \(hueValue).")
//    ///     }
//    ///     // Prints "The hue of Heliotrope is 296."
//    ///     // Prints "The hue of Coral is 16."
//    ///     // Prints "The hue of Aquamarine is 156."
//    ///
//    /// - Returns: An iterator over the dictionary with elements of type
//    ///   `(key: Key, value: Value)`.
////    @inlinable public func makeIterator() -> Dictionary<Key, Value>.Iterator
//    func makeIterator() -> SynchronizedDictionary<K, V>.Iterator {
//
//    }
//}

//<K,V>
