import Foundation

struct Item {

    static let maxAFsCount = 30

    let sm: SweetMemo
    let value: String

    var lapse = 0
    var repetition = -1
    var of: Double = 1
    var optimumInterval: Double
    var dueDate = Date()
    var previousDate: Date?
    private var af: Double?
    private var afs = [Double]()

    init(sm: SweetMemo, value: String) {
        self.sm = sm
        self.value = value
        self.optimumInterval = sm.intervalBase
    }

    func interval(now: Date = .init()) -> TimeInterval {
        guard let previousDate = previousDate else {
            return sm.intervalBase
        }

        return now.timeIntervalSince(previousDate)
    }

    func uf(now: Date = .init()) -> Double {
        interval(now: now) / (optimumInterval / of)
    }

    mutating func af(value: Double? = nil) -> Double {
        guard let value = value else {
            // Is af ever nil in usage?
            return af ?? SweetMemo.minAF
        }

        let a = round((value - SweetMemo.minAF) / SweetMemo.notchAF)
        af = max(SweetMemo.minAF, min(SweetMemo.maxAF, SweetMemo.minAF + a * SweetMemo.notchAF))
        return af!
    }

    mutating func afIndex() -> Int {
        let afs = (0...SweetMemo.rangeAF).map { SweetMemo.minAF + Double($0) * SweetMemo.notchAF }
        return (0...SweetMemo.rangeAF).reduce(0, { a, b in
            abs(af() - afs[a]) < abs(af() - afs[b]) ? a : b
        })
    }

    private mutating func I(now: Date = .init()) {
        let of = sm.ofm.of(repetition: repetition, afIndex: repetition == 0 ? lapse : afIndex())
        self.of = max(1, (of - 1) * (interval(now: now) / optimumInterval) + 1)
        optimumInterval = round(optimumInterval * self.of)

        previousDate = now
        dueDate = Date(timeIntervalSinceNow: optimumInterval)
    }

    private mutating func updateAF(grade: Double, now: Date = .init()) {
        let estimatedFI = max(1, sm.forgettingIndexGraph.forgettingIndex(grade: grade))
        let correctedUF = uf(now: now) * (sm.requestedFI / estimatedFI)
        let estimatedAF = repetition > 0
            ? sm.ofm.af(repetition: repetition, of: correctedUF)
            : max(SweetMemo.minAF, min(SweetMemo.maxAF, correctedUF))

        afs.append(estimatedAF)
        afs = afs.suffix(Self.maxAFsCount)
        let x = afs.enumerated().map { i, a in a * (Double(i) + 1) }.reduce(0, +)
        let y = (1..<afs.count).reduce(0, +)
        _ = af(value: x / Double(y))
    }

    mutating func answer(grade: Double, now: Date = .init()) {
        if repetition >= 0 {
            updateAF(grade: grade, now: now)
        }

        if grade >= SweetMemo.thresholdRecall {
            if repetition < (SweetMemo.rangeRepetition - 1) {
                repetition += 1
            }
            I(now: now)
        } else {
            if lapse < (SweetMemo.rangeAF - 1) {
                lapse += 1
            }
            optimumInterval = sm.intervalBase
            previousDate = nil
            dueDate = now
            repetition = -1
        }
    }

}

