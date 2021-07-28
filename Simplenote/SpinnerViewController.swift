import UIKit

class SpinnerViewController: UIViewController {
    private var alertView: UIView!
    private var activityIndicator: UIActivityIndicatorView!

    init() {
        super.init(nibName: nil, bundle: nil)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        setupViewLayout()
        setupViewAppearance()
    }

    private func setupViewLayout() {
        alertView = UIView(frame: .zero)
        activityIndicator = UIActivityIndicatorView(frame: .zero)
        alertView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(alertView)

        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.widthAnchor.constraint(equalToConstant: 150),
            alertView.heightAnchor.constraint(equalToConstant: 115)
        ])
        alertView.layer.cornerRadius = 15


        alertView.addSubview(activityIndicator)
        alertView.sizeToFit()
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: alertView.centerYAnchor),
        ])
    }

    private func setupViewAppearance() {
        modalPresentationStyle = .overFullScreen

        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            activityIndicator.style = .gray
        }

        view.backgroundColor = UIColor(studioColor: .gray50, alpha: UIKitConstants.alpha0_5)
        alertView.backgroundColor = UIColor(studioColor: .white, alpha: UIKitConstants.alpha1_0)
        activityIndicator.color = .black
    }

    func startAnimating() {
        activityIndicator.startAnimating()
    }

    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}
