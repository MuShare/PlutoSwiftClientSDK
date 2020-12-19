//
//  LoginViewController.swift
//  MuShare-Login-Swift-SDK
//
//  Created by Meng Li on 06/11/2019.
//  Copyright (c) 2019 MuShare. All rights reserved.
//

import UIKit
import PlutoSDK

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Pluto.shared.observeState { [unowned self] state in
            switch state {
            case .signIn:
                self.performSegue(withIdentifier: "userSegue", sender: self)
            default:
                break
            }
        }
    }
    
    @IBAction func loginWithEmail(_ sender: Any) {
        guard
            let address = emailTextField.text, !address.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else {
            return
        }
        Pluto.shared.loginWithAccount(account: address, password: password, error: { [weak self] error in
            self?.showAlert(title: "Error", content: error.localizedDescription)
        })
    }

}

