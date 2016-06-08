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

// Constants for drawing tracer points
private let _tracerPointFillColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0.5, 0.5, 0.5, 0.9])!
private let _tracerPointStrokeColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0.0, 0.0, 0.0, 1.0])!

// Colors for drawing the user's tapped points
private let _pointsFillColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0.0, 0.0, 0.0, 0.9])!
private let _pointsStrokeColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [0.0, 0.0, 0.0, 1.0])!

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
    
    override func drawRect(rect: CGRect) {
        
        // Add the tracer point and its shadows
        setCircleAttributes(circleFillColor: _tracerPointFillColor, circleStrokeColor: _tracerPointStrokeColor)
        for idx in 0..<dataModel.tracerPoints.count {
            guard let tracerPoint = dataModel.tracerPoints[idx] else { continue }
            addCircle(atPoint: tracerPoint, alpha: CGFloat(1 - dataModel.shadowFractions[idx]))
        }
        
        // Add the points
        setCircleAttributes(circleFillColor: _pointsFillColor, circleStrokeColor: _pointsStrokeColor)
        for idx in 0..<dataModel.points.count {
            let point = dataModel.points[idx]
            addCircle(atPoint: point, alpha: 1.0)
        }
        
    }
    
}
