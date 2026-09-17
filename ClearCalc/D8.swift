import Foundation

enum K4: String {
    case a = "+"
    case b = "−"
    case c = "×"
    case e = "÷"
}

struct D8 {
    private(set) var d = "0"
    private var s: Decimal?
    private var o: K4?
    private var n = true

    mutating func i1(_ digit: String) {
        guard digit.count == 1, digit.first?.isNumber == true else { return }
        if d == B7.er || n {
            d = digit
            n = false
        } else if d == "0" {
            d = digit
        } else if d.replacingOccurrences(of: ".", with: "").count < 12 {
            d.append(digit)
        }
    }

    mutating func i2() {
        if d == B7.er || n {
            d = "0."
            n = false
        } else if !d.contains(".") {
            d.append(".")
        }
    }

    mutating func i3() {
        guard d != "0", d != B7.er else { return }
        d = d.hasPrefix("-") ? String(d.dropFirst()) : "-" + d
    }

    mutating func i4() {
        d = "0"
        s = nil
        o = nil
        n = true
    }

    mutating func i5(_ value: String) {
        d = Decimal(string: value, locale: Locale(identifier: B7.lc)) == nil ? "0" : value
        s = nil
        o = nil
        n = true
    }

    mutating func i6(_ operation: K4) {
        guard let current = p else { i4(); return }
        if let o, let s, !n {
            guard let result = i9(o, s, current) else { d = B7.er; self.s = nil; self.o = nil; n = true; return }
            d = i0(result)
            self.s = result
        } else {
            self.s = current
        }
        self.o = operation
        n = true
    }

    mutating func i7() {
        guard let o, let initial = s, let current = p else { return }
        guard let result = i9(o, initial, current) else { d = B7.er; s = nil; self.o = nil; n = true; return }
        d = i0(result)
        s = nil
        self.o = nil
        n = true
    }

    var i8: K4? { o }

    private var p: Decimal? { Decimal(string: d, locale: Locale(identifier: B7.lc)) }

    private func i9(_ operation: K4, _ lhs: Decimal, _ rhs: Decimal) -> Decimal? {
        switch operation {
        case .a: return lhs + rhs
        case .b: return lhs - rhs
        case .c: return lhs * rhs
        case .e:
            guard rhs != 0 else { return nil }
            return lhs / rhs
        }
    }

    private func i0(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: B7.lc)
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 10
        formatter.minimumFractionDigits = 0
        return formatter.string(from: value as NSDecimalNumber) ?? B7.er
    }
}
