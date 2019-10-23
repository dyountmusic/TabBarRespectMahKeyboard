//
//  SecondViewController.swift
//  KeyboardNotificationTest
//
//  Created by Daniel Yount on 10/23/19.
//  Copyright © 2019 Daniel Yount. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var frameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillLayoutSubviews() {
        updateTabBarLabel()
    }

    private func updateTabBarLabel() {
        guard let tabBarFrame = tabBarController?.tabBar.frame else {
            frameLabel.text = "Error. TabBar Frame could not be fetched. Try again later."
            return
        }
        frameLabel.text = "The TabBar's Frame is \n{ x: \(tabBarFrame.minX), y: \(tabBarFrame.minY) } \n{ width: \(tabBarFrame.width), height: \(tabBarFrame.height) } "
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }


}

extension SecondViewController: UITextFieldDelegate {

    @objc private func dismissKeyboard() {
        textField.resignFirstResponder()
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let previousFrame = self.tabBarController?.tabBar.frame else { return }
        if let data = notification.userInfo as? [String: Any], let bounds = data["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
            guard bounds.height <= 150 else { return } // protect against modifying the tab bar outside of the quick type toolbar keyboard scenario
            let newFrame = CGRect(x: previousFrame.minX, y: bounds.minY, width: previousFrame.width, height: previousFrame.height)
            tabBarController?.tabBar.frame = newFrame
        }
        updateTabBarLabel()
    }

    @objc private func keyboardWillHide(notification: Notification) {
        let previousFrame = self.tabBarController?.tabBar.frame
        if let width = previousFrame?.width, let height = previousFrame?.height {
            let newFrame = CGRect(x: 0, y: view.frame.height - height, width: width, height: height)
            tabBarController?.tabBar.frame = newFrame
        }
        updateTabBarLabel()
    }
}

