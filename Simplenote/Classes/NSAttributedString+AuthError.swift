import Foundation

// MARK: - NSAttributedString + AuthError Helpers
//
extension NSAttributedString {

    /// Returns an Attributed String that translates a Networking Error into human friendly text.
    ///
    /// - Parameters:
    ///     - statusCode: Response Status Code
    ///     - response: Response Body (Text)
    ///     - error: Request Error, if any
    ///
    /// - Returns: An Attributed String describing a Networking Error
    ///
    class func stringFromNetworkError(statusCode: Int, response: String?, error: Error?) -> NSAttributedString {
        let statusTitle = NSAttributedString(string: Title.statusCode, attributes: Style.title)
        let statusText = NSAttributedString(string: statusCode.description, attributes: Style.title)

        let output = NSMutableAttributedString()
        output.append(statusTitle)
        output.append(string: .space)
        output.append(statusText)

        if let error = error {
            let title = NSAttributedString(string: Title.error, attributes: Style.title)
            let text = NSAttributedString(string: error.localizedDescription, attributes: Style.text)

            output.append(string: .newline)
            output.append(string: .newline)
            output.append(title)
            output.append(string: .newline)
            output.append(text)
        }

        if let response = response {
            let title = NSAttributedString(string: Title.response, attributes: Style.title)
            let text = NSAttributedString(string: response, attributes: Style.text)

            output.append(string: .newline)
            output.append(string: .newline)
            output.append(title)
            output.append(string: .newline)
            output.append(text)
        }

        return output
    }
}

// MARK: - Diagnostic Title(s)
//
private enum Title {
    static let statusCode   = NSLocalizedString("Status Code", comment: "Title for the response's Status Code")
    static let error        = NSLocalizedString("Error", comment: "Error Title")
    static let response     = NSLocalizedString("Response", comment: "Response Title")
}

// MARK: - Text Styles
//
private enum Style {
    static let title: [NSAttributedString.Key: Any] = [
        .font: UIFont.preferredFont(for: .title3, weight: .semibold)
    ]

    static let text: [NSAttributedString.Key: Any] = [
        .font: UIFont.preferredFont(for: .body, weight: .regular)
    ]
}
