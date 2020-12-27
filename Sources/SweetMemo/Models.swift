import Foundation

struct Graph {

    let y: (Double) -> Double
    let x: (Double) -> Double
    let a: Double
    let b: Double
    let mse: Double

}

struct Model {

    let y: (Double) -> Double
    let x: (Double) -> Double
    let a: Double
    let b: Double

}

struct LRResult {

    let y: (Double) -> Double
    let x: (Double) -> Double
    let b: Double

}

struct Point {
    let x: Double
    let y: Double
}

struct PointModel {
    let x: (Double) -> Double
    let y: (Double) -> Double
}

extension SweetMemo {

    static func mse(y: (Double) -> Double, points: [Point]) -> Double {
        let sum = points
            .map { y($0.x) - $0.y }
            .map { $0 * $0 }
            .reduce(0, +)
        return sum / Double(points.count)
    }

    static func exponentialRegression(points: [Point]) -> Graph {
        let n = Double(points.count)
        let X = points.map { $0.x }
        let Y = points.map { $0.y }
        let logY = Y.map { log($0) }
        let sqX = X.map { $0 * $0 }

        let sumLogY = logY.reduce(0, +)
        let sumSqX = sqX.reduce(0, +)
        let sumX = X.reduce(0, +)
        let sumXLogY = zip(X, logY).map(*).reduce(0, +)
        let sqSumX = sumX * sumX

        let a = (sumLogY * sumSqX - sumX * sumXLogY) / (n * sumSqX - sqSumX)
        let b = (n * sumXLogY - sumX * sumLogY) / (n * sumSqX - sqSumX)
        let _y: (Double) -> Double = { exp(a) * exp(b * $0)  }
        return Graph(
            y: _y,
            x: { (-a + log($0)) / b },
            a: exp(a),
            b: b,
            mse: mse(y: _y, points: points)
        )
    }

    static func linearRegression(points: [Point]) -> Model {
        let n = Double(points.count)
        let X = points.map { $0.x }
        let Y = points.map { $0.y }
        let sqX = X.map { $0 * $0 }

        let sumY = Y.reduce(0, +)
        let sumSqX = sqX.reduce(0, +)
        let sumX = X.reduce(0, +)
        let sumXY = zip(X, Y).map(*).reduce(0, +)
        let sqSumX = sumX * sumX

        let a = (sumY * sumSqX - sumX * sumXY) / (n * sumSqX - sqSumX)
        let b = (n * sumXY - sumX * sumY) / (n * sumSqX - sqSumX)
        let _y: (Double) -> Double = { a + b * $0 }
        return Model(
            y: _y,
            x: { ($0 - a) / b },
            a: a,
            b: b
        )
    }

    static func fixedPointPowerLawRegression(points: [Point], fixedPoint: Point) -> Model {
        let p = fixedPoint.x
        let q = fixedPoint.y
        let logQ = log(q)
        let X = points.map { log($0.x / p) }
        let Y = points.map { log($0.y) - logQ }
        let b = linearRegressionThroughOrigin(points: zip(X, Y).map { Point(x: $0, y: $1) }).b
        return powerLawModel(a: q / pow(p, b), b: b)
    }

    static func linearRegressionThroughOrigin(points: [Point]) -> LRResult {
        let X = points.map { $0.x }
        let Y = points.map { $0.y }

        let sumXY = zip(X, Y).map(*).reduce(0, +)
        let sumSqX = zip(X, X).map(*).reduce(0, +)
        let b = sumXY / sumSqX
        return .init(
            y: { b * $0 },
            x: { $0 / b },
            b: b
        )
    }

    static func powerLawModel(a: Double, b: Double) -> Model {
        return .init(
            y: { a * pow($0, b) },
            x: { pow($0 / a, 1 / b) },
            a: a,
            b: b
        )
    }

}
