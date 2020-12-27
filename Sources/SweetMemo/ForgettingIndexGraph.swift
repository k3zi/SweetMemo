import Foundation

struct ForgettingIndexGraph {

    static let maxPoints = 5000
    static let gradeOffset: Double = 1

    let sm: SweetMemo
    var points: [Point]
    var graph: Graph?

    init(sm: SweetMemo, points: [Point]? = nil) {
        self.sm = sm
        if let points = points {
            self.points = points
        } else {
            self.points = []
            registerPoint(fi: .zero, g: SweetMemo.maxGrade)
            registerPoint(fi: 100, g: .zero)
        }
    }

    mutating func registerPoint(fi: Double, g: Double) {
        points.append(Point(x: fi, y: g))
        points = points.suffix(Self.maxPoints)
    }

    mutating func update(grade: Double, item: Item, now: Date = .init()) {
        let expectedFI = (item.uf(now: now) / item.of) * sm.requestedFI
        registerPoint(fi: expectedFI, g: grade)
        graph = nil
    }

    mutating func forgettingIndex(grade: Double) -> Double {
        graph = graph ?? SweetMemo.exponentialRegression(points: points)
        return max(0, min(100, graph?.x(grade + Self.gradeOffset) ?? 0))
    }

    mutating func grade(forgettingIndex fi: Double) -> Double {
        graph = graph ?? SweetMemo.exponentialRegression(points: points)
        return (graph?.y(fi) ?? 0) - Self.gradeOffset
    }

}
