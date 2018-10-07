//
//  CommentsVC.swift
//  RNDM
//
//  Created by Owen Henley on 10/3/18.
//  Copyright © 2018 Owen Henley. All rights reserved.
//

import UIKit
import Firebase

class CommentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CommentDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCommentTF: UITextField!
    @IBOutlet weak var commentContainer: UIView!
    
    // Variables
    var thoughts: Thought!
    var comments = [Comment]()
    var thoughtRef: DocumentReference!
    let firestore = Firestore.firestore()
    var username: String!
    var commentListener: ListenerRegistration!
    let auth = Auth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        thoughtRef = firestore.collection(THOUGHTS_REF).document(thoughts.documentID)
        if let name = Auth.auth().currentUser?.displayName {
            username = name
        }
        self.view.bindToKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        commentListener = firestore
            .collection(THOUGHTS_REF)
            .document(self.thoughts.documentID)
            .collection(COMMENTS_REF)
            .order(by: TIMESTAMP, descending: false)
            .addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else {
                debugPrint("Error fetching comments: \(error!)")
                return
            }
            self.comments.removeAll()
            self.comments = Comment.parseData(snapshot: snapshot)
            self.tableView.reloadData()
        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        commentListener.remove()
    }
    
    func commentOptionsTapped(comment: Comment) {
        let alert = UIAlertController(title: "Edit Comment", message: "You can edit or delete", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete Comment", style: .default) { (action) in
            
            self.firestore.runTransaction({ (transaction, errorPointer) -> Any? in
                
                let thoughtDocument: DocumentSnapshot
                
                do {
                    try thoughtDocument = transaction.getDocument(self.firestore.collection(THOUGHTS_REF).document(self.thoughts.documentID))
                } catch let error as NSError {
                    debugPrint("Fetch error: \(error.localizedDescription)")
                    return nil
                }
                
                guard let oldNumComments = thoughtDocument.data()?[NUM_COMMENTS] as? Int else { return nil }
                
                transaction.updateData([NUM_COMMENTS : oldNumComments - 1], forDocument: self.thoughtRef)
                
                let commentRef = self.firestore.collection(THOUGHTS_REF).document(self.thoughts.documentID)
                                               .collection(COMMENTS_REF).document(comment.documentID)
                
                transaction.deleteDocument(commentRef)
                
                return nil
                
            }) { (object, error) in
                if let error = error {
                    debugPrint("Transaction failed: \(error.localizedDescription)")
                } else {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
//            self.firestore.collection(THOUGHTS_REF).document(self.thoughts.documentID)
//                .collection(COMMENTS_REF)
//                .document(comment.documentID)
//                .delete(completion: { (error) in
//                    if let error = error {
//                        debugPrint("Error deleting comment: \(error.localizedDescription)")
//                    }
//                })
        }
        
        let editComment = UIAlertAction(title: "Edit Comment", style: .default) { (action) in
            self.performSegue(withIdentifier: "toEditComment", sender: (comment, self.thoughts))
            alert.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        alert.addAction(deleteAction)
        alert.addAction(editComment)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UpdateCommentVC {
            if let commentData = sender as? (comment: Comment, thought: Thought) {
                destination.commentData = commentData
            }
        }
    }
    
    
    // MARK: - Actions
    
    @IBAction func addCommentTapped(_ sender: Any) {
        guard let commentText = addCommentTF.text, commentText != "" else  { return }
        
        firestore.runTransaction({ (transaction, errorPointer) -> Any? in
            
            let thoughtDocument: DocumentSnapshot
            
            do{
                try thoughtDocument = transaction.getDocument(self.firestore.collection(THOUGHTS_REF).document(self.thoughts.documentID))
            } catch let error as NSError {
                debugPrint("Fetch error: \(error.localizedDescription)")
                return nil
            }
            
            guard let oldNumComments = thoughtDocument.data()?[NUM_COMMENTS] as? Int else { return nil }
            
            transaction.updateData([NUM_COMMENTS : oldNumComments + 1], forDocument: self.thoughtRef)
            
            let newCommentRef = self.firestore.collection(THOUGHTS_REF).document(self.thoughts.documentID).collection(COMMENTS_REF).document()
            
            transaction.setData([
                COMMENT_TEXT : commentText,
                TIMESTAMP    : FieldValue.serverTimestamp(),
                USERNAME     : self.username,
                USER_ID      : self.auth.currentUser?.uid ?? ""
                ], forDocument: newCommentRef)
            
            return nil
            
        }) { (object, error) in
            if let error = error {
                debugPrint("Transaction failed: \(error.localizedDescription)")
            } else {
                self.addCommentTF.text = ""
                self.addCommentTF.resignFirstResponder()
                self.view.bindToKeyboard()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentCell {
            cell.configueCell(comment: comments[indexPath.row], delegate: self)
            return cell
        }
        return UITableViewCell()
    }
}
