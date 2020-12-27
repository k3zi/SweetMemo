import Foundation

class SweetMemo {

    static let rangeAF: Int = 20
    static let rangeRepetition: Int = 20

    static let minAF: Double = 1.2
    static let notchAF: Double = 0.3
    static let maxAF = minAF + notchAF * (Double(rangeAF) - 1)

    static let maxGrade: Double = 5
    static let thresholdRecall: Double = 3

    let requestedFI: Double = 10
    let intervalBase: Double = 3 * 60 * 60 * 1000
    lazy var forgettingIndexGraph = ForgettingIndexGraph(sm: self)
    lazy var forgettingCurves = ForgettingCurves(sm: self)
    lazy var rfm = RFactorMatrix(sm: self)
    lazy var ofm = OptimumFactorMatrix(sm: self)

    var queue: [Item]

    init() {
        queue = []
    }

    private func findIndexToInsert(item: Item, range: ClosedRange<Int>? = nil) -> Int {
        // Binary insert
        let r = range ?? (0...queue.count)
        if r.count == 0 {
            return 0
        }
        let v = item.dueDate
        let i = r.count / 2
        let ri = r.index(r.startIndex, offsetBy: i)
        if r.count == 1 {
            return v < queue[r[ri]].dueDate ? r[ri] : (r[ri] + 1)
        }

        return findIndexToInsert(item: item, range: ClosedRange(v < queue[r[ri]].dueDate ? r[...ri] : r[ri...]))
    }

    public func addItem(value: String) {
        let item = Item(sm: self, value: value)
        queue.insert(item, at: findIndexToInsert(item: item))
    }

    public func nextItem(isAdvanceable: Bool = false) -> Item? {
        guard queue.count > 0 else { return nil }
        let first = queue[0]
        return (isAdvanceable || first.dueDate < Date()) ? first : nil
    }

    public func answer(grade: Double, item: inout Item, now: Date = .init()) {
        update(grade: grade, item: &item, now: now)
    }

    private func update(grade: Double, item: inout Item, now: Date = .init()) {
        if item.repetition > 0 {
            forgettingCurves.registerPoint(grade: grade, item: &item, now: now)
            ofm.update()
            forgettingIndexGraph.update(grade: grade, item: item, now: now)
        }
        item.answer(grade: grade, now: now)
    }

}
