import Foundation

struct ForgettingCurves {

    static let forgotten: Double = 1
    static let remembered: Double = 100 + forgotten

    var curves: [[ForgettingCurve]]

    init(sm: SweetMemo, points: [[Point]]? = nil) {
        curves = (0...SweetMemo.rangeRepetition).map { (r: Int) -> [ForgettingCurve] in
            (0...SweetMemo.rangeAF).map { (a: Int) -> ForgettingCurve in
                let dr = Double(r)
                let da = Double(a)
                let partialPoints: [Point]
                if let points = points {
                    partialPoints = [points[r][a]]
                } else {
                    let p: [Point]
                    if r > 0 {
                        p = (0..<20).map { i -> Point in
                            Point(
                                x: SweetMemo.minAF + SweetMemo.notchAF * Double(i),
                                y: min(
                                    Self.remembered,
                                    exp(
                                        (-(dr + 1) / 200) * (Double(i) - da * (2 / (dr + 1).squareRoot()))
                                    ) * (Self.remembered - sm.requestedFI)
                                )
                            )
                        }
                    } else {
                        p = (0..<20).map { i -> Point in
                            Point(
                                x: SweetMemo.minAF + SweetMemo.notchAF * Double(i),
                                y: min(
                                    Self.remembered,
                                    exp(
                                        (-1 / (10 + 1 * (da + 1))) * (Double(i) - pow(da, 0.6))
                                    ) * (Self.remembered - sm.requestedFI)
                                )
                            )
                        }
                    }
                    partialPoints = [Point(x: 0, y: Self.remembered)] + p
                }
                return ForgettingCurve(points: partialPoints)
            }
        }
    }

    mutating func registerPoint(grade: Double, item: inout Item, now: Date = .init()) {
        let afIndex = item.repetition > 0 ? item.afIndex() : item.lapse
        curves[item.repetition][afIndex].registerPoint(grade: grade, uf: item.uf(now: now))
    }

}
