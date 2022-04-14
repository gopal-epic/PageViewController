//
//  CreateAccountPageViewController.swift
//  Epic
//
//  Created by Gopal Rao Gurram on 3/23/22.
//  Copyright © 2022 Epic. All rights reserved.
//

import UIKit

class CreateAccountPageViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var imageLabelStackView: UIStackView?

    var page: CreateAccountPopupModel

    init(with page: CreateAccountPopupModel) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func updateUI() {
        
        titleLabel?.text = page.title()

        guard let imageLabelStackView = self.imageLabelStackView
        else { return }

        if CreateAccountPopupModel.isIphone() {
            imageLabelStackView.addEpicImageLabelViewAsArrangedSubView(for: page)
        } else {
            let allPages: [CreateAccountPopupModel] = [.pageZero, .pageOne, .pageTwo]
            for page in allPages {
                imageLabelStackView.addEpicImageLabelViewAsArrangedSubView(for: page)
            }
        }
    }

}

extension UIStackView {
    func addEpicImageLabelViewAsArrangedSubView(for page: CreateAccountPopupModel) {
        let epicImageLabelStackViewFrame: CGRect = CreateAccountPopupModel.isIphone() ? self.frame : CGRect(origin: self.frame.origin, size: CGSize(width: 220, height: 275))
        let epicImageLabelStackView = EpicImageLabelStackView.createEpicImageLabelStackView(frame: epicImageLabelStackViewFrame, image: page.backgroundImage(), text: page.subTitle())
        epicImageLabelStackView.label?.textAlignment = .center
        self.addArrangedSubview(epicImageLabelStackView)
    }
}
