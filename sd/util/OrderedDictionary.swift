//
//  OrderedDictionary.swift
//  sd
//
//  Created by Hai on 23/11/2018.
//  Copyright © 2018 AHOPE. All rights reserved.
//

import UIKit

struct OrderedDictionary<Tk: Hashable, Tv> {
    var keys: Array<Tk> = []
    private var _values: Dictionary<Tk,Tv> = [:]
    var values: Array<Tv> {
        get { return keys.compactMap { _values[$0] } }
    }
    
    var count: Int {
        assert(keys.count == _values.count, "Keys and values array out of sync")
        return self.keys.count;
    }
    
    // Explicitly define an empty initializer to prevent the default memberwise initializer from being generated
    init() {}
    
    subscript(index: Int) -> Tv? {
        get {
            let key = self.keys[index]
            return self._values[key]
        }
        set(newValue) {
            let key = self.keys[index]
            if (newValue != nil) {
                self._values[key] = newValue
            } else {
                self._values.removeValue(forKey: key)
                self.keys.remove(at: index)
            }
        }
    }
    
    subscript(key: Tk) -> Tv? {
        get {
            return self._values[key]
        }
        set(newValue) {
            if newValue == nil {
                self._values.removeValue(forKey: key)
                self.keys = self.keys.filter {$0 != key}
            } else {
                let oldValue = self._values.updateValue(newValue!, forKey: key)
                if oldValue == nil {
                    self.keys.append(key)
                }
            }
        }
    }
    
    var description: String {
        var result = "{\n"
        for i in 0..<self.count {
            result += "[\(i)]: \(self.keys[i]) => \(String(describing: self[i]))\n"
        }
        result += "}"
        return result
    }
}
