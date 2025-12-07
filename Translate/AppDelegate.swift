//
//  AppDelegate.swift
//  Translate
//
//  Created by 김은서 on 12/7/25.
//

import Cocoa
import ApplicationServices   // AX(손쉬운 사용) API

class AppDelegate: NSObject, NSApplicationDelegate {

    var selectionMonitor: SelectionMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.requestAccessibilityPermission()

            self.selectionMonitor = SelectionMonitor()
            self.selectionMonitor?.start()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        selectionMonitor?.stop()
    }

    private func requestAccessibilityPermission() {
        // 처음 실행 시 “손쉬운 사용” 권한 팝업 뜸
        //        let options: NSDictionary = [
        //            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        //        ]
        //        _ = AXIsProcessTrustedWithOptions(options)
        //    }
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)}
}
