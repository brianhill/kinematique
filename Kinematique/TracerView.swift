//
//  TracerView.swift
//  Kinematique
//
//  Created by Brian Hill on 5/5/16.
//  Copyright © 2016 Kinematique. All rights reserved.
//

import UIKit

private let _circleRadius: CGFloat = 10
private let _circleStrokeWidth: CGFloat = 1

import CoreGraphics

// Circular motion parameters
let radius: CGFloat = 250.0
let period: CFTimeInterval = 10

// Parabolic motion parameters
let transitTime: CFTimeInterval = 8
let transitWidth: CGFloat = 600
let initialVerticalVelocity: CGFloat = 300
let verticalDeceleration: CGFloat = 2 * initialVerticalVelocity / CGFloat(transitTime)
let doOverTime: CFTimeInterval = 10
let initialAltitude: CGFloat = 40

// Constants for drawing tracer points
private let _tracerPointFillColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0.5, 0.5, 0.5, 0.9])!
private let _tracerPointStrokeColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0.0, 0.0, 0.0, 1.0])!

// Colors for drawing points
private let _pointsFillColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0.0, 0.0, 0.0, 0.9])!
private let _pointsStrokeColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0.0, 0.0, 0.0, 1.0])!

let shadowDuration: CFTimeInterval = 0.5
let shadowQuantity: Int = 7

class TracerView: UIView {
    
    let userSelections = UserSelections.sharedInstance
    let dataModel = DataModel.sharedInstance
    
    // First we have code for drawing circles, used by both the tracer view and the positions view.
    
    private var _circleFillColor: CGColor? = nil
    private var _circleStrokeColor: CGColor? = nil
    
    func setCircleAttributes(circleFillColor circleFillColor: CGColor, circleStrokeColor: CGColor) {
        _circleFillColor = circleFillColor
        _circleStrokeColor = circleStrokeColor
    }
    
    func addCircle(atPoint point: CGPoint, alpha: CGFloat) {
        guard let circleFillColor = _circleFillColor else {return }
        guard let circleStrokeColor = _circleStrokeColor else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        CGContextSetFillColorWithColor(context, circleFillColor)
        CGContextSetStrokeColorWithColor(context, circleStrokeColor)
        CGContextSetLineWidth(context, _circleStrokeWidth)
        CGContextSetAlpha(context, alpha)
        
        CGContextBeginPath(context)
        let circleRect = CGRectMake(point.x - _circleRadius, point.y - _circleRadius, 2 * _circleRadius, 2 * _circleRadius)
        CGContextAddEllipseInRect(context, circleRect)
        CGContextDrawPath(context, .FillStroke)
    }
    
    func circularMotion(timeInterval: CFTimeInterval) -> CGPoint? {
        let angle = CGFloat(2) * CGFloat(M_PI) * CGFloat(timeInterval) / CGFloat(period)
        let x = radius * cos(angle) + frame.size.width / 2
        let y = frame.size.height / 2 - radius * sin(angle)
        return CGPointMake(x, y)
    }
    
    func parabolicMotion(timeInterval: CFTimeInterval) -> CGPoint? {
        let remainder = timeInterval % doOverTime
        if remainder < 0 || remainder > transitTime { return nil }
        let x: CGFloat = transitWidth * (CGFloat(remainder) / CGFloat(transitTime) - 1 / 2) + frame.size.width / 2
        let y: CGFloat = frame.size.height - initialVerticalVelocity * CGFloat(remainder) + verticalDeceleration * CGFloat(remainder) * CGFloat(remainder) / 2 - initialAltitude
        return CGPointMake(x, y)
    }
    
    override func drawRect(rect: CGRect) {
        
        // Add the tracer point and its shadows
        setCircleAttributes(circleFillColor: _tracerPointFillColor, circleStrokeColor: _tracerPointStrokeColor)
        for i in 0..<shadowQuantity {
            // Add the points as filled gray circles with a thin stroke
            let shadowFraction = CFTimeInterval(i) / CFTimeInterval(shadowQuantity)
            let shadowTime = shadowFraction * shadowDuration
            let shadowTimeInterval = userSelections.tracerTimeInterval - shadowTime
            let point = userSelections.showingParabolic ? parabolicMotion(shadowTimeInterval) : circularMotion(shadowTimeInterval)
            guard let knownPoint = point else { continue }
            addCircle(atPoint: knownPoint, alpha: CGFloat(1 - shadowFraction))
        }
        
        // Add the points
        setCircleAttributes(circleFillColor: _pointsFillColor, circleStrokeColor: _pointsStrokeColor)
        for idx in 0..<dataModel.points.count {
            let point = dataModel.points[idx]
            addCircle(atPoint: point, alpha: 1.0)
        }
        
    }
    
}
