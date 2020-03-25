//
//  WiggleMyMouse.swift
//  WiggleMyMouse
//
//  Copyright 2020 Matt Whitehead
//  Licensed under the MIT license
//  Credit for icon: https://www.flaticon.com/free-icon/mouse_689348


import Cocoa

@NSApplicationMain
class WiggleMyMouse: NSObject, NSApplicationDelegate {

    // bind UI elements
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var numberDisplay: NSTextField!
    
    // define event loop
    var eventLoop: Timer?
    
    // function to start event loop
    func startEventLoop(_ interval: Double) {
        print("Starting event loop with fire every \(interval) seconds...")
        eventLoop = Timer.scheduledTimer(
            timeInterval: interval,
            target: self,
            selector: #selector(fireEvent),
            userInfo: nil,
            repeats: true
        )
    }
    
    // function to stop event loop
    func stopEventLoop() {
        print("Stopping event loop...")
        eventLoop?.invalidate()
    }
    
    // function to move the mouse to a new position
    func moveMouse(_ newPosition: NSPoint) {
        // handle the broadcasting of the mouse move event
        // Adapted from: https://github.com/bhaller/Jiggler/blob/master/AppDelegate.m
        let eventSource = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        if let sourceRef = eventSource {
            let eventMoved = CGEvent(
                mouseEventSource: sourceRef,
                mouseType: CGEventType.mouseMoved,
                mouseCursorPosition: newPosition,
                mouseButton: CGMouseButton.left
            )
            eventMoved?.post(tap: CGEventTapLocation.cghidEventTap)
        }
    }
    
    // function to be called each time the event is fired
    @objc
    func fireEvent() {
        // get display information (used to calculate height offset)
        let mainScreen = NSScreen.main
        
        // set move distance and wiggle delay
        let moveDistance = 15
        let wiggleDelay = 0.5
        
        // calulate our original and new positions (correcting for different screen heights)
        let originalPosition = NSMakePoint(NSEvent.mouseLocation.x, (mainScreen?.frame.height ?? 0) - NSEvent.mouseLocation.y)
        let newPosition = NSMakePoint(originalPosition.x + CGFloat(moveDistance), originalPosition.y)

        self.moveMouse(newPosition)
        
        // wait for the wiggle delay before moving back to the og position
        // if we don't have a wait here it happens instantly and you can't see the move
        DispatchQueue.main.asyncAfter(deadline: .now() + wiggleDelay) {
            self.moveMouse(originalPosition)
        }
    }
    
    // UI events
    @IBAction func fireSlider(_ sender: Any) {
        numberDisplay.stringValue = slider.stringValue
    }
    
    @IBAction func fireStartButton(_ sender: Any) {
        print("Start button pushed")
        let eventInterval = (slider.doubleValue * 60)
        startEventLoop(eventInterval)
        stopButton.isEnabled = true
        startButton.isEnabled = false
    }
    
    @IBAction func fireStopButton(_ sender: Any) {
        print("Stop button pushed")
        stopEventLoop()
        startButton.isEnabled = true
        stopButton.isEnabled = false
    }
    
    // Application start and stop events
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("Starting application")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        print("Stopping application")
    }
}
