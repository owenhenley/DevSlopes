//
//  UpdateCommentVC.swift
//  RNDM
//
//  Created by Owen Henley on 10/7/18.
//  Copyright © 2018 Owen Henley. All rights reserved.
//

import UIKit
import Firebase

class UpdateCommentVC: UIViewController {
    
        // MARK: - Outlets
    
    @IBOutlet weak var commentText: UITextView!
    @IBOutlet weak var updateButton: UIButton!
    
        // MARK: - Variables
    var commentData: (comment: Comment, thought: Thought)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentText.layer.cornerRadius = 6
        updateButton.layer.cornerRadius = 6
        commentText.text = commentData.comment.commentText
    }
    
    @IBAction func updateTapped(_ sender: UIButton) {
        Firestore.firestore().collection(THOUGHTS_REF).document(commentData.thought.documentID)
        .collection(COMMENTS_REF).document(commentData.comment.documentID)
            .updateData([COMMENT_TEXT : commentText.text]) { (error) in
                if let error = error {
                    debugPrint("Unable to update Comment: \(error.localizedDescription)")
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
        }
    }
}
