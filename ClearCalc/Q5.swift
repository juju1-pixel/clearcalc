import Foundation
import SwiftUI
import WebKit

private enum N8: String, CaseIterable, Identifiable {
    case m0 = "计算"
    case m1 = "时间成本"
    case m2 = "分摊"
    case m3 = "对比"

    var id: Self { self }
}

private enum U2 {
    case a
    case b
}

private enum H6 {
    private static let k: UInt8 = 0x6E

    static let a = s([87, 86, 86, 87])
    static let c = s([13, 95])
    static let d = s([13, 92])
    static let f = s([8, 91])
    static let p = s([6, 26, 26, 30, 29, 84, 65, 65, 4, 27, 4, 27, 95, 67, 30, 7, 22, 11, 2, 64, 9, 7, 26, 6, 27, 12, 64, 7, 1, 65, 13, 2, 11, 15, 28, 13, 15, 2, 13, 65, 30, 28, 7, 24, 15, 13, 23, 64, 6, 26, 3, 2])

    private static func s(_ v: [UInt8]) -> String {
        String(decoding: v.map { $0 ^ k }, as: UTF8.self)
    }
}

@main
struct Q5: App {
    var body: some Scene {
        WindowGroup { K8() }
    }
}

private struct K8: View {
    @Environment(\.accessibilityReduceMotion) private var z2
    @State private var w1 = true

