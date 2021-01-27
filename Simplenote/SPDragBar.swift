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
    
    func configure() {
        if SPUserInterface.isDark {
            self.backgroundColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.black
        }
        self.alpha = 0.2
        self.layer.cornerRadius = 2.5
        self.layer.masksToBounds = true
    }
}
