//
//  SignUpViewController.swift
//  hoopr
//
//  Created by Paul Narcisse on 12/29/17.
//  Copyright © 2018 Paul Narcisse. All rights reserved.
//

import UIKit


class SignUpViewController: UIViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    
    var selectedImage: UIImage?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.backgroundColor = .clear
        emailTextField.tintColor = .white
        emailTextField.textColor = .white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes:[NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        let bottomLayerEmail = CALayer()
        bottomLayerEmail.frame = CGRect(x: 0, y: 40, width: 375, height: 1)
        bottomLayerEmail.backgroundColor = UIColor(white: 1.0, alpha: 0.9).cgColor
        bottomLayerEmail.masksToBounds = true
        
        passwordTextField.backgroundColor = .clear
        passwordTextField.tintColor = .white
        passwordTextField.textColor = .white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes:[NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        let BottomLayerPassword = CALayer()
        BottomLayerPassword.frame = CGRect(x: 0, y: 40, width: 375, height: 1)
        BottomLayerPassword.backgroundColor = UIColor(white: 1.0, alpha: 0.9).cgColor
        BottomLayerPassword.masksToBounds = true
        
        
        
        
        usernameTextField.backgroundColor = .clear
        usernameTextField.tintColor = .white
        usernameTextField.textColor = .white
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes:[NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        let BottomLayerUsername = CALayer()
        BottomLayerUsername.frame = CGRect(x: 0, y: 40, width: 375, height: 1)
        BottomLayerUsername.backgroundColor = UIColor(white: 1.0, alpha: 0.9).cgColor
        BottomLayerUsername.masksToBounds = true

        
        
        passwordTextField.layer.addSublayer(BottomLayerPassword)
        emailTextField.layer.addSublayer(bottomLayerEmail)
        usernameTextField.layer.addSublayer(BottomLayerUsername)
        
        profileImage.layer.cornerRadius =  50
        profileImage.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector(self.handleSelectProfileImageView))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        signUpButton.isEnabled = false
        handleTextField()
    }
    
    
    func handleTextField() {
        usernameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    @objc func textFieldDidChange() {
        guard let username = usernameTextField.text, !username.isEmpty, let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text,  !password.isEmpty else {
            signUpButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
            signUpButton.isEnabled = false
            return
        }
        
        signUpButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        signUpButton.isEnabled = true
        
    }
    
    @objc func handleSelectProfileImageView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    @IBAction func dismiss_onClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpBtn_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        ProgressHUD.show("Uploading Data", interaction: false)
        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
            AuthService.signUp(username: usernameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, imageData: imageData, onSuccess: {
                 ProgressHUD.showSuccess("Success")
                self.performSegue(withIdentifier: "signUpTabbarVC", sender: nil)}, onError: { (errorString) in
                    ProgressHUD.showError(errorString!)
            })
        } else {ProgressHUD.showError("Profile Image can't be empty")
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("did Finish Picking Media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImage = image
            profileImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    
}

}




