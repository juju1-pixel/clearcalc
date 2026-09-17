import Foundation

enum O4: String {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"
}

struct P2 {
    private(set) var display = "0"
    private var storedValue: Decimal?
    private var pendingOperation: O4?
    private var startsNewNumber = true

    mutating func inputDigit(_ digit: String) {
        guard digit.count == 1, digit.first?.isNumber == true else { return }
        if display == "Error" || startsNewNumber {
            display = digit
            startsNewNumber = false
        } else if display == "0" {
            display = digit
        } else if display.replacingOccurrences(of: ".", with: "").count < 12 {
            display.append(digit)
        }
    }

    mutating func inputDecimal() {
        if display == "Error" || startsNewNumber {
            display = "0."
            startsNewNumber = false
        } else if !display.contains(".") {
            display.append(".")
        }
    }

    mutating func toggleSign() {
        guard display != "0", display != "Error" else { return }
        display = display.hasPrefix("-") ? String(display.dropFirst()) : "-" + display
    }

    mutating func clear() {
        display = "0"
        storedValue = nil
        pendingOperation = nil
        startsNewNumber = true
    }

    mutating func replaceDisplay(_ value: String) {
        display = Decimal(string: value, locale: Locale(identifier: "en_US_POSIX")) == nil ? "0" : value
        storedValue = nil
        pendingOperation = nil
        startsNewNumber = true
    }

    mutating func choose(_ operation: O4) {
        guard let currentValue = decimalValue else { clear(); return }
        if let pendingOperation, let storedValue, !startsNewNumber {
            guard let result = apply(pendingOperation, to: storedValue, and: currentValue) else { display = "Error"; self.storedValue = nil; self.pendingOperation = nil; startsNewNumber = true; return }
            display = formatted(result)
            self.storedValue = result
        } else {
            storedValue = currentValue
        }
        pendingOperation = operation
        startsNewNumber = true
    }

    mutating func equals() {
        guard let operation = pendingOperation, let initialValue = storedValue, let currentValue = decimalValue else { return }
        guard let result = apply(operation, to: initialValue, and: currentValue) else { display = "Error"; storedValue = nil; pendingOperation = nil; startsNewNumber = true; return }
        display = formatted(result)
        storedValue = nil
        pendingOperation = nil
        startsNewNumber = true
    }

    var activeOperation: O4? { pendingOperation }

    private var decimalValue: Decimal? { Decimal(string: display, locale: Locale(identifier: "en_US_POSIX")) }

    private func apply(_ operation: O4, to lhs: Decimal, and rhs: Decimal) -> Decimal? {
        switch operation {
        case .add: return lhs + rhs
        case .subtract: return lhs - rhs
        case .multiply: return lhs * rhs
        case .divide:
            guard rhs != 0 else { return nil }
            return lhs / rhs
        }
    }

    private func formatted(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 10
        formatter.minimumFractionDigits = 0
        return formatter.string(from: value as NSDecimalNumber) ?? "Error"
    }
}