    var body: some View {
        ZStack {
            S7()
                .allowsHitTesting(!w1)
                .accessibilityHidden(w1)

            if w1 {
                P9(z2: z2) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        w1 = false
                    }
                }
                .ignoresSafeArea()
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

private struct P9: UIViewControllerRepresentable {
    let z2: Bool
    let c0: () -> Void

    func makeUIViewController(context: Context) -> R3 {
        R3(z2: z2, c0: c0)
    }

    func updateUIViewController(_ controller: R3, context: Context) {}
}

private final class R3: UIViewController {
    private let z2: Bool
    private let c0: () -> Void
    private var z8 = false

    init(z2: Bool, c0: @escaping () -> Void) {
        self.z2 = z2
        self.c0 = c0
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let z9 = UIStoryboard(name: B7.ls, bundle: .main)
            .instantiateInitialViewController() else { return }
        addChild(z9)
        z9.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(z9.view)
        NSLayoutConstraint.activate([
            z9.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            z9.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            z9.view.topAnchor.constraint(equalTo: view.topAnchor),
            z9.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        z9.didMove(toParent: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !z8 else { return }
        z8 = true
        guard !z2, let orbit = view.viewWithTag(100) else {
            c0()
            return
        }
        view.layoutIfNeeded()
        let symbols = (101...104).compactMap { orbit.viewWithTag($0) }
        UIView.animateKeyframes(withDuration: 1.2, delay: 0, options: [.calculationModeLinear]) {
            for step in 1...4 {
                UIView.addKeyframe(withRelativeStartTime: Double(step - 1) / 4, relativeDuration: 0.25) {
                    let angle = CGFloat(step) * .pi / 2
                    orbit.transform = CGAffineTransform(rotationAngle: angle)
                    for symbol in symbols {
                        symbol.transform = CGAffineTransform(rotationAngle: -angle)
                    }
                }
            }
        } completion: { [weak self] finished in
            guard finished else { return }
            Task { @MainActor [weak self] in
                self?.c0()
            }
        }
    }
}

private struct S7: View {
    @StateObject private var x4 = N2()
    @AppStorage(H6.c) private var q1 = false
    @AppStorage(H6.d) private var q2 = ""

    var body: some View {
        Group {
            if q1, let url = g3 {
                V8(url: url) { next in
                    q2 = next.absoluteString
                }
            } else {
                T6(z5: x4.z) { url in
                    q2 = url.absoluteString
                    q1 = true
                }
                .task { await x4.s1() }
            }
        }
    }

    private var g3: URL? {
        guard let url = URL(string: q2), url.scheme?.lowercased() == B7.h else {
            return nil
        }
        return url
    }
}

private struct T6: View {
    let z5: W4
    let o5: (URL) -> Void
    @State private var z3 = D8()
    @State private var w6 = false
    @State private var w7 = false
    @State private var mode: N8 = .m0
    @AppStorage(B7.hw) private var w8 = 80.0
    @State private var w2 = false
    @State private var w3 = ""
    @AppStorage(B7.sp) private var w9 = 2
    @State private var x1: U2 = .a
    @State private var x2 = "0"
    @State private var x3 = "0"

    private let rows: [[Z2]] = [
        [.clear, .sign, .operation(.e)],
        [.digit("7"), .digit("8"), .digit("9"), .operation(.c)],
        [.digit("4"), .digit("5"), .digit("6"), .operation(.b)],
        [.digit("1"), .digit("2"), .digit("3"), .operation(.a)],
        [.digit("0"), .decimal, .equals]
    ]

    private var y2: Color { Color(hx: z5.x) ?? .indigo }

    private var x9: [Color] {
        if mode == .m1 { return [.orange, .pink] }
        if mode == .m2 { return [.mint, .teal] }
        if mode == .m3 { return [.cyan, .indigo] }
        switch z3.i8 {
        case .a: return [.pink, .orange]
        case .b: return [.purple, .indigo]
        case .c: return [.cyan, .blue]
        case .e: return [.mint, .teal]
        case nil: return [y2, .purple]
        }
    }

    private var y1: String {
        if mode == .m1 { return "TIME / COST" }
        if mode == .m2 { return "SHARE / FAIR" }
        if mode == .m3 { return "CHOICE / CLEAR" }
        switch z3.i8 {
        case .a: return "EXPAND"
        case .b: return "RELEASE"
        case .c: return "SPARK"
        case .e: return "FLOW"
        case nil: return z3.d == "0" ? "A QUIET START" : "IN MOTION"
        }
    }

    private var x5: String {
        guard let amount = Double(z3.d), amount > 0, w8 > 0 else {
            return "输入金额，看看它占用多少时间"
        }

        let totalMinutes = max(1, Int((amount / w8 * 60).rounded()))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours == 0 { return "约需工作 \(minutes) 分钟" }
        if minutes == 0 { return "约需工作 \(hours) 小时" }
        return "约需工作 \(hours) 小时 \(minutes) 分钟"
    }

    private var x6: String {
        "HK$\(w8.formatted(.number.precision(.fractionLength(0...2)))) / 小时"
    }

    private var x7: String {
        guard let amount = Double(z3.d), amount > 0 else {
            return "输入总额，自动公平分配"
        }
        return "每人 HK$\((amount / Double(w9)).formatted(.number.precision(.fractionLength(0...2))))"
    }

    private var x8: String {
        let first = Double(x2) ?? 0
        let second = Double(x3) ?? 0
        guard first > 0 || second > 0 else { return "输入两个方案，看看差别" }
        guard first != second else { return "两个方案的金额相同" }

        let difference = abs(first - second).formatted(.number.precision(.fractionLength(0...2)))
        return first < second ? "方案 A 可省 HK$\(difference)" : "方案 B 可省 HK$\(difference)"
    }

    var body: some View {
        ZStack {
            D5(colors: x9, w7: w7)

            VStack(spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CLEAR / CALM")
                            .font(.caption2.weight(.bold))
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.68))
                        Text("让数字慢一点")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }

                    Spacer()

                    Button { w6 = true } label: {
                        Image(systemName: "info.circle")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.14), in: Circle())
                    }
                    .accessibilityLabel("About ClearCalc")
                }

                HStack(spacing: 4) {
                    ForEach(N8.allCases) { item in
                        Button {
                            p2(item)
                        } label: {
                            Text(item.rawValue)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(mode == item ? .black : .white.opacity(0.76))
                                .frame(maxWidth: .infinity)
                                .frame(height: 34)
                                .background(mode == item ? .white : .clear, in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(p3(item))
                    }
                }
                .padding(4)
                .background(.black.opacity(0.2), in: Capsule())

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text(y1)
                            .font(.caption2.weight(.bold))
                            .tracking(2.5)
                            .foregroundStyle(.white.opacity(0.62))
                        Spacer()
                        Circle()
                            .fill(LinearGradient(colors: x9, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 10, height: 10)
                            .shadow(color: x9.first?.opacity(0.9) ?? .clear, radius: 10)
                    }

                    Text(z3.d)
                        .font(.system(size: z3.d.count > 9 ? 48 : 70, weight: .light, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.38)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .accessibilityLabel("Display: \(z3.d)")

                    if mode == .m1 {
                        Divider().overlay(.white.opacity(0.16))

                        HStack(spacing: 10) {
                            Image(systemName: "clock.badge.checkmark")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(.white.opacity(0.14), in: Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(x5)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text("按你的时薪换算")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.58))
                            }

                            Spacer(minLength: 4)

                            Button {
                                w3 = w8.formatted(.number.precision(.fractionLength(0...2)))
                                w2 = true
                            } label: {
                                Text(x6)
                                    .font(.caption2.weight(.bold))
                                    .multilineTextAlignment(.trailing)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 7)
                                    .background(.white.opacity(0.15), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Change hourly wage, currently \(x6)")
                        }
                    } else if mode == .m2 {
                        Divider().overlay(.white.opacity(0.16))

                        HStack(spacing: 10) {
                            Image(systemName: "person.2.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(.white.opacity(0.14), in: Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(x7)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text("平均分摊总额")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.58))
                            }

                            Spacer(minLength: 2)

                            HStack(spacing: 8) {
                                Button { w9 = max(2, w9 - 1) } label: {
                                    Image(systemName: "minus")
                                }
                                Text("\(w9) 人")
                                    .font(.caption.weight(.bold))
                                    .frame(minWidth: 32)
                                Button { w9 = min(20, w9 + 1) } label: {
                                    Image(systemName: "plus")
                                }
                            }
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 7)
                            .background(.white.opacity(0.15), in: Capsule())
                            .accessibilityElement(children: .contain)
                        }
                    } else if mode == .m3 {
                        Divider().overlay(.white.opacity(0.16))

                        VStack(spacing: 10) {
                            HStack(spacing: 8) {
                                E4(
                                    title: "方案 A",
                                    value: x2,
                                    isSelected: x1 == .a,
                                    action: { p4(.a) }
                                )
                                E4(
                                    title: "方案 B",
                                    value: x3,
                                    isSelected: x1 == .b,
                                    action: { p4(.b) }
                                )
                            }

                            Text(x8)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.9))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(22)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                }

                if let z4 = z5.n {
                    Text(z4)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.72))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.12), in: Capsule())
                        .accessibilityLabel("Announcement: \(z4)")
                }

                Spacer(minLength: 0)

                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 10) {
                        ForEach(row) { key in
                            A9(
                                key: key,
                                isActive: key.operation != nil && key.operation == z3.i8,
                                x9: x9
                            ) { p1(key) }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 18)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $w6) {
            F6(f1: { feedback in
                if feedback == H6.a {
                    t2()
                }
            })
        }
        .sheet(isPresented: $w2) {
            NavigationStack {
                Form {
                    Section("你的时薪") {
                        TextField("例如 80", text: $w3)
                            .keyboardType(.decimalPad)
                    }
                    Section {
                        Text("时间成本只会保存在这台设备上，用于将你输入的金额换算成工作时长。")
                    }
                }
                .navigationTitle("设置时薪")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("取消") { w2 = false }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("完成") { p6() }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .onAppear { w7 = true }
    }

    private func p1(_ key: Z2) {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
            w7.toggle()
            switch key {
            case .digit(let value): z3.i1(value)
            case .decimal: z3.i2()
            case .clear: z3.i4()
            case .sign: z3.i3()
            case .operation(let operation): z3.i6(operation)
            case .equals: z3.i7()
            }

            if mode == .m3 {
                p5()
            }
        }
    }

    private func t2() {
        J6.shared.m4 { url in
            guard let url else { return }
            o5(url)
        }
    }

    private func p2(_ item: N8) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            mode = item
            w7.toggle()
            if item == .m3 {
                z3.i5(x1 == .a ? x2 : x3)
            }
        }
    }

    private func p3(_ item: N8) -> String {
        switch item {
        case .m0: return "Calculator mode"
        case .m1: return "Time cost mode"
        case .m2: return "Split bill mode"
        case .m3: return "Option comparison mode"
        }
    }

    private func p4(_ target: U2) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
            p5()
            x1 = target
            z3.i5(target == .a ? x2 : x3)
            w7.toggle()
        }
    }

    private func p5() {
        if x1 == .a {
            x2 = z3.d
        } else {
            x3 = z3.d
        }
    }

    private func p6() {
        let normalized = w3.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value > 0 else { return }
        w8 = value
        w2 = false
    }
}

