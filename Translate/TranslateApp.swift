//
//  TranslateApp.swift
//  Translate
//
//  Created by 김은서 on 12/7/25.
//

import SwiftUI

@main
struct TranslateApp: App {
    // AppDelegate를 SwiftUI App에 연결
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
