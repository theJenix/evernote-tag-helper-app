//
//  PopupPanel.swift
//  EvernoteTagHelper
//
//  Created by Jesse Rosalia on 12/12/16.
//  Copyright © 2016 Jesse Rosalia. All rights reserved.
//

import Cocoa

class PopupPanel: NSPanel {

    var _text: NSTextField!
    init() {
        super.init(contentRect: NSMakeRect(0, 0, 100, 100),
                                        styleMask: NSWindowStyleMask.nonactivatingPanel,
                                        backing: NSBackingStoreType.buffered, defer: false)
        
        let frameRect = NSMakeRect(20,20,80,20);// This will chang_e based on the size you need
        _text = NSTextField()
        _text.frame = frameRect
        self.contentView?.addSubview(_text)
        self.hidesOnDeactivate = false
        self.level = Int(CGWindowLevelForKey(CGWindowLevelKey.popUpMenuWindow))
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
