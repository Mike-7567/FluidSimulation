//
//  Controller.swift
//  FluidSimulation
//
//  Created by Gabriel Thomson on 2/16/25.
//

import Foundation
import GameController

@MainActor
class Controller {
    private(set) var viewMatrix: simd_float4x4 = .identity
    var cameraPos: simd_float3
    var cameraVel: simd_float3 = .zero
    var cameraRot: simd_float3
    
    init(cameraPos: simd_float3 = .zero, cameraRot: simd_float3 = .zero) {
        self.cameraPos = cameraPos
        self.cameraRot = cameraRot
        
        self.cameraPos.z = 15
        
        setupNotifications()
    }
    
    func updateViewMatrix() {
        viewMatrix = .identity
        cameraPos += cameraVel
        
        //cameraRot.x = 1.2
        //cameraRot.z = .pi / 4
        
        viewMatrix.translate(direction: -cameraPos)
        viewMatrix.rotate(angle: -cameraRot.x, axis: .xAxis)
        viewMatrix.rotate(angle: -cameraRot.y, axis: .yAxis)
        viewMatrix.rotate(angle: -cameraRot.z, axis: .zAxis)
    }
    
    func setupNotifications() {
        let center = NotificationCenter.default
        
        //TODO: use swiftui instead
        //center.addObserver(forName: .GCKeyboardDidConnect, object: nil, queue: .main) { n in
        //    let keyBoard = n.object as! GCKeyboard
        //
        //    keyBoard.keyboardInput?.keyChangedHandler = { keyboard, key, keyCode, pressed in
        //        MainActor.assumeIsolated {
        //            if pressed {
        //                switch keyCode {
        //                case .keyA:
        //                    self.cameraVel.x = -0.1
        //                case .keyD:
        //                    self.cameraVel.x = 0.1
        //                case .keyW:
        //                    self.cameraVel.z = -0.1
        //                case .keyS:
        //                    self.cameraVel.z = 0.1
        //                case .spacebar:
        //                    self.cameraVel.y = 0.1
        //                case .leftShift:
        //                    self.cameraVel.y = -0.1
        //                case .F2:
        //                    Simulation.main.resetParticlePositions()
        //                case .F4:
        //                    Simulation.main.printParticle()
        //                case .F1:
        //                    if Simulation.main.simSettings.simState == SimState.pause {
        //                        Simulation.main.simSettings.simState = SimState.step
        //                    }
        //                default:
        //                    print("Unhandled key: \(keyCode)")
        //                }
        //            } else {
        //                switch keyCode {
        //                case .keyA:
        //                    self.cameraVel.x = 0
        //                case .keyD:
        //                    self.cameraVel.x = 0
        //                case .keyW:
        //                    self.cameraVel.z = 0
        //                case .keyS:
        //                    self.cameraVel.z = 0
        //                case .spacebar:
        //                    self.cameraVel.y = 0
        //                case .leftShift:
        //                    self.cameraVel.y = 0
        //                default:
        //                    return
        //                }
        //            }
        //        }
        //    }
        //}
    }
}
