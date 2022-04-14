//
//  ExtensionUIView.swift
//  PageViewController
//
//  Created by Gopal Rao Gurram on 4/14/22.
//

import Foundation
import UIKit

extension UIView {
    @discardableResult func loadViewIfNeeded(nibName: String, bindToSuperview: Bool = true) -> UIView? {
        guard subviews.count == 0,
              let view = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?.first as? UIView
        else { return nil } //Did not need to load view or failed to find it

        addSubview(view)
        if bindToSuperview {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.frame = bounds
            view.bindViewToSuperviewBounds()
        }

        return view
    }
    
    @objc func bindViewToSuperviewBounds() {

        guard let superview = superview else {
            return
        }

        superview.addConstraints([NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1.0, constant: 0.0),
                                  NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1.0, constant: 0.0),
                                  NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1.0, constant: 0.0),
                                  NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1.0, constant: 0.0)])
    }
}
