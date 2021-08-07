//
//  PasswordViewController.swift
//  Gallery
//
//  Created by Володя on 07.08.2021.
//

import UIKit

class PasswordViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.delegate = self
    }
    
    @IBAction func savePasswordButtonPressed(_ sender: Any) {
        passwordTextField.resignFirstResponder()
        KeychainManager.shared.savePassword(passwordTextField?.text ?? "")
        passwordTextField.text = ""
    }
    
    @IBAction func clearPasswordButtonPressed(_ sender: Any) {
        KeychainManager.shared.clearPassword()
        passwordTextField.text = ""
    }
}

extension PasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        if KeychainManager.shared.validatePassword(passwordTextField?.text ?? "") {
            print("верный пароль")
            self.dismiss(animated: true)
            return true
        } else {
            print("неверный пароль")
        }
        return false
    }
}
