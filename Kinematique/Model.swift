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
        
    var tracerPoints: [CGPoint?] = Array<CGPoint?>(count: _shadowQuantity, repeatedValue:nil)
    
    func motionFunction() -> MotionFunction {
        return showingCircularMotion ? circularMotionFunction() : parabolicMotionFunction()
    }
    
    func scaleTracerPoint(frameSize: CGSize, tracerPoint: CGPoint) -> CGPoint {
        if showingCircularMotion {
            let smallerDimension = frameSize.height < frameSize.width ? frameSize.height : frameSize.width
            return CGPointMake(tracerPoint.x * smallerDimension, tracerPoint.y * smallerDimension)
        } else {
            return CGPointMake(tracerPoint.x * frameSize.width, tracerPoint.y * frameSize.height)
        }
    }
    
    func translateTracerPoint(frameSize: CGSize, scaledTracerPoint: CGPoint) -> CGPoint {
        return CGPointMake(scaledTracerPoint.x + frameSize.width / 2, frameSize.height / 2 - scaledTracerPoint.y)
    }
    
    func regenerateTracerPoints(frameSize: CGSize) {
        let currentMotionFunction = motionFunction()
        for i in 0..<_shadowQuantity {
            let shadowFraction = CFTimeInterval(i) / CFTimeInterval(_shadowQuantity)
            let shadowTime = shadowFraction * _shadowDuration
            let shadowTimeInterval = anmimationTiming.tracerTimeInterval - shadowTime
            let tracerPoint = currentMotionFunction(shadowTimeInterval)
            tracerPoints[i] = tracerPoint != nil ? translateTracerPoint(frameSize, scaledTracerPoint: scaleTracerPoint(frameSize, tracerPoint: tracerPoint!)) : nil
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

