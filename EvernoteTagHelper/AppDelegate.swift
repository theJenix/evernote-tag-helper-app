//
//  AppDelegate.swift
//  EvernoteTagHelper
//
//  Created by Jesse Rosalia on 12/10/16.
//  Copyright © 2016 Jesse Rosalia. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    var _monitor: Any?
    var _debugMonitor: Any?
    var _app: NSApplication!
    // Need to keep a reference to the panel, or else it dies immediately
    var _panel = PopupPanel()
    
    func windowDidResignKey(_ notification: Notification) {
        let openDuration = 0.15
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current().duration = openDuration
        _panel.animator().alphaValue = 0;
        NSAnimationContext.endGrouping()

        _panel.orderOut(nil)
    }

    
    func openHelperPanelAtPoint(point: NSPoint) {
        _panel.delegate = self
        let panelRect = NSRect(origin: CGPoint(x:point.x, y:point.y - 50), size: NSSize(width: 140, height: 50))
        let openDuration = 0.15
        
        NSApp.activate(ignoringOtherApps: false)
        _panel.makeKeyAndOrderFront(nil)
        _panel.alphaValue = 0
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current().duration = openDuration
        _panel.animator().setFrame(panelRect, display:true)
        _panel.animator().alphaValue = 1;
        NSAnimationContext.endGrouping()
        

        _panel.focusTextField(openDuration)
    
        /*_
                NSWindow *panel = [self window];
                
                NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
                NSRect statusRect = [self statusRectForWindow:panel];
                
                NSRect panelRect = [panel frame];
                panelRect.size.width = PANEL_WIDTH;
                panelRect.size.height = POPUP_HEIGHT;
                panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
                panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
                
                if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
                panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
                
                [NSApp activateIgnoringOtherApps:NO];
                [panel setAlphaValue:0];
                [panel setFrame:statusRect display:YES];
                [panel makeKeyAndOrderFront:nil];
                
                NSTimeInterval openDuration = OPEN_DURATION;
                
                NSEvent *currentEvent = [NSApp currentEvent];
                if ([currentEvent type] == NSLeftMouseDown)
                {
                    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
                    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
                    BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
                    if (shiftPressed || shiftOptionPressed)
                    {
                        openDuration *= 10;
                        
                        if (shiftOptionPressed)
                        NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                        NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
                    }
                }
                
                [panel performSelector:@selector(makeFirstResponder:) withObject:self.searchField afterDelay:openDuration];
        }
 */
    }
    
    func axGetCursorPosition() -> CGRect? {
        let axh = AccessabilityCursor()
        
        let rect = axh.startAtSystemWideElement()
                      .select(kAXFocusedUIElementAttribute)?
                      .getValue(kAXSelectedTextRangeAttribute)?
                      .boundsForRange()?
                      .get() as? CGRect

        // if rect is nill, print an error
        if rect == nil {
            switch(axh._context) {
            case "select":
                print("Could not get focused element")
                break
            case "getValue":
                print("Could not get selected range")
                break
            case "boundsForRange":
                print("Could not get bounds for selected range");
                break
            case "get":
                print("Unable to get value of bounds for selected range")
                break
            default:
                break
            }
        }
        
        return rect
        
        /*
        let systemWideElement = AXUIElementCreateSystemWide();
        var focusedElement: CFTypeRef?
        var retVal: CGRect?
        let error = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement);
        if error != AXError.success {
            print("Could not get focused element")
        } else {
            var selectedRangeValue: CFTypeRef?
            let getSelectedRangeError = AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSelectedTextRangeAttribute as CFString, &selectedRangeValue);
            if getSelectedRangeError != AXError.success {
                print("Could not get selected range")
            } else {
                var selectedRange = CFRange()
                let success = AXValueGetValue(selectedRangeValue as! AXValue, AXValueType.cfRange, &selectedRange)
                var selectionBoundsValue: CFTypeRef?
                let getSelectionBoundsError = AXUIElementCopyParameterizedAttributeValue(focusedElement as! AXUIElement, kAXBoundsForRangeParameterizedAttribute as CFString, selectedRangeValue as! AXValue, &selectionBoundsValue);
                if getSelectionBoundsError == AXError.success {
                    var selectionBounds = CGRect()
                    if AXValueGetValue(selectionBoundsValue as! AXValue, AXValueType.cgRect, &selectionBounds) {
                       // print(String(format: "Selection bounds: %@", NSStringFromRect(NSRectFromCGRect(selectionBounds!))));
                        retVal = selectionBounds
                    } else {
                        print("Unable to get value of bounds for selected range")
                    }
                } else {
                    print("Could not get bounds for selected range");
                }
            }
        }*/

    }

    func handleGlobalKeyDown(event: NSEvent) {
        if event.characters == "_" {
            if let app = NSWorkspace.shared().frontmostApplication,
               let name = app.localizedName {
                if true  || name.contains("Evernote") {
                    NSLog("\(event)")
                    let rect = self.axGetCursorPosition()
                    if let r = rect {
                        var origin = r.origin
                        origin.y = NSScreen.main()!.frame.size.height - origin.y - r.size.height
                        
                        self.openHelperPanelAtPoint(point: origin)
                    }
                }
            }
        }
    }

    func printEvent(event: NSEvent) {
        print("\(event)")
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("\(aNotification.object)")
        let app = aNotification.object as! NSApplication
        _app = app
        print("Adding monitor")
        
        _monitor = NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.keyDown, handler: self.handleGlobalKeyDown)
        //_debugMonitor = NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.flagsChanged, handler: self.printEvent)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        if let m = _monitor {
            NSEvent.removeMonitor(m)
        }
        if let m = _debugMonitor {
            NSEvent.removeMonitor(m)
        }
    }
}
