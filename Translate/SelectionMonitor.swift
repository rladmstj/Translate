//
//  SelectionMonitor.swift
//  Translate
//
//  Created by 김은서 on 12/7/25.
//

import Cocoa
import ApplicationServices

class SelectionMonitor {

    private var timer: Timer?
    private var lastText: String?
    private let popup = PopupController()

    func start() {
        print("start selection monitor")
        print("AX trusted?:", AXIsProcessTrusted())

        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
                self?.checkSelection()
                print("tick")
            }

            if let t = self.timer {
                RunLoop.main.add(t, forMode: .common)
            }
        }
    }

    func stop() {
        timer?.invalidate()
    }

    private func checkSelection() {
        // ✅ 마우스 버튼이 눌려 있는 동안에는 아무 것도 안 함
        // (드래그로 선택하는 중에는 팝업이 안 뜨게)
        if NSEvent.pressedMouseButtons != 0 {
            // print("mouse pressed, skip")
            return
        }

        // (선택) 특정 앱에서만 동작하게 하고 싶으면 이 필터 사용
        // if let bundleID = currentAppBundleIdentifier(),
        //    bundleID != "com.apple.Preview" {
        //     return
        // }

        guard let selected = getSelectedText(),
              !selected.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }

        // 이전과 같은 텍스트면 다시 안 띄움
        if selected == lastText { return }
        lastText = selected

        // 새 텍스트 선택 → 팝업 띄우기
        DispatchQueue.main.async {
            print("Selected text detected: \(selected)")
            self.popup.show(for: selected)
        }
    }

    /// 현재 포커스된 UI 요소에서 선택된 텍스트 가져오기
    private func getSelectedText() -> String? {
        let systemWide = AXUIElementCreateSystemWide()

        var focusedElement: AnyObject?
        let result = AXUIElementCopyAttributeValue(
            systemWide,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )

        if result != .success {
            print("AX ERROR: focused element 가져오기 실패 — code: \(result.rawValue)")
            return nil
        }

        let element = focusedElement as! AXUIElement

        var selectedText: AnyObject?
        let res2 = AXUIElementCopyAttributeValue(
            element,
            kAXSelectedTextAttribute as CFString,
            &selectedText
        )

        if res2 != .success {
            // 선택된 텍스트가 없는 경우 종종 여기로 옴
            // print("AX ERROR: selected text 없음 — code: \(res2.rawValue)")
            if let id = currentAppBundleIdentifier() {
                print("현재 포커스 앱:", id)
            }
            return nil
        }

        return selectedText as? String
    }

    /// 현재 포커스를 가진 앱의 bundle identifier (예: com.apple.Preview)
    private func currentAppBundleIdentifier() -> String? {
        let systemWide = AXUIElementCreateSystemWide()
        var app: AnyObject?

        guard AXUIElementCopyAttributeValue(
            systemWide,
            kAXFocusedApplicationAttribute as CFString,
            &app
        ) == .success else {
            return nil
        }

        let axApp = app as! AXUIElement

        var pid: pid_t = 0
        AXUIElementGetPid(axApp, &pid)

        if let runningApp = NSRunningApplication(processIdentifier: pid) {
            return runningApp.bundleIdentifier
        }
        return nil
    }

    deinit {
        print("SelectionMonitor DEINIT — 객체 사라짐!!!")
    }
}
