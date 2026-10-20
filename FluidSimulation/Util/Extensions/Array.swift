//
//  Parallel.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 3/6/25.
//
import Foundation

extension Array {
    func count() -> UInt32 {
        return UInt32(self.count)
    }
    
    subscript(index: UInt32) -> Element {
        get {
            return self[Int(index)]
        }
        set {
            self[Int(index)] = newValue
        }
    }
    
    mutating func unsafeParallelForEach(_ body: @Sendable (inout Element, Int) -> Void) {
        var a = self
        a.withUnsafeMutableBufferPointer { ptr in
            DispatchQueue.concurrentPerform(iterations: self.count) { i in
                body(&ptr[i], i)
            }
        }
        self = a
    }
}
