import Foundation


// MARK: - CGRect Methods
//
extension CGRect {

    /// Returns the resulting Rectangles by splitting the receiver in two, by the specified Rectangle's **minY** and **maxY**
    ///
    /// - Note: We rely on this API to determine the available editing area above and below the cursor
    /// - Important: **For simplicity's sake** we won't return an optional. If the parameters are invalid, we'll just pass along the "non split receiver"
    ///
    func split(by rect: CGRect) -> (aboveSlice: CGRect, belowSlice: CGRect) {
        guard contains(rect) else {
            return (.zero, self)
        }

        var belowSlice = self
        belowSlice.size.height = rect.minY - minY

        var aboveSlice = self
        aboveSlice.origin.y = rect.maxY
        aboveSlice.size.height = maxY - rect.maxY

        return (aboveSlice, belowSlice)
    }
}
