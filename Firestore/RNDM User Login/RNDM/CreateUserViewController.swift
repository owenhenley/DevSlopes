//
//  CreateUserViewController.swift
//  RNDM
//
//  Created by Owen Henley on 10/3/18.
//  Copyright © 2018 Owen Henley. All rights reserved.
//

import UIKit
import Firebase

class CreateUserViewController: UIViewController {
    
    
    // MARK: - Outlets
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5
    }
    
    // MARK: - Actions
    @IBAction func signUpTapped(_ sender: UIButton) {
        
        guard let email = emailTF.text, let password = passwordTF.text, let username = usernameTF.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                debugPrint("Error signing up user: \(error.localizedDescription)")
            }
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                }
            })
            
            guard let userID = Auth.auth().currentUser?.uid else { return }
            Firestore.firestore().collection(USERS_REF).document(userID).setData([
                
                USERNAME     : username,
                DATE_CREATED : FieldValue.serverTimestamp()
                
                ], completion: { (error) in
                    if let error = error {
                        debugPrint(error.localizedDescription)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
            })
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
