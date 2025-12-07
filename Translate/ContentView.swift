////
////  ContentView.swift
////  Translate
////
////  Created by 김은서 on 12/7/25.
////
//
//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Text("Translate Helper가 실행 중입니다.")
//                .font(.headline)
//                .padding()
//            Text("미리보기에서 단어를 더블클릭해보세요.")
//                .font(.subheadline)
//        }
//        .frame(minWidth: 300, minHeight: 120)
//    }
//}
//
//#Preview {
//    ContentView()
//}
import SwiftUI
import AppKit

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Translate Helper 테스트")
                .font(.headline)
                .padding(.bottom, 4)

            Text("아래 텍스트에서 단어를 드래그 또는 더블클릭하면 팝업이 뜹니다.")
                .font(.subheadline)
                .padding(.bottom, 10)

            SelectableTextView()
                .frame(height: 200)
                .border(Color.gray.opacity(0.4))
                .padding(.bottom, 10)

            Spacer(minLength: 20)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}


// MARK: - NSTextView Wrapper (SwiftUI에서 selectable text를 사용하기 위한 코드)
struct SelectableTextView: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()

        textView.isEditable = false
        textView.isSelectable = true
        textView.font = NSFont.systemFont(ofSize: 16)
        textView.string =
        """
        This is a test text area.

        Select a word in this box and the Translate popup will appear.
        단어 선택 테스트를 위해 아무거나 선택해보세요.
        """

        textView.delegate = context.coordinator
        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) { }

    class Coordinator: NSObject, NSTextViewDelegate {
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }

            let range = textView.selectedRange()
            if range.length == 0 { return }

            let selected = (textView.string as NSString).substring(with: range)
            let trimmed = selected.trimmingCharacters(in: .whitespacesAndNewlines)

            if !trimmed.isEmpty {
                print("Selected in app: \(trimmed)")
                PopupController().show(for: trimmed)
            }
        }
    }
}
