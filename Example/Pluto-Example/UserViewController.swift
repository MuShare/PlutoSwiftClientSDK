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
    
    private lazy var imagePickerController: UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.navigationBar.tintColor = .white
        imagePickerController.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
        ]
        return imagePickerController
    }()
    
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
    
    @IBAction func uploadAvatar(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Update Avatar",
            message: nil,
            preferredStyle: .actionSheet
        )
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
                self.imagePickerController.cameraCaptureMode = .photo
                self.imagePickerController.cameraDevice = .front
                self.imagePickerController.allowsEditing = true
            }
            self.present(self.imagePickerController, animated: true)
        }
        let choosePhoto = UIAlertAction(title: "Select from Library", style: .default) { action in
            self.imagePickerController.sourceType = .photoLibrary
            self.imagePickerController.allowsEditing = true
            self.present(self.imagePickerController, animated: true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(takePhoto)
        alertController.addAction(choosePhoto)
        alertController.addAction(cancel)
        alertController.popoverPresentationController?.sourceView = avatarImageView
        alertController.popoverPresentationController?.sourceRect = avatarImageView.bounds
        present(alertController, animated: true)
    }
    
}


extension UserViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        avatarImageView.image = info[.editedImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
        
        /*
        uploadButton.isEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target      : self,
            selector    : #selector(updateUploadProgress),
            userInfo    : nil,
            repeats     : true)
        
        user.uploadAvatar(avatarImageView.image!) { (success) in
            self.uploadButton.isEnabled = true
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.timer?.invalidate()
            self.timer = nil
            if success {
                self.uploadButton.setTitle(R.string.localizable.upload_profile_photo(), for: .normal)
            }
        }
 */
    }
    
}

extension UserViewController: UINavigationControllerDelegate {}
