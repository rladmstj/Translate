//
//  NonKeyPanel.swift
//  Translate
//
//  Created by 김은서 on 12/8/25.
//

import Cocoa

class NonKeyPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
