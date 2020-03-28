//
//  UserViewController.swift
//  Pluto-Example
//
//  Created by Meng Li on 2019/8/10.
//  Copyright © 2019 MuShare. All rights reserved.
//

import PlutoSDK
import Kingfisher

class UserViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Pluto.shared.myInfo(success: { [weak self] in
            self?.set(user: $0)
        }, error: {
            print($0)
        })
    }
    
    @IBAction func refresh(_ sender: Any) {
        Pluto.shared.getToken { [weak self] in
            self?.showAlert(title: "token", content: $0 ?? "")
            
        }
    }
    
    @IBAction func showScopes(_ sender: Any) {
        Pluto.shared.getScopes { [weak self] in
            self?.showAlert(title: "scopes", content: $0.description)
        }
    }
    
    private func set(user: PlutoUser) {
        avatarImageView.kf.setImage(with: URL(string: user.avatar))
        emailLabel.text = user.mail
        nameLabel.text = user.name
    }
    
}
