//
//  Logger.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 4/14/25.
//

import os
import Metal

extension Logger {
    
    //TODO: Update to use OSLogMessage
    func logIf(_ condition: Bool, message: String) {
        if condition {
            self.log("\(message)")
        }
    }
    
    func logBufferContents<T>(_ buffer: MTLBuffer, type: T.Type, size: Int) {
        let pointer = buffer.contents().assumingMemoryBound(to: T.self)
        var string = "["
        for i in 0..<size {
            string += "\(pointer.advanced(by: i).pointee) "
        }
        string += "]"
        self.log("\(string)")
    }
}
