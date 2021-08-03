import UIKit

class SpinnerViewController: UIViewController {
    private var alertView = UIView()
    private var activityIndicator = UIActivityIndicatorView()

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
            alertView.widthAnchor.constraint(equalToConstant: Constants.width),
            alertView.heightAnchor.constraint(equalToConstant: Constants.height)
        ])
        alertView.layer.cornerRadius = Constants.cornerRadius


        alertView.addSubview(activityIndicator)
        alertView.sizeToFit()
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: alertView.centerYAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.startAnimating()
    }

    override func viewDidDisappear(_ animated: Bool) {
        activityIndicator.stopAnimating()
    }


    private func setupViewAppearance() {
        modalPresentationStyle = .overFullScreen

        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            activityIndicator.style = .gray
        }


        view.backgroundColor = UIColor(lightColor: .black, darkColor: .black, lightColorAlpha: 0.2, darkColorAlpha: 0.43)
        alertView.backgroundColor = UIColor(lightColor: .spGray2, darkColor: .darkGray2)
        activityIndicator.color = UIColor(lightColor: .black, darkColor: .spGray1)
    }
}

private struct Constants {
    static let width: CGFloat = 150
    static let height: CGFloat = 115
    static let cornerRadius: CGFloat = 15
}
