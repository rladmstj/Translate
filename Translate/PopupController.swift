import Cocoa

class PopupController: NSObject {

    private let popover = NSPopover()
    private var anchorWindow: NSWindow?

    private var wordLabel: NSTextField!
    private var translationTextView: NSTextView!

    private var lastText: String?

    override init() {
        super.init()
        setupPopoverUI()
    }

    // MARK: - UI 구성
    private func setupPopoverUI() {
        popover.behavior = .transient          // 다른 곳 클릭하면 자동으로 닫힘
        popover.animates = true

        let vc = NSViewController()
        vc.view = NSView(frame: NSRect(x: 0, y: 0, width: 260, height: 190))

        // 단어 라벨
        let word = NSTextField(labelWithString: "")
        word.font = .systemFont(ofSize: 15, weight: .semibold)
        word.frame = NSRect(x: 15, y: 155, width: 230, height: 24)
        vc.view.addSubview(word)
        self.wordLabel = word

        // 스크롤뷰 + 텍스트뷰
        let scroll = NSScrollView(frame: NSRect(x: 15, y: 15, width: 230, height: 130))
        scroll.hasVerticalScroller = true
        scroll.borderType = .noBorder
        scroll.drawsBackground = false

        let textView = NSTextView(frame: scroll.bounds)
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = .systemFont(ofSize: 13)
        textView.backgroundColor = .clear
        textView.textContainerInset = NSSize(width: 0, height: 2)
        scroll.documentView = textView

        vc.view.addSubview(scroll)
        self.translationTextView = textView

        // 약간 둥근 느낌 주기
        vc.view.wantsLayer = true
        vc.view.layer?.cornerRadius = 8
        vc.view.layer?.masksToBounds = true

        popover.contentViewController = vc
    }

    // MARK: - 팝오버 표시
    func show(for text: String) {

        // 이미 떠 있고, 같은 단어이고, "번역 중..."이 아닌 결과가 있는 상태라면 다시 안 띄움
        if popover.isShown,
           lastText == text
             {
            return
        }

        lastText = text

        // 기존 anchor 윈도우 정리
        anchorWindow?.orderOut(nil)
        anchorWindow = nil

        // UI 업데이트
        wordLabel.stringValue = text
        translationTextView.string = "번역 중..."

        // 마우스 위치 기준으로 1x1짜리 앵커 윈도우 만들기
        let mouse = NSEvent.mouseLocation
        let rect = NSRect(x: mouse.x, y: mouse.y, width: 1, height: 1)

        let anchor = NSWindow(
            contentRect: rect,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        anchor.isOpaque = false
        anchor.backgroundColor = .clear
        anchor.level = .floating
        anchor.ignoresMouseEvents = true
        anchor.orderFrontRegardless()
        anchorWindow = anchor

        // 팝오버 띄우기
        if let view = anchor.contentView {
            popover.show(relativeTo: .zero, of: view, preferredEdge: .maxY)
        }

        // 번역 실행 (마지막 응답이 이기는 방식)
        fetchKoreanDictionary(text: text) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                // 선택된 단어가 이미 바뀐 경우엔 그냥 무시
                if self.lastText != text { return }

                self.translationTextView.string = result
            }
        }
    }

    // MARK: - 팝오버 닫기
    func close() {
        popover.performClose(nil)
        anchorWindow?.orderOut(nil)
        anchorWindow = nil
    }

    // MARK: - 네이버 API
    private func fetchKoreanDictionary(text: String, completion: @escaping (String) -> Void) {

        let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? text
        let urlStr = "https://ac.dict.naver.com/enko/ac?q=\(encoded)&q_enc=utf-8&st=11001&frm=ac"

        guard let url = URL(string: urlStr) else {
            completion("URL 오류")
            return
        }

        var req = URLRequest(url: url)
        req.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")

        URLSession.shared.dataTask(with: req) { data, _, err in

            if let err = err {
                completion("요청 실패: \(err.localizedDescription)")
                return
            }
            guard let data = data else {
                completion("데이터 없음")
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let items = json["items"] as? [[Any]] else {
                    completion("뜻 없음")
                    return
                }

                var list: [String] = []

                for group in items {
                    if let entries = group as? [[Any]] {
                        for entry in entries {
                            if entry.count >= 3,
                               let word = (entry[0] as? [Any])?.first as? String,
                               let meaning = (entry[2] as? [Any])?.first as? String {
                                let formatted = meaning.replacingOccurrences(of: ", ", with: "\n")
                                list.append("• \(word)\n\(formatted)")
                            }
                        }
                    }
                }

                completion(list.isEmpty ? "뜻 없음" : list.joined(separator: "\n\n"))

            } catch {
                completion("파싱 오류: \(error.localizedDescription)")
            }

        }.resume()
    }
}
