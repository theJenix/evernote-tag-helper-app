//
//  AccessabilityHelper.swift
//  EvernoteTagHelper
//
//  Created by Jesse Rosalia on 12/12/16.
//  Copyright © 2016 Jesse Rosalia. All rights reserved.
//

import Foundation

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
}
