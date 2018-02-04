//
//  SignInViewController.swift
//  hoopr
//
//  Created by Paul Narcisse on 12/28/17.
//  Copyright © 201 Paul Narcisse. All rights reserved.
//

import UIKit



class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        emailTextField.backgroundColor = .clear
        emailTextField.tintColor = .white
        emailTextField.textColor = .white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes:[NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        let bottomLayerEmail = CALayer()
        bottomLayerEmail.frame = CGRect(x: 0, y: 40, width: 375, height: 1)
        bottomLayerEmail.backgroundColor = UIColor(white: 1.0, alpha: 0.9).cgColor
        emailTextField.layer.addSublayer(bottomLayerEmail)
        bottomLayerEmail.masksToBounds = true
        
        passwordTextField.backgroundColor = .clear
        passwordTextField.tintColor = .white
        passwordTextField.textColor = .white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes:[NSAttributedStringKey.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        let BottomLayerPassword = CALayer()
        BottomLayerPassword.frame = CGRect(x: 0, y: 40, width: 375, height: 1)
        BottomLayerPassword.backgroundColor = UIColor(white: 1.0, alpha: 0.9).cgColor
        passwordTextField.layer.addSublayer(BottomLayerPassword)
        signInButton.isEnabled = false
        BottomLayerPassword.masksToBounds = true
        handleTextField()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Api.User.CURRENT_USER != nil {
            self.performSegue(withIdentifier: "signInTabbarVC", sender: nil)
        }
    }
    func handleTextField() {
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    @objc func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text,  !password.isEmpty else {
            signInButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
            signInButton.isEnabled = false
            return
        }
        
        signInButton.setTitleColor(UIColor(red: 255/255, green: 113/255, blue: 0/255, alpha: 1), for: UIControlState.normal)
        signInButton.isEnabled = true
        
    }
    
    
    @IBAction func signInButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
         ProgressHUD.show("Granting Access", interaction: false)
        AuthService.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
            ProgressHUD.showSuccess("Success")
            self.performSegue(withIdentifier: "signInTabbarVC", sender: nil)}, onError: { error in
                ProgressHUD.showError(error!)
        })
    }
    
    
}


