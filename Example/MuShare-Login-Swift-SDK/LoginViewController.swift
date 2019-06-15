//
//  LoginViewController.swift
//  MuShare-Login-Swift-SDK
//
//  Created by Meng Li on 06/11/2019.
//  Copyright (c) 2019 MuShare. All rights reserved.
//

import UIKit
import MuShareLogin

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func loginWithEmail(_ sender: Any) {
        guard
            let address = emailTextField.text, !address.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else {
            return
        }
        MuShareLogin.shared.loginWithEmail(address: address, password: password, success: { [weak self] in
            self?.showAlert(title: "Login", content: "Login success for " + address + " , accessToken is " + MuShareLogin.accessToken())
            self?.navigationController?.popViewController(animated: true)
        }, error: { [weak self] error in
            self?.showAlert(title: "Error", content: error.localizedDescription)
        })
    }

}

