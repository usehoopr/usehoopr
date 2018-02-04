//
//  SettingTableViewController.swift
//  hoopr
//
//  Created by Paul Narcisse on 1/20/18.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import UIKit
protocol SettingTableViewControllerDelegate {
    func updateUserInfor()
}

class SettingTableViewController: UITableViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
     var delegate: SettingTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Top Bar1"), for: .default)
        navigationItem.title = "Edit Profile"
        usernameTextField.delegate = self
        emailTextField.delegate = self
        fetchCurrentUser()
    }
    func fetchCurrentUser() {
        Api.User.observeCurrentUser { (user) in
            self.usernameTextField.text = user.username
            self.emailTextField.text = user.email
            if let profileUrl = URL(string: user.profileImageUrl!) {
             self.profileImageView.sd_setImage(with: profileUrl)
            }
            
        }
    }
    @IBAction func saveBtn_TouchUpInside(_ sender: Any) {
        if let profileImg = self.profileImageView.image, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
            ProgressHUD.show("Updating...")
            AuthService.updateUserInfor(username: usernameTextField.text!, email: emailTextField.text!, imageData: imageData, onSuccess: {
                ProgressHUD.showSuccess("Success")
                self.delegate?.updateUserInfor()
            }, onError: { (errorMessage) in
                ProgressHUD.showError(errorMessage)
            })
            
        }
    }
    @IBAction func logoutBtn_TouchUpInside(_ sender: Any) {
        AuthService.logout(onSuccess: {
            let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboard.instantiateViewController (withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    
    }
    @IBAction func changeProfileBtn_TouchUpInside(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
}
extension SettingTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
    }
    
}

extension SettingTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("return")
        textField.resignFirstResponder()
        return true
    }
}
