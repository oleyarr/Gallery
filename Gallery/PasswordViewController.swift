//
//  PasswordViewController.swift
//  Gallery
//
//  Created by Володя on 07.08.2021.
//

import UIKit

class PasswordViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordCheckErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordCheckErrorLabel.textColor = .clear
        passwordTextField.delegate = self
    }

    @IBAction func savePasswordButtonPressed(_ sender: Any) {
        passwordTextField.resignFirstResponder()
        KeychainManager.shared.savePassword(passwordTextField?.text ?? "")
        passwordTextField.text = ""
        passwordCheckErrorLabel.textColor = .clear
    }
    
    @IBAction func clearPasswordButtonPressed(_ sender: Any) {
        KeychainManager.shared.clearPassword()
        passwordTextField.text = ""
        passwordCheckErrorLabel.textColor = .clear
    }
}

extension PasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        if KeychainManager.shared.validatePassword(passwordTextField?.text ?? "") {
            self.dismiss(animated: true)
            return true
        } else {
            passwordCheckErrorLabel.textColor = .red
        }
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        passwordCheckErrorLabel.textColor = .clear
    }
}