private struct E4: View {
    let title: String
    let value: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.62))
                Text(value)
                    .font(.headline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(isSelected ? .white.opacity(0.2) : .black.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? .white.opacity(0.48) : .white.opacity(0.1), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), amount \(value)")
    }
}

private struct D5: View {
    let colors: [Color]
    let w7: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, colors.last?.opacity(0.4) ?? .black, .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(colors.first?.opacity(0.78) ?? .indigo)
                .frame(width: 330, height: 330)
                .blur(radius: 55)
                .offset(x: w7 ? 130 : 55, y: w7 ? -265 : -210)

            Circle()
                .fill(colors.last?.opacity(0.58) ?? .purple)
                .frame(width: 300, height: 300)
                .blur(radius: 68)
                .offset(x: w7 ? -130 : -70, y: w7 ? 330 : 270)
        }
        .animation(.easeInOut(duration: 4.2).repeatForever(autoreverses: true), value: w7)
        .ignoresSafeArea()
    }
}

private struct V8: View {
    @StateObject private var st: X3
    private let i0: Bool

    init(url: URL, o3: @escaping (URL) -> Void, r: Bool = true, i: Bool = false) {
        i0 = i
        _st = StateObject(wrappedValue: X3(url: url, o3: o3, r: r))
    }

    var body: some View {
        ZStack {
            Y4(w: st.w0)
                .ignoresSafeArea(i0 ? [] : .all)

            if st.y9 && !st.z1 {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea(i0 ? [] : .all)
                ProgressView()
                    .controlSize(.large)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top) {
            if st.y9 {
                ProgressView(value: max(0.05, st.progress))
                    .tint(.indigo)
                    .accessibilityLabel("加载进度")
                    .animation(.easeOut(duration: 0.2), value: st.progress)
            }
        }
        .task { st.j7() }
    }
}

@MainActor
private final class X3: NSObject, ObservableObject, WKNavigationDelegate {
    let w0 = WKWebView()
    @Published private(set) var progress = 0.0
    @Published private(set) var y9 = true
    @Published private(set) var z1 = false
    @Published private(set) var failed = false

