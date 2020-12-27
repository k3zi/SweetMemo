import Foundation

struct ForgettingCurve {

    static let maxPointsCount = 500

    var points: [Point]
    var graph: Graph?

    mutating func registerPoint(grade: Double, uf: Double) {
        let isRemembered = grade >= SweetMemo.thresholdRecall
        points.append(Point(x: uf, y: isRemembered ? ForgettingCurves.remembered : ForgettingCurves.forgotten))
        points = points.suffix(Self.maxPointsCount)
        graph = nil
    }

    mutating func retention(uf: Double) -> Double {
        let graph = self.graph ?? SweetMemo.exponentialRegression(points: points)
        self.graph = graph
        return max(ForgettingCurves.forgotten, min(graph.y(uf), ForgettingCurves.remembered)) - ForgettingCurves.forgotten
    }

    mutating func uf(retention: Double) -> Double {
        let graph = self.graph ?? SweetMemo.exponentialRegression(points: points)
        self.graph = graph
        return max(0, graph.x(retention + ForgettingCurves.forgotten))
    }

}
