//
//  EpicImageLabelStackView.swift
//  Epic
//
//  Created by Gopal Rao Gurram on 3/23/22.
//  Copyright © 2022 Epic. All rights reserved.
//

import UIKit

class EpicImageLabelStackView: UIStackView {

    var defaultNibName: String { return String(describing: type(of: self)) } // Getting the name of the UIView’s class. This will only work if the xib name and its corresponding class name is same.

    @IBOutlet weak var stackView: UIStackView?
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var label: UILabel?

    required init(coder: NSCoder) {
        super.init(coder: coder)

        configureXib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureXib()
    }

    private func configureXib() {
        loadViewIfNeeded(nibName: defaultNibName)
    }

    class func createEpicImageLabelStackView(frame: CGRect, stackViewAxis: NSLayoutConstraint.Axis = .vertical, image: UIImage?, text: String?) -> EpicImageLabelStackView {
        let imageLabelStackView = EpicImageLabelStackView(frame: frame)
        imageLabelStackView.stackView?.axis = stackViewAxis
        imageLabelStackView.imageView?.image = image
        imageLabelStackView.label?.text = text

        return imageLabelStackView
    }
}
