//
//  KeyedDecodingContainer.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 4/18/25.
//

extension KeyedDecodingContainer {
    func uint8FromBool(_ key: KeyedDecodingContainer<K>.Key) throws -> UInt8 {
        try self.decode(Bool.self, forKey: key) ? 1 : 0
    }
}
