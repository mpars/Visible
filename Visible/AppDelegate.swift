
// AppDelegate.swift
// Visible
//
// MIT License
//
// Copyright (c) 2017 Mark Parsons
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//


import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    // Setup items
    let statusItem = NSStatusBar.system().statusItem(withLength:-2)
    let statusItemPopover = NSPopover()
    var eventMonitor: globalEventMonitor?
    
    
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // Check initial status of hidden files
        RunShellCommandFirstTime(sender: self)
        
            // If the statusItem button is pressed then
            if let button = statusItem.button {
                button.action = #selector(AppDelegate.checkForClickType(sender:))
                button.sendAction(on: [.leftMouseUp, .rightMouseUp])
                
                //button.image = NSImage(named: "hidden@x2")
                //to make popover use below
                
                //button.action = #selector(AppDelegate.togglePopover(sender:))
                
                // To Run Shell Command on left click of statusitem
                //button.action = #selector(AppDelegate.RunShellCommand(sender:))
                
            }
   
        
        statusItemPopover.contentViewController = displayViewController(nibName: "displayViewController", bundle: nil)
        
        // Setup the globalEventMonitor on popover
        
        eventMonitor = globalEventMonitor(mask: [.leftMouseUp, .rightMouseUp]) { [unowned self] event in
            if self.statusItemPopover.isShown {
                self.closeStatusItemPopover(sender: event)
            }
        }
        
    }
    // end of applicationDidFinishLaunching function
    
    // function to check if left or right mouse button has been clicked
    func checkForClickType(sender: NSStatusItem) {
        let event = NSApp.currentEvent!
        if event.type == NSEventType.rightMouseUp {
            
            // Right button click
            RunShellCommand(sender: sender)
            
        } else {
            // Left button click
            toggleStatusItemPopover(sender: sender)
        }
        
    }
    // end of function 
    
    // function to show the popover
    func showStatusItemPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            statusItemPopover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            // Start the eventMonitor
            eventMonitor?.start()
        }
    }
    // end of function  
    
    // function to close the popover
    func closeStatusItemPopover(sender: AnyObject?) {
        statusItemPopover.performClose(sender)
        // Stop the eventMonitor
        eventMonitor?.stop()
    }
    // end of function 
    
    // function to check if popover is open or closed
    func toggleStatusItemPopover(sender: AnyObject?) {
        if statusItemPopover.isShown {
            closeStatusItemPopover(sender: sender)
        } else {
            showStatusItemPopover(sender: sender)
        }
    }
    // End of function
    
    // function to change the StatusItemImage to Visible and kill the finder
    func ChangeStatusBarImageVisible(sender: AnyObject? ) {
     
        
        if let button = statusItem.button {
            button.image = NSImage(named: "visible@x2")
        }
        
        // now update the com.apple.finder plist with new setting
        let task = Process()
        task.launchPath="/usr/bin/defaults"
        task.arguments=["write", "com.apple.finder", "AppleShowAllFiles", "-boolean", "TRUE"]
        task.launch()
        
        // Wait until task is completed
        task.waitUntilExit()
        
        // Kill the finder
        let killtask = Process()
        killtask.launchPath="/usr/bin/killall"
        killtask.arguments=["Finder"]
        killtask.launch()
        
    }
    // end of function
    
    // function to change the StatusItemImage to Hidden and kill the finder
    func ChangeStatusBarImageHidden(sender: AnyObject? ) {
        
        
        if let button = statusItem.button {
            button.image = NSImage(named: "hidden@x2")
        }
        
        // now update the com.apple.finder plist with new setting
        let task = Process()
        task.launchPath="/usr/bin/defaults"
        task.arguments=["write", "com.apple.finder", "AppleShowAllFiles", "-boolean", "FALSE"]
        task.launch()
        
        // Wait until task is completed
        task.waitUntilExit()
        
        // Kill the Finder
        let killtask = Process()
        killtask.launchPath="/usr/bin/killall"
        killtask.arguments=["Finder"]
        killtask.launch()
    }
    // end of function
    
    
    // function to check current AppleShowAllFiles status and change accordingly
    func RunShellCommand(sender: AnyObject?) {
        // Create a Task instance
        let task = Process()
        
        // Set the task parameters
        task.launchPath="/usr/bin/defaults"
        
        // Make sure arguements are separated
        task.arguments=["read", "com.apple.finder", "AppleShowAllFiles"]
        
        
        // Create a Pipe and make the task
        // put all the output there
        let pipe = Pipe()
        task.standardOutput = pipe
        
        // Launch the task
        task.launch()
        
        // Get the data
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        
        print(output!)
        
        if (output!=="1\n") || output!=="YES\n" {
            // Files are visible, change to hidden
            ChangeStatusBarImageHidden(sender: sender)
            
        } else {
            // Files are hidden change to visible
            ChangeStatusBarImageVisible(sender: sender)
        }
    }
    // end of function
    
    // function to check to see whether files are hidden on app launch 
    // by checking com.Apple.Finder plist
    func RunShellCommandFirstTime(sender: AnyObject?) {
        // Create a Task instance
        let task = Process()
        
        // Set the task parameters
        task.launchPath="/usr/bin/defaults"
        
        // Make sure arguements are separated
        task.arguments=["read", "com.apple.finder", "AppleShowAllFiles"]
        
        
        // Create a Pipe and make the task
        // put all the output there
        let pipe = Pipe()
        task.standardOutput = pipe
        
        // Launch the task
        task.launch()
        
        // Get the data
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        
        print(output!)
        
        // Check the output of task
        if (output!=="1\n" || output!=="YES\n") {
            
            // Visible
            if let button = statusItem.button {
                button.image = NSImage(named: "visible@x2")
            }
            
        } else {
            
            // Hidden : change the statusitem.button image accordingly
            if let button = statusItem.button {
                button.image = NSImage(named: "hidden@x2")
            }
        }
        
    }
    // end of function
    
    
    
    
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    
}
