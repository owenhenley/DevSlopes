//
//  LoginViewController.swift
//  RNDM
//
//  Created by Owen Henley on 10/3/18.
//  Copyright © 2018 Owen Henley. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
        // MARK: - Outlets
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createUserButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        createUserButton.layer.cornerRadius = 5

    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        guard let email = emailTF.text, let password = passwordTF.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint("Error signing in: \(error.localizedDescription)")
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
