//
//  PopupPanel.swift
//  EvernoteTagHelper
//
//  Created by Jesse Rosalia on 12/12/16.
//  Copyright © 2016 Jesse Rosalia. All rights reserved.
//

import Cocoa
import Carbon

protocol PopupTextFieldDelegate {
    func enterPressed()
}

class PopupTextField: NSTextField, NSTextFieldDelegate {
    
    var _completionStrings: [String] = []
    var _stringSelectedFunc: ((Void) -> (Void))?
    var _fieldEditor: NSTextView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func controlTextDidBeginEditing(_ obj: Notification) {
        _fieldEditor = obj.userInfo!["NSFieldEditor"] as! NSTextView
    }

    override func keyUp(with event: NSEvent) {
        NSLog("Key: %d", event.keyCode)
        //NOTE: It's a little unclear when this is hit vs the insertNewline: command selector below.  I think it has to do with
        // the field editor and completion dialog.  In either case, supporting both get's us what we want
        if event.keyCode == UInt16(kVK_Return) {
            _stringSelectedFunc?()
        } else {
            let lower = event.characters!.lowercased()
            if lower >= "a" && lower <= "z" || lower == "_" {
                if _fieldEditor != nil {
                    _fieldEditor.complete(nil)
                }
            }
        }
    }

    func control(_ control: NSControl, textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>) -> [String] {
        return _completionStrings.filter({ (s) -> Bool in
            return s.hasPrefix(stringValue)
        })
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        NSLog(commandSelector.description)
        if commandSelector.description == "insertNewline:" {
            _stringSelectedFunc?()
            return true
        } else if commandSelector.description == "moveDown:" {
            _fieldEditor.complete(nil)
            return true
        } else {
            return false
        }
    }
}

class PopupPanel: NSPanel, PopupTextFieldDelegate {

    var _text: PopupTextField!
    var _enterPressed = false

    init() {
        let frameRect = NSMakeRect(0,0,100,20);// This will chang_e based on the size you need
        super.init(contentRect: frameRect,
                   styleMask: NSWindowStyleMask.nonactivatingPanel,
                   backing: NSBackingStoreType.buffered,
                   defer: false)
        
        _text = PopupTextField(frame: frameRect)
        _text._stringSelectedFunc = self.enterPressed

        self.contentView?.addSubview(_text)
        self.hidesOnDeactivate = false
        self.level = Int(CGWindowLevelForKey(CGWindowLevelKey.popUpMenuWindow))
    }
    
    func enterPressed() {
        _enterPressed = true
        self.resignKey()
    }

    func setTags(tags: [String]) {
        _text._completionStrings = tags
    }

    override var canBecomeKey: Bool {
        return true
    }

    func focusTextField(_ delay: TimeInterval) {
        self.perform(#selector(self.makeFirstResponder(_:)), with: _text, afterDelay:delay)
    }
    
    override func cancelOperation(_ sender: Any?) {
        self.resignKey()
    }
}
