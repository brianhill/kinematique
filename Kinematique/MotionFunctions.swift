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

// Circular motion parameters
private let radius: CGFloat = 250.0
private let period: CFTimeInterval = 10

// Parabolic motion parameters
private let transitTime: CFTimeInterval = 8
private let transitWidth: CGFloat = 600
private let initialVerticalVelocity: CGFloat = 300
private let verticalDeceleration: CGFloat = 2 * initialVerticalVelocity / CGFloat(transitTime)
private let doOverTime: CFTimeInterval = 10
private let initialAltitude: CGFloat = 40

func circularMotionFunctionForFrameSize(frameSize: CGSize) -> MotionFunction {
    return { (timeInterval: CFTimeInterval) -> CGPoint? in
        let angle = CGFloat(2) * CGFloat(M_PI) * CGFloat(timeInterval) / CGFloat(period)
        let x = radius * cos(angle) + frameSize.width / 2
        let y = frameSize.height / 2 - radius * sin(angle)
        return CGPointMake(x, y)
    }
}

func parabolicMotionFunctionForFrameSize(frameSize: CGSize) -> MotionFunction {
    return { (timeInterval: CFTimeInterval) -> CGPoint? in
        let remainder = timeInterval % doOverTime
        if remainder < 0 || remainder > transitTime { return nil }
        let x: CGFloat = transitWidth * (CGFloat(remainder) / CGFloat(transitTime) - 1 / 2) + frameSize.width / 2
        let y: CGFloat = frameSize.height - initialVerticalVelocity * CGFloat(remainder) + verticalDeceleration * CGFloat(remainder) * CGFloat(remainder) / 2 - initialAltitude
        return CGPointMake(x, y)
    }
}
