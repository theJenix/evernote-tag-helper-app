//
//  AccessabilityHelper.swift
//  EvernoteTagHelper
//
//  Created by Jesse Rosalia on 12/12/16.
//  Copyright © 2016 Jesse Rosalia. All rights reserved.
//

import Foundation
import Carbon.HIToolbox.Events

class AccessabilityCursor {
    
    var _systemWideElement: AXUIElement!
    var _currentElement: AXUIElement?
    var _currentValue: AXValue?
    var _error: AXError?
    var _context: String = ""
    
    init() {
        _systemWideElement = AXUIElementCreateSystemWide();
    }

    func startAtSystemWideElement() -> AccessabilityCursor {
        _currentElement = _systemWideElement
        return self
    }
    
    func select(_ uiElementAttribute: String) -> AccessabilityCursor? {
        _context = "select"
        var ret: AccessabilityCursor? = nil
        if let element = _currentElement {
            var outval: CFTypeRef?
            _error = AXUIElementCopyAttributeValue(element, uiElementAttribute as CFString, &outval)
            if _error == AXError.success {
                _currentElement = (outval as! AXUIElement)
                ret = self
            } else {
                _error = AXError.illegalArgument
            }
        }
        return ret
    }
    
    func getValue(_ valueAttribute: String) -> AccessabilityCursor? {
        _context = "getValue"
        var ret: AccessabilityCursor? = nil
        if let element = _currentElement {
            var outval: CFTypeRef?
            
            _error = AXUIElementCopyAttributeValue(element, valueAttribute as CFString, &outval);
            if _error == AXError.success {
                _currentValue = (outval as! AXValue)
                ret = self
            }
        }
        return ret
    }
    
    func boundsForRange() -> AccessabilityCursor? {
        _context = "boundsForRange"
        var ret: AccessabilityCursor? = nil
        if let element = _currentElement,
           let value = _currentValue {
            //TODO: check for CGRange type...
            var outval: CFTypeRef?
            _error = AXUIElementCopyParameterizedAttributeValue(element, kAXBoundsForRangeParameterizedAttribute as CFString, value, &outval);
            if _error == AXError.success {
                _currentValue = (outval as! AXValue)
                ret = self
            }
        }
        return ret
    }

    func get() -> Any? {
        _context = "get"
        var ret: Any? = nil
        if let value = _currentValue {
            switch(AXValueGetType(value)) {
            case AXValueType.cgPoint:
                var point = CGPoint()
                if AXValueGetValue(value, AXValueType.cgPoint, &point) {
                    ret = point
                }
                break
            case AXValueType.cgSize:
                var size = CGSize()
                if AXValueGetValue(value, AXValueType.cgSize, &size) {
                    ret = size
                }
                break
            case AXValueType.cgRect:
                var rect = CGRect()
                if AXValueGetValue(value, AXValueType.cgRect, &rect) {
                    ret = rect
                }
                break
            case AXValueType.cfRange:
                var range = CFRange()
                if AXValueGetValue(value, AXValueType.cfRange, &range) {
                    ret = range
                }
                break
//            case AXValueType.axError:
  //              break
            default:
                break
            }
        }
        return ret
    }
    
    var keyCodeMap: Dictionary<Character, (Int, Bool)> = [
        "a": (kVK_ANSI_A, false),
        "b": (kVK_ANSI_B, false),
        "c": (kVK_ANSI_C, false),
        "d": (kVK_ANSI_D, false),
        "e": (kVK_ANSI_E, false),
        "f": (kVK_ANSI_F, false),
        "g": (kVK_ANSI_G, false),
        "h": (kVK_ANSI_H, false),
        "i": (kVK_ANSI_I, false),
        "j": (kVK_ANSI_J, false),
        "k": (kVK_ANSI_K, false),
        "l": (kVK_ANSI_L, false),
        "m": (kVK_ANSI_M, false),
        "n": (kVK_ANSI_N, false),
        "o": (kVK_ANSI_O, false),
        "p": (kVK_ANSI_P, false),
        "q": (kVK_ANSI_Q, false),
        "r": (kVK_ANSI_R, false),
        "s": (kVK_ANSI_S, false),
        "t": (kVK_ANSI_T, false),
        "u": (kVK_ANSI_U, false),
        "v": (kVK_ANSI_V, false),
        "w": (kVK_ANSI_W, false),
        "x": (kVK_ANSI_X, false),
        "y": (kVK_ANSI_Y, false),
        "z": (kVK_ANSI_Z, false),
        "A": (kVK_ANSI_A, true),
        "B": (kVK_ANSI_B, true),
        "C": (kVK_ANSI_C, true),
        "D": (kVK_ANSI_D, true),
        "E": (kVK_ANSI_E, true),
        "F": (kVK_ANSI_F, true),
        "G": (kVK_ANSI_G, true),
        "H": (kVK_ANSI_H, true),
        "I": (kVK_ANSI_I, true),
        "J": (kVK_ANSI_J, true),
        "K": (kVK_ANSI_K, true),
        "L": (kVK_ANSI_L, true),
        "M": (kVK_ANSI_M, true),
        "N": (kVK_ANSI_N, true),
        "O": (kVK_ANSI_O, true),
        "P": (kVK_ANSI_P, true),
        "Q": (kVK_ANSI_Q, true),
        "R": (kVK_ANSI_R, true),
        "S": (kVK_ANSI_S, true),
        "T": (kVK_ANSI_T, true),
        "U": (kVK_ANSI_U, true),
        "V": (kVK_ANSI_V, true),
        "W": (kVK_ANSI_W, true),
        "X": (kVK_ANSI_X, true),
        "Y": (kVK_ANSI_Y, true),
        "Z": (kVK_ANSI_Z, true),
        " ": (kVK_Space, false),
        "-": (kVK_ANSI_Minus, false),
        "_": (kVK_ANSI_Minus, true),
        "0": (kVK_ANSI_0, false),
        "1": (kVK_ANSI_1, false),
        "2": (kVK_ANSI_2, false),
        "3": (kVK_ANSI_3, false),
        "4": (kVK_ANSI_4, false),
        "5": (kVK_ANSI_5, false),
        "6": (kVK_ANSI_6, false),
        "7": (kVK_ANSI_7, false),
        "8": (kVK_ANSI_8, false),
        "9": (kVK_ANSI_9, false)
    ]
    
    func typeCharacters(_ chars: String) -> AccessabilityCursor? {
        var ret: AccessabilityCursor? = nil
        if let element = _currentElement {
            var pid: pid_t = 0
            _error = AXUIElementGetPid(element, &pid)
            if _error == AXError.success {
                //print(chars)
                // Prep the events (do this before executing them, so the actual typing is fast)
                let events: [CGEvent?] = chars.characters.map({ (c:Character) in
                    if let (keyCode, shift) = keyCodeMap[c] {
                        //print("\(keyCode), \(flags)")
                        let event = CGEvent(keyboardEventSource: nil, virtualKey: UInt16(keyCode), keyDown: true)!
                        if shift {
                            event.flags.formUnion(CGEventFlags.maskShift)
                        }
                        return event
                    } else {
                        return nil
                    }
                })
                // Execute all of the events as fast as we can
                events.forEach { $0?.postToPid(pid) }

                ret = self
            }
        }
        return ret
    }
}
