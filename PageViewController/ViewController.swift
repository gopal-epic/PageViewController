//
//  ViewController.swift
//  PageViewController
//
//  Created by Gopal Rao Gurram on 4/14/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        showCreateAccountPopup()
    }

    func showCreateAccountPopup() {
        let createAccountPopup = CreateAccountPopupViewController()
        createAccountPopup.modalPresentationStyle = .fullScreen
        createAccountPopup.preferredContentSize = CGSize(width: 760, height: 566)
        self.present(createAccountPopup, animated: true)
    }
}

