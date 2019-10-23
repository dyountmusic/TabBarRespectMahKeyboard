//
//  FirstViewController.swift
//  KeyboardNotificationTest
//
//  Created by Daniel Yount on 10/23/19.
//  Copyright © 2019 Daniel Yount. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var tabBarMeasurementLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        updateTabBarLabel()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func updateTabBarLabel() {
        guard let tabBarFrame = tabBarController?.tabBar.frame else {
            tabBarMeasurementLabel.text = "Error. TabBar Frame could not be fetched. Try again later."
            return
        }
        tabBarMeasurementLabel.text = "The TabBar's Frame is \n{ x: \(tabBarFrame.minX), y: \(tabBarFrame.minY) } \n{ width: \(tabBarFrame.width), height: \(tabBarFrame.height) } "
    }
}

extension FirstViewController: UITextFieldDelegate {

    @objc private func dismissKeyboard() {
        textField.resignFirstResponder()
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let previousFrame = self.tabBarController?.tabBar.frame else { return }
        if let data = notification.userInfo as? [String: Any], let bounds = data["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
            guard bounds.height <= 150 else { return } // protect against modifying the tab bar outside of the quick type toolbar keyboard scenario
            let newFrame = CGRect(x: previousFrame.minX, y: previousFrame.minY - previousFrame.height, width: previousFrame.width, height: previousFrame.height)
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
