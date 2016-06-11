//
//  MotionFunctions.swift
//  Kinematique
//
//  Created by Brian Hill on 6/7/16.
//  Copyright © 2016 Kinematique. All rights reserved.
//

import Foundation

import CoreGraphics

typealias MotionFunction = (CFTimeInterval) -> CGPoint?

// Motion parameters
private let period: CFTimeInterval = 10

// Circular motion parameters
private let radius: CGFloat = 0.375

// Parabolic motion parameters
private let transitTime: CFTimeInterval = 8
private let transitWidth: CGFloat = 0.75
private let initialVerticalVelocity: CGFloat = 0.375
private let verticalDeceleration: CGFloat = 2 * initialVerticalVelocity / CGFloat(transitTime)
private let initialAltitude: CGFloat = 0.05

func circularMotionFunction() -> MotionFunction {
    return { (timeInterval: CFTimeInterval) -> CGPoint? in
        let angle = CGFloat(2) * CGFloat(M_PI) * CGFloat(timeInterval) / CGFloat(period)
        let x = radius * cos(angle)
        let y = radius * sin(angle)
        return CGPointMake(x, y)
    }
}

func parabolicMotionFunction() -> MotionFunction {
    return { (timeInterval: CFTimeInterval) -> CGPoint? in
        let remainder = timeInterval % period
        if remainder < 0 || remainder > transitTime { return nil }
        let x: CGFloat = transitWidth * (CGFloat(remainder) / CGFloat(transitTime) - 0.5)
        let y: CGFloat = initialVerticalVelocity * CGFloat(remainder) - verticalDeceleration * CGFloat(remainder) * CGFloat(remainder) / 2 + initialAltitude - 0.5
        return CGPointMake(x, y)
    }
}
