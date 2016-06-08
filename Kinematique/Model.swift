//
//  Model.swift
//  Kinematique
//
//  Created by Brian Hill on 5/4/16.
//  Copyright © 2016 Kinematique. All rights reserved.
//

import CoreGraphics

// In principle, the difference between any two vectors can be shown.
// In actuality, `to` is always `from + 1`.
typealias Difference = (from: Int, to: Int)

// In actuality, `to` is always `middle + 1` and `middle` is always `from + 1`.
typealias SecondOrderDifference = (from: Int, middle: Int, to: Int)

private let _shadowDuration: CFTimeInterval = 0.5
let _shadowQuantity: Int = 7

class DataModel {
    
    static let sharedInstance = DataModel()
    
    var anmimationTiming = AnimationTiming.sharedInstance
    
    var origin: CGPoint?
    
    var initialTime: CFTimeInterval! = nil
    
    var points: [CGPoint] = []
    
    // Sanitized points can be nil! They are in 1:1 correspondence with points. Sometimes the
    // function in the tracer view legitimately returns nil.
    var sanitizedPoints: [CGPoint?] = []
    
    var times: [CFTimeInterval] = []
    
    var labels: [String] = []
    
    var allDifferences: [Difference] {
        guard points.count > 1 else { return [] }
        var differences: [Difference] = []
        for i in 0..<points.count - 1 {
            differences.append(Difference(from:i, to:i + 1))
        }
        return differences
    }
    
    var allSecondOrderDifferences: [SecondOrderDifference] {
        guard points.count > 2 else { return [] }
        var secondOrderDifferences: [SecondOrderDifference] = []
        for i in 0..<points.count - 2 {
            secondOrderDifferences.append(SecondOrderDifference(from:i, middle:i + 1, to:i + 2))
        }
        return secondOrderDifferences
    }
    
    var showingCircularMotion = true
    
    var motionFunction: MotionFunction! = nil
    
    var tracerPoints: [CGPoint?] = Array<CGPoint?>(count: _shadowQuantity, repeatedValue:nil)
    
    func regenerateTracerPoints() {
        guard let currentMotionFunction = motionFunction else {
            tracerPoints = Array<CGPoint?>(count: _shadowQuantity, repeatedValue:nil)
            return
        }
        for i in 0..<_shadowQuantity {
            let shadowFraction = CFTimeInterval(i) / CFTimeInterval(_shadowQuantity)
            let shadowTime = shadowFraction * _shadowDuration
            let shadowTimeInterval = anmimationTiming.tracerTimeInterval - shadowTime
            tracerPoints[i] = currentMotionFunction(shadowTimeInterval)
        }
    }
    
    let shadowFractions: [CFTimeInterval] = (0..<_shadowQuantity).map { CFTimeInterval($0) / CFTimeInterval(_shadowQuantity) }
    
}

class UserSelections {
    
    static let sharedInstance = UserSelections()
    
    var settingOrigin: Bool = true
    
    var selectedDifference: Difference? = nil
    
    var selectedSecondOrderDifference: SecondOrderDifference? = nil
    
    var showingVelocities: Bool = false
    
    var showingAccelerations: Bool = false
    
    var selectedDifferences: [Difference] {
        guard let difference = selectedDifference else { return [] }
        return [difference]
    }
    
    var selectedSecondOrderDifferences: [SecondOrderDifference] {
        guard let secondOrderDifference = selectedSecondOrderDifference else { return [] }
        return [secondOrderDifference]
    }
    
}

class AnimationTiming {

    static let sharedInstance = AnimationTiming()
    
    var tracerResetTime: CFAbsoluteTime! = nil
    var tracerTimeInterval: CFTimeInterval = 0

}

