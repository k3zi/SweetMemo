import Foundation

extension ClosedRange where Bound: Strideable, Bound.Stride: SignedInteger {

    // Assumes that the slice will not be empty. ClosedRange must have at least
    // one element.
    init(_ slice: Slice<ClosedRange<Bound>>) {
        self.init(uncheckedBounds: (slice.first!, slice.last!))
    }

}
