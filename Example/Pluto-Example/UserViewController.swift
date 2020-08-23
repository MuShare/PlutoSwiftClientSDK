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
    @IBOutlet weak var nameLabel: UILabel!
    
    private lazy var imagePickerController: UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.navigationBar.tintColor = .white
        imagePickerController.navigationBar.titleTextAttributes = [
            .foregroundColor : UIColor.white
        ]
        return imagePickerController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Pluto.shared.myInfo(success: { [weak self] in
            self?.set(user: $0)
        }, error: {
            print("Error loading user info: \($0)")
        })
    }
    
    @IBAction func refresh(_ sender: Any) {
        Pluto.shared.getToken(isForceRefresh: true) { [weak self] in
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
    
    @IBAction func updateName(_ sender: Any) {
        let alertController = UIAlertController(
            title: "Update user name",
            message: nil,
            preferredStyle: .alert
        )
        alertController.addTextField {
            $0.textAlignment = .center
        }
        let addAction = UIAlertAction(title: "Submit", style: .default) { [unowned self] _ in
            guard let name = alertController.textFields?[0].text else {
                return
            }
            Pluto.shared.updateName(name: name, success: { [weak self] in
                self?.nameLabel.text = name
            }, error: { [weak self] in
                switch $0 {
                case .userNameExist:
                    self?.showAlert(title: "Error", content: "User name already exists")
                default:
                    print("Error updating user name: \($0)")
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
}


extension UserViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        picker.dismiss(animated: true, completion: nil)

        Pluto.shared.uploadAvatar(image: image, success: { [weak self] in
            self?.avatarImageView.image = image
        }, error: {
            print("Error uploading avatar: \($0)")
        })
    }
    
}

extension UserViewController: UINavigationControllerDelegate {}
