import Foundation

extension SPModalActivityIndicator {
    // Swift is automatically creating an async version of this function for us, but then it is failing to build
    // If you use the completion handler version of this method it complains.
    // So you can't use the async version and you can't use the completion handler version... rock meet hard place
    // This method is here to handle that issue
    func dismiss(_ animated: Bool) async {
        // Wrapping the dismiss in an anonymous closure silences the completion handler warning.
        { dismiss(animated, completion: nil) }()
    }
}
