
// globalEventMonitor.swift
// Visible
//
// a global event monitor borrowed from:
// https://stackoverflow.com/questions/38512281/swift-on-os-x-how-to-handle-global-mouse-events
//



import Cocoa

public class globalEventMonitor {
    private var monitor: AnyObject?
    private let mask: NSEventMask
    private let handler: (NSEvent?) -> ()
    
    public init(mask: NSEventMask, handler: @escaping (NSEvent?) -> ()) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    // Start monitoring
    public func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as AnyObject?
    }
    
    // Stop monitoring
    public func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
