//
//  ScrollFormViewController.swift
//  Epic
//
//  Created by Garret Carstensen on 1/6/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import UIKit

open class ScrollFormViewController: UIViewController {

    @IBOutlet public var scrollView: UIScrollView?
    @IBOutlet public var visibleAreaView: UIView?
    @IBOutlet public var visibleAreaViewBottomConstraint: NSLayoutConstraint?

    @IBInspectable public var tapDismissesKeyboard: Bool = true
    @IBInspectable public var autoselectFirstResponder: Bool = false

    public var tapGestureRecognizer: UITapGestureRecognizer?
    fileprivate var _scrollViewDefaultBottomInset: CGFloat = 0
    fileprivate var _firstResponder: UIView? {
        didSet {
            updateTapGestureRecognizer()
        }
    }

    open override var prefersStatusBarHidden: Bool {
        return true
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Observe keyboard notifications to resize scroll view to visible portion of the screen
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        // Observe notification for closing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Add a tap gesture recognizer to dismiss the keyboard. On iPhone there is no keyboard button to do so.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.isEnabled = false // will enable when the keyboard is displayed
        self.tapGestureRecognizer = tapGestureRecognizer

        if let scrollView = scrollView {
            _scrollViewDefaultBottomInset = scrollView.contentInset.bottom
            scrollView.addGestureRecognizer(tapGestureRecognizer)
        } else {
            view.addGestureRecognizer(tapGestureRecognizer)
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Observe keyboard notifications to resize scroll view to visible portion of the screen
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        // Observe notification for closing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        if autoselectFirstResponder {
            if let textField = textFieldWithTag(1), _firstResponder == nil {
                textField.becomeFirstResponder()
            }
        }
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func updateTapGestureRecognizer() {
        if let tapGestureRecognizer = tapGestureRecognizer {
            tapGestureRecognizer.isEnabled = tapDismissesKeyboard && _firstResponder != nil
        }
    }

    /** Action to dismiss the keyboard which is available as a selector for connecting to UITapGestureRecognizer and other components via Interface Builder */
    @objc @IBAction public func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc open func keyboardWillShow(_ notification: Notification) {
        if let info = notification.userInfo {
            if let size = (info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size {
                // The info with the notification does not account for device orientation.
                // Assume the keyboard height is the lesser dimension.
                scrollViewKeyboardAdjustment = min(size.width, size.height)
            }
            if let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
                UIView.animate(withDuration: duration, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        scrollViewKeyboardAdjustment = 0.0
        if let info = notification.userInfo {
            if let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
                UIView.animate(withDuration: duration, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

    public var scrollViewKeyboardAdjustment: CGFloat {
        get {
            if let scrollView = scrollView {
                return scrollView.contentInset.bottom - _scrollViewDefaultBottomInset
            } else {
                return 0.0
            }
        }
        set {
            if let scrollView = scrollView {
                var inset = scrollView.contentInset
                inset.bottom = _scrollViewDefaultBottomInset + newValue
                scrollView.contentInset = inset
            }

            if let constraint = visibleAreaViewBottomConstraint {
                constraint.constant = newValue
            }
        }
    }

    func scrollToSubview(subview: UIView, withMargin margin: CGFloat, animated: Bool) {
        if let scrollView = scrollView {
            var rect = scrollView.convert(subview.bounds, from: subview)
            rect.origin.x -= margin
            rect.origin.y -= margin
            rect.size.width += 2.0 * margin
            rect.size.height += 2.0 * margin
            if !scrollView.bounds.contains(rect) {
                scrollView.scrollRectToVisible(rect, animated: animated)
            }
        }
    }

    func textFieldWithTag(_ tag: Int) -> UITextField? {
        if tag == 0 {
            return nil
        }
        return view.viewWithTag(tag) as? UITextField
    }

    func selectTextField(_ textField: UITextField) -> Bool {
        if textField.isUserInteractionEnabled && textField.canBecomeFirstResponder && !textField.isHidden {
            textField.becomeFirstResponder()
            return true
        }
        return false
    }

    func selectFirstTextField() {
        if let textField = textFieldWithTag(1) {
            let _ = selectTextField(textField)
        }
    }
}

extension ScrollFormViewController: UITextFieldDelegate {

    open func textFieldDidBeginEditing(_ textField: UITextField) {
        // Adjust scroll view bottom inset for custom input view
        var inputViewHeight: CGFloat = 0
        if let textFieldInputView = textField.inputView {
            inputViewHeight += textFieldInputView.frame.height
        }
        if let textFieldAccessoryView = textField.inputAccessoryView {
            inputViewHeight += textFieldAccessoryView.frame.height
        }
        if inputViewHeight > 0 {
            scrollViewKeyboardAdjustment = inputViewHeight
        }

        // Scroll so the selected text field is visible
        _firstResponder = textField
        scrollToSubview(subview: textField, withMargin: 10, animated: true)
    }

    open func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == _firstResponder {
            _firstResponder = nil
        }
    }

    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // If the text field has its tag set greater than 0...
        // Set the next text field as first responder, or dissmiss keyboard if there is no following text field
        if textField.tag > 0 {
            if let nextTextField = textFieldWithTag(textField.tag + 1) {
                if !selectTextField(nextTextField) {
                    textField.resignFirstResponder()
                }
            } else {
                textField.resignFirstResponder()
            }
        } else if textField.tag < 0 {
            // Text fields with negative tags dismiss keyboard on return
            textField.resignFirstResponder()
        }

        return true
    }

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

}
