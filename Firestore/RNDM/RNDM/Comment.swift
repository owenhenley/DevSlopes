//
//  Comment.swift
//  
//
//  Created by Owen Henley on 10/4/18.
//

import Foundation
import Firebase

class Comment {
    
    private(set) var username    : String!
    private(set) var timestamp   : Date!
    private(set) var commentText : String!
    private(set) var documentID  : String!
    private(set) var userID      : String!
    
    init (username: String, timestamp: Date, commentText: String, documentID: String, userID: String) {
        
        self.username    = username
        self.timestamp   = timestamp
        self.commentText = commentText
        self.documentID  = documentID
        self.userID      = userID
    }
    
    class func parseData(snapshot: QuerySnapshot?) -> [Comment] {
        var comments = [Comment]()

        guard let snapshot = snapshot else { return comments }
        for document in (snapshot.documents) {
            let data        = document.data()
            let username    = data[USERNAME] as? String ?? "Anonymous"
            let timestamp   = data[TIMESTAMP] as? Date ?? Date()
            let commentText = data[COMMENT_TEXT] as? String ?? ""
            let documentID  = document.documentID
            let userID      = data[USER_ID] as? String ?? ""
            
            let newComment = Comment(username: username, timestamp: timestamp, commentText: commentText, documentID: documentID, userID: userID)

            comments.append(newComment)
        }

        return comments
    }
}
