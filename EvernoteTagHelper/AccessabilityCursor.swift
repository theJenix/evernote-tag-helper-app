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
    
    var keyCodeMap: Dictionary<Character, Int> = [
        "a": kVK_ANSI_A,
        "b": kVK_ANSI_B,
        "c": kVK_ANSI_C,
        "d": kVK_ANSI_D,
        "e": kVK_ANSI_E,
        "f": kVK_ANSI_F,
        "g": kVK_ANSI_G,
        "h": kVK_ANSI_H,
        "i": kVK_ANSI_I,
        "j": kVK_ANSI_J,
        "k": kVK_ANSI_K,
        "l": kVK_ANSI_L,
        "m": kVK_ANSI_M,
        "n": kVK_ANSI_N,
        "o": kVK_ANSI_O,
        "p": kVK_ANSI_P,
        "q": kVK_ANSI_Q,
        "r": kVK_ANSI_R,
        "s": kVK_ANSI_S,
        "t": kVK_ANSI_T,
        "u": kVK_ANSI_U,
        "v": kVK_ANSI_V,
        "w": kVK_ANSI_W,
        "x": kVK_ANSI_X,
        "y": kVK_ANSI_Y,
        "z": kVK_ANSI_Z,
    ]
    
    func keyCodeAndFlags(_ c: Character) -> (UInt16, CGEventFlags) {
        var flags:CGEventFlags = CGEventFlags(rawValue: 0)
        var keyCode = 0
        if c == "_" {
            flags = CGEventFlags.maskShift
            keyCode = kVK_ANSI_Minus
        } else if c >= "A" && c <= "Z" {
            flags = CGEventFlags.maskShift
            keyCode = keyCodeMap[String(c).lowercased().characters.first!]!
        } else {
            keyCode = keyCodeMap[c]!
        }

        return (UInt16(keyCode), flags)
    }

    func typeCharacters(_ chars: String) -> AccessabilityCursor? {
        var ret: AccessabilityCursor? = nil
        if let element = _currentElement {
            var pid: pid_t = 0
            _error = AXUIElementGetPid(element, &pid)
            if _error == AXError.success {
                //print(chars)
                // Prep the events (do this before executing them, so the actual typing is fast)
                let events: [CGEvent] = chars.characters.map({ (c:Character) in
                    let (keyCode, flags) = keyCodeAndFlags(c)
                    //print("\(keyCode), \(flags)")
                    let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)!
                    event.flags.formUnion(flags)
                    return event
                })
                // Execute all of the events as fast as we can
                events.forEach { $0.postToPid(pid) }

                ret = self
            }
        }
        return ret
    }
}
