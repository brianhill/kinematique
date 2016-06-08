//
//  TracerViewController.swift
//  Kinematique
//
//  Created by Brian Hill on 6/7/16.
//  Copyright © 2016 Kinematique. All rights reserved.
//

import UIKit

class TracerViewController: UIViewController {
    
    @IBOutlet weak var tracerView: TracerView!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var circularButton: UIBarButtonItem!
    @IBOutlet weak var parabolicButton: UIBarButtonItem!

    var displayLink: CADisplayLink! = nil
    
    let userSelections = UserSelections.sharedInstance
    let dataModel = DataModel.sharedInstance
    let animationTiming = AnimationTiming.sharedInstance
    
    private func _clear() {
        animationTiming.tracerResetTime = CFAbsoluteTimeGetCurrent()
        animationTiming.tracerTimeInterval = 0
        dataModel.points.removeAll()
        dataModel.initialTime = nil
        dataModel.times.removeAll()
        dataModel.labels.removeAll()
        userSelections.selectedDifference = nil
        userSelections.selectedSecondOrderDifference = nil
        userSelections.showingVelocities = false
        userSelections.showingAccelerations = false
        tracerView.setNeedsDisplay()
        nextButton.enabled = false
    }
    
    @IBAction func circular(sender: UIBarButtonItem) {
        dataModel.showingCircularMotion = true
        dataModel.motionFunction = circularMotionFunctionForFrameSize(tracerView.frame.size)
        circularButton.style = .Done
        parabolicButton.style = .Plain
        _clear()
    }
    
    @IBAction func parabolic(sender: UIBarButtonItem) {
        dataModel.showingCircularMotion = false
        dataModel.motionFunction = parabolicMotionFunctionForFrameSize(tracerView.frame.size)
        circularButton.style = .Plain
        parabolicButton.style = .Done
        _clear()
    }
    
    @IBAction func clear(sender: UIBarButtonItem) {
        _clear()
    }
    
    func addPoint(point: CGPoint) {
        let now = CFAbsoluteTimeGetCurrent()
        if dataModel.points.count == 0 {
            dataModel.initialTime = now
        }
        dataModel.points.append(point)
        dataModel.times.append(now - dataModel.initialTime)
        let sanitizedPoint = dataModel.motionFunction(now)
        dataModel.sanitizedPoints.append(sanitizedPoint)
        
        dataModel.labels.append(String(dataModel.points.count))
    }
    
    @IBAction func viewTapped(sender: UITapGestureRecognizer) {
        let tapPoint: CGPoint = sender.locationOfTouch(0, inView: tracerView)
        addPoint(tapPoint)
        tracerView.setNeedsDisplay()
        // Once the user has made three points, they can hit next
        if dataModel.points.count == 3 {
            nextButton.enabled = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        displayLink = CADisplayLink(target:self, selector:#selector(prepareForVSync(_:)))
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode:NSRunLoopCommonModes)
        displayLink.paused = true
        nextButton.enabled = false
        circularButton.style = .Done
        parabolicButton.style = .Plain

    }
    
    override func viewDidLayoutSubviews() {
        let frameSize = tracerView.frame.size
        dataModel.motionFunction = dataModel.showingCircularMotion ? circularMotionFunctionForFrameSize(frameSize) : parabolicMotionFunctionForFrameSize(frameSize)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        animationTiming.tracerResetTime = CFAbsoluteTimeGetCurrent()
        animationTiming.tracerTimeInterval = 0
        tracerView.setNeedsDisplay()
        displayLink.paused = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        displayLink.paused = true
        super.viewWillDisappear(animated)
    }
    
    func prepareForVSync(displayLink: CADisplayLink) {
        animationTiming.tracerTimeInterval = CFAbsoluteTimeGetCurrent() + displayLink.duration - animationTiming.tracerResetTime
        dataModel.regenerateTracerPoints()
        tracerView.setNeedsDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
