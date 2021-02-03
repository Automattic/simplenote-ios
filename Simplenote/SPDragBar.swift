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
        let color = UIColor(lightColor: ColorStudio.black, darkColor: ColorStudio.white)
        
        backgroundColor = color
        alpha = 0.2
        layer.cornerRadius = 2.5
        layer.masksToBounds = true
        
        isAccessibilityElement = true
    }
}
