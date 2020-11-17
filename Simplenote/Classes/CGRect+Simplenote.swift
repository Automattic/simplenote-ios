import Foundation


// MARK: - CGRect Methods
//
extension CGRect {

    /// Returns the resulting Rectangles by splitting the receiver in two, by the specified Rectangle's **minY** and **maxY**
    ///
    /// - Note: We rely on this API to determine the available editing area above and below the cursor
    /// - Important: **For simplicity's sake** we won't return an optional. If the parameters are invalid, we'll just pass along the "non split receiver"
    ///
    func split(by rect: CGRect) -> (upperSlice: CGRect, lowerSlice: CGRect) {
        guard contains(rect) else {
            return (.zero, self)
        }

        var lowerSlice = self
        lowerSlice.size.height = rect.minY - minY

        var upperSlice = self
        upperSlice.origin.y = rect.maxY
        upperSlice.size.height = height - lowerSlice.height - rect.height

        return (upperSlice, lowerSlice)
    }
}
