import UIKit

class SPDragBar: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        backgroundColor = SPUserInterface.isDark ? .white : .black
        alpha = 0.2
        layer.cornerRadius = 2.5
        layer.masksToBounds = true
    }
}
