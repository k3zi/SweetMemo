import Foundation

struct RFactorMatrix {

    let sm: SweetMemo

    func rFactor(repetition: Int, afIndex: Int) -> Double {
        sm.forgettingCurves.curves[repetition][afIndex].uf(retention: 100 - sm.requestedFI)
    }

}