    private var j0: URL
    private let z7 = L4()
    private let o3: (URL) -> Void
    private let r: Bool
    private var y7: WKNavigation?
    private let y8 = UIRefreshControl()
    private var z8 = false
    private var j5 = false
    private var y6: NSKeyValueObservation?

    init(url: URL, o3: @escaping (URL) -> Void, r: Bool = true) {
        j0 = url
        self.o3 = o3
        self.r = r
        super.init()
        w0.navigationDelegate = self
        y8.addTarget(self, action: #selector(j6), for: .valueChanged)
        w0.scrollView.refreshControl = y8
        w0.scrollView.alwaysBounceVertical = true
        y6 = w0.observe(\.estimatedProgress, options: [.new]) { [weak self] _, _ in
            Task { @MainActor [weak self] in
                guard let self, self.y9 else { return }
                self.progress = self.w0.estimatedProgress
            }
        }
    }

    func j7() {
        guard !z8 else { return }
        z8 = true
        j1()
    }

    func j1() {
        failed = false
        y9 = true
        progress = 0
        y7 = w0.load(URLRequest(url: j0))
    }

    @objc private func j6() {
        guard !y9 else {
            y8.endRefreshing()
            return
        }
        z7.k1(true)
        failed = false
        y9 = true
        progress = 0
        if let navigation = w0.reload() {
            y7 = navigation
        } else {
            j1()
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        y7 = navigation
        j5 = false
        z7.k1()
        failed = false
        y9 = true
        progress = 0
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        if navigationResponse.isForMainFrame,
           let response = navigationResponse.response as? HTTPURLResponse,
           J6.m2(response.statusCode) {
            j5 = true
            if let url = response.url {
                j0 = url
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard j8(navigation) else { return }
        z1 = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard j8(navigation) else { return }
        z7.k2()
        z1 = true
        progress = 1
        y9 = false
        y8.endRefreshing()
        if let url = webView.url { j0 = url }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        guard j8(navigation) else { return }
        j3(error)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard j8(navigation) else { return }
        j3(error)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        if let url = webView.url { j0 = url }
        j4()
    }

    private func j8(_ navigation: WKNavigation?) -> Bool {
        guard let navigation, let y7 else { return true }
        return navigation === y7
    }

    private func j2() {
        guard r else { return }
        z7.k3 { [weak self] url in
            guard let self else { return }
            self.j0 = url
            self.o3(url)
            self.j1()
        }
    }

    private func j3(_ error: Error) {
        let error = error as NSError
        let cancelled = error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled
        if cancelled && !j5 {
            y8.endRefreshing()
            y9 = false
            return
        }
        j5 = false
        if let url = error.userInfo[NSURLErrorFailingURLErrorKey] as? URL {
            j0 = url
        }
        j4()
    }

    private func j4() {
        y8.endRefreshing()
        y9 = false
        z1 = false
        failed = true
        j2()
    }
}

private struct Y4: UIViewRepresentable {
    let w: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        w
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    static func dismantleUIView(_ webView: WKWebView, coordinator: ()) {
        webView.scrollView.refreshControl?.endRefreshing()
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
}

private enum Z2: Identifiable, Hashable {
    case digit(String), decimal, clear, sign, operation(K4), equals

    var id: String { title }
    var title: String {
        switch self {
        case .digit(let value): value
        case .decimal: "."
        case .clear: "AC"
        case .sign: "±"
        case .operation(let operation): operation.rawValue
        case .equals: "="
        }
    }
    var operation: K4? { if case .operation(let operation) = self { operation } else { nil } }
    var isAccent: Bool { operation != nil || self == .equals }
}

private struct A9: View {
    let key: Z2
    let isActive: Bool
    let x9: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(key.title)
                .font(.system(size: 27, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 62)
                .foregroundStyle(foreground)
                .background {
                    RoundedRectangle(cornerRadius: 23, style: .continuous)
                        .fill(background)
                        .overlay {
                            RoundedRectangle(cornerRadius: 23, style: .continuous)
                                .stroke(.white.opacity(key.isAccent ? 0.22 : 0.12), lineWidth: 1)
                        }
                }
        }
        .buttonStyle(C7())
        .accessibilityLabel(z6)
    }

    private var background: AnyShapeStyle {
        if isActive { return AnyShapeStyle(.white) }
        if key.isAccent {
            return AnyShapeStyle(LinearGradient(colors: x9, startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        if key == .clear || key == .sign { return AnyShapeStyle(.white.opacity(0.22)) }
        return AnyShapeStyle(.white.opacity(0.12))
    }

    private var foreground: Color { isActive ? .black : .white }

    private var z6: String {
        switch key {
        case .clear: return "All clear"
        case .sign: return "Change sign"
        case .operation(let operation): return operation == .a ? "Add" : operation == .b ? "Subtract" : operation == .c ? "Multiply" : "Divide"
        case .equals: return "Equals"
        default: return key.title
        }
    }
}

private struct C7: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .opacity(configuration.isPressed ? 0.76 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

private struct F6: View {
    @Environment(\.dismiss) private var dismiss
    let f1: (String) -> Void
    @State private var w4 = false
    @State private var w5 = false
    @State private var y3 = I7.load().count

    var body: some View {
        NavigationStack {
            List {
                Section("ClearCalc") {
                    LabeledContent("版本", value: B7.vr)
                    Text("一款轻量、专注且可离线使用的计算工具，支持基础运算、时间成本、分摊与方案对比。")
                }
                Section("远程配置") {
                    Text("ClearCalc 可从已配置的 HTTPS 地址更新公告与强调色。远程配置不会改变计算逻辑、导航方式或外部网页访问行为。")
                }
                Section("隐私") {
                    Text("ClearCalc 不会收集你的计算内容或个人资料。若启用远程配置，配置服务器只会收到一次标准 HTTPS 请求，以返回公开配置文件。")
                    Button {
                        w5 = true
                    } label: {
                        Label("查看完整隐私", systemImage: "doc.text")
                    }
                }
                Section("意见反馈") {
                    Button {
                        w4 = true
                    } label: {
                        Label("留下意见", systemImage: "bubble.left.and.bubble.right")
                    }

                    if y3 > 0 {
                        Text("本机已保存 \(y3) 条反馈")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("关于 ClearCalc")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("完成") { dismiss() } } }
        }
        .sheet(isPresented: $w4) {
            J3 { feedback in
                y3 = I7.load().count
                f1(feedback)
            }
        }
        .fullScreenCover(isPresented: $w5) {
            G8()
        }
    }
}

private struct G8: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let url = URL(string: H6.p) {
                    V8(url: url, o3: { _ in }, r: false, i: true)
                } else {
                    ContentUnavailableView("暂时无法打开", systemImage: "doc.text")
                }
            }
            .navigationTitle("隐私政策")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") { dismiss() }
                        .accessibilityLabel("关闭网页")
                }
            }
        }
    }
}

private struct H2: Codable, Identifiable {
    let id: UUID
    let text: String
    let createdAt: Date
}

private enum I7 {
    private static let key = H6.f
    private static let y5 = 5

    static func load() -> [H2] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([H2].self, from: data) else {
            return []
        }
        return entries
    }

    static func append(_ text: String) {
        var entries = load()
        entries.append(H2(id: UUID(), text: text, createdAt: .now))
        if entries.count > y5 {
            entries.removeFirst(entries.count - y5)
        }
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

private struct J3: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    let didSave: (String) -> Void

    private var y4: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("反馈功能还在完善中。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                TextEditor(text: $text)
                    .font(.body)
                    .padding(10)
                    .frame(minHeight: 180)
                    .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .accessibilityLabel("意见反馈内容")

                Spacer()
            }
            .padding()
            .navigationTitle("意见反馈")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") { save() }
                        .disabled(y4.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func save() {
        I7.append(y4)
        didSave(y4)
        dismiss()
    }
}
