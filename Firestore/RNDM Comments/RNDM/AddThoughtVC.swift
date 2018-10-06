//
//  AddThoughtViewController.swift
//  RNDM
//
//  Created by Owen Henley on 10/2/18.
//  Copyright © 2018 Owen Henley. All rights reserved.
//

import UIKit
import Firebase

class AddThoughtVC: UIViewController, UITextViewDelegate {
	
	// Outlets
	@IBOutlet weak var catagorySegment: UISegmentedControl!
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var thoughtTextView: UITextView!
	@IBOutlet weak var postButton: UIButton!
	
	// Variables
	private var selectedCatagory = ThoughtCatagory.funny.rawValue
	
	
	// Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
		
		thoughtTextView.delegate = self
		
		postButton.layer.cornerRadius = 4
		thoughtTextView.layer.cornerRadius = 4
		thoughtTextView.text = "My Random Thought..."
		thoughtTextView.textColor = UIColor.darkGray
    }
	
	@IBAction func postTapped(_ sender: UIButton) {
		guard let username = usernameTextField.text else { return }
		Firestore.firestore().collection(THOUGHTS_REF).addDocument(data: [
			
			CATAGORY     : selectedCatagory,
			NUM_COMMENTS : 0,
			NUM_LIKES    : 0,
			THOUGHT_TEXT : thoughtTextView.text,
			TIMESTAMP    : FieldValue.serverTimestamp(),
			USERNAME     : username
			
		]) { (error) in
			
			if let error = error {
				debugPrint("Error adding to Firestore: \(error)")
			} else {
				self.navigationController?.popViewController(animated: true)
			}
		}
	}
	
	@IBAction func catagoryChanged(_ sender: UISegmentedControl) {
		switch catagorySegment.selectedSegmentIndex {
		case 0:
			selectedCatagory = ThoughtCatagory.funny.rawValue
		case 1:
			selectedCatagory = ThoughtCatagory.serious.rawValue
		default:
			selectedCatagory = ThoughtCatagory.crazy.rawValue
		}
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		textView.text = ""
		textView.textColor = UIColor.darkGray
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
