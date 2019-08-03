//
//  CustomBack.swift
//  Tsukuba-iOS
//
//  Created by Meng Li on 11/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, content: String) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: title,
                                                    message: content,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
            self?.present(alertController, animated: true)
        }
        
    }

}
