import UIKit

extension UIView {
    /// A helper function to add multiple subviews.
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach {
            addSubview($0)
        }
    }
    
    func makeCircleView() {
        self.layer.cornerRadius = self.bounds.height / 2
        self.clipsToBounds = true
    }
    func makeRoundView() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
}
