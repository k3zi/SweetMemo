import Foundation

struct OptimumFactorMatrix {

    static let initialRepValue: Double = 1

    static func afFromIndex(a: Int) -> Double {
        Double(a) * SweetMemo.notchAF + SweetMemo.minAF
    }

    static func repFromIndex(r: Double) -> Double {
        r + Self.initialRepValue
    }

    let sm: SweetMemo
    private var ofm: ((Int) -> PointModel)? = nil
    private var ofm0: ((Int) -> Double)? = nil

    init(sm: SweetMemo) {
        self.sm = sm
        self.update()
    }

    func rFactor(repetition: Int, afIndex: Int) -> Double {
        sm.forgettingCurves.curves[repetition][afIndex].uf(retention: 100 - sm.requestedFI)
    }

    mutating func update() {
        var dfs: [Double] = (0...SweetMemo.rangeAF).map { a in
            SweetMemo.fixedPointPowerLawRegression(points: (1...SweetMemo.rangeRepetition).map { r in
                Point(x: Self.repFromIndex(r: Double(r)), y: sm.rfm.rFactor(repetition: r, afIndex: a))
            }, fixedPoint: Point(x: Self.repFromIndex(r: 1), y: Self.afFromIndex(a: a))).b
        }
        dfs = (0...SweetMemo.rangeAF).map { Self.afFromIndex(a: $0) / pow(2, dfs[$0]) }
        let decay = SweetMemo.linearRegression(points: (0...SweetMemo.rangeAF).map { Point(x: Double($0), y: dfs[$0]) })
        self.ofm = { a in
            let af = Self.afFromIndex(a: a)
            let b = log(af / decay.y(Double(a))) / log(Self.repFromIndex(r: 1))
            let model = SweetMemo.powerLawModel(a: af / pow(Self.repFromIndex(r: 1), b), b: b)
            return .init(
                x: { model.x($0) - Self.initialRepValue },
                y: { model.y(Self.repFromIndex(r: $0)) }
            )
        }

        let ofm0 = SweetMemo.exponentialRegression(points: (0...SweetMemo.rangeAF).map { Point(x: Double($0), y: sm.rfm.rFactor(repetition: 0, afIndex: $0)) })
        self.ofm0 = { ofm0.y(Double($0)) }
    }

    func of(repetition: Int, afIndex: Int) -> Double {
        repetition == 0
            ? ofm0!(afIndex)
            : ofm!(afIndex).y(Double(repetition))
    }

    func af(repetition: Int, of of_: Double) -> Double {
        Double(Self.afFromIndex(a: (0...SweetMemo.rangeAF).reduce(0, { a, b -> Int in
            abs(of(repetition: repetition, afIndex: a) - of_) < abs(of(repetition: repetition, afIndex: b) - of_)
                ? a
                : b
        })))
    }

}
