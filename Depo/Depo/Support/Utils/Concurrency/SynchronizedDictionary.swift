//
//  SynchronizedDictionary.swift
//  Depo
//
//  Created by Alex on 2/27/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import Foundation

/*
-----------Syncronised Dictionary------------
 */
func + <K, V>(left: SynchronizedDictionary<K, V>, right: SynchronizedDictionary<K, V>) -> SynchronizedDictionary<K, V> {
    let map = left.copy()
    for (k, v) in right {
        map[k] = v
    }
    return map
}

func + <K, V>(left: SynchronizedDictionary<K, V>, right: Dictionary<K, V>) -> SynchronizedDictionary<K, V> {
    let map = left.copy()
    for (k, v) in right {
        map[k] = v
    }
    return map
}

public final class SynchronizedDictionary<K,V> where K: Hashable {
    
    public typealias Element = (key: K, value: V)
    
    private var iteratorIndex: Dictionary<K, V>.Index?
    
    private let queue = DispatchQueue(label: DispatchQueueLabels.syncronizedArray, attributes: .concurrent)
    private var dictionary = [K:V]()

    init() {
        
    }
    
    init(dictionary: [K:V]) {
        self.dictionary = dictionary
        
        iteratorIndex = dictionary.startIndex
    }

    init<S>(uniqueKeysWithValues keysAndValues: S) where S : Sequence, S.Element == (K, V) {
        for (k, v) in keysAndValues {
            dictionary[k] = v
        }
    }
    
}

//MARK:- General
extension SynchronizedDictionary {
    
    subscript(key: K) -> V? {
        set {
            queue.async(flags: .barrier) {
                self.dictionary[key] = newValue
            }
        }
        get {
            queue.sync {
                return self.dictionary[key]
            }
        }
    }
    
    func merge(with dictionary: Dictionary<K, V>) {
        queue.async(flags: .barrier) {
            self.dictionary = self.dictionary + dictionary
        }
    }
    
}

//MARK:- Properties
extension SynchronizedDictionary {
    
    var keys: Dictionary<K, V>.Keys {
        queue.sync {
            return dictionary.keys
        }
    }
    
    var values: Dictionary<K, V>.Values {
        queue.sync {
            return dictionary.values
        }
    }
    
    var dictionaryCopy: Dictionary<K,V> {
        queue.sync {
            return dictionary
        }
    }
}

//MARK: - Iterator
extension SynchronizedDictionary: Sequence, IteratorProtocol {
    
    public func next() -> SynchronizedDictionary.Element? {
        if iteratorIndex == nil {
            iteratorIndex = dictionary.startIndex
        }
        
        guard let iteratorIndex = iteratorIndex,
            iteratorIndex < dictionary.endIndex else {
            return nil
        }
        defer {
            self.iteratorIndex = dictionary.index(after: iteratorIndex)
        }
        
        return dictionary[iteratorIndex]
    }

}

//MARK:- Copy protocol imitation
extension SynchronizedDictionary {
    func copy() -> SynchronizedDictionary<K,V> {
        queue.sync {
            let copy = SynchronizedDictionary<K,V>(dictionary: dictionary)
            return copy
        }
    }
}
