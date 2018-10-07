//
//  Thought.swift
//  RNDM
//
//  Created by Owen Henley on 10/2/18.
//  Copyright © 2018 Owen Henley. All rights reserved.
//

import Foundation
import Firebase

class Thought {
    
    private(set) var username    : String!
    private(set) var timestamp   : Date!
    private(set) var thoughtText : String!
    private(set) var numLikes    : Int!
    private(set) var numComments : Int!
    private(set) var documentID  : String!
    private(set) var userID      : String!
    
    init (username: String, timestamp: Date, thoughtText: String, numLikes: Int, numComments: Int, documentID: String, userID: String) {
        
        self.username    = username
        self.timestamp   = timestamp
        self.thoughtText = thoughtText
        self.numLikes    = numLikes
        self.numComments = numComments
        self.documentID  = documentID
        self.userID      = userID
    }
    
    class func parseData(snapshot: QuerySnapshot?) -> [Thought] {
        var thoughts = [Thought]()
        
        guard let snapshot = snapshot else { return thoughts }
        for document in (snapshot.documents) {
            let data        = document.data()
            let username    = data[USERNAME] as? String ?? "Anonymous"
            let timestamp   = data[TIMESTAMP] as? Date ?? Date()
            let thoughtText = data[THOUGHT_TEXT] as? String ?? ""
            let numLikes    = data[NUM_LIKES] as? Int ?? 0
            let numComments = data[NUM_COMMENTS] as? Int ?? 0
            let documentID  = document.documentID
            let userID      = data[USER_ID] as? String ?? ""
            
            let newThought = Thought(username: username, timestamp: timestamp, thoughtText: thoughtText, numLikes: numLikes, numComments: numComments, documentID: documentID, userID: userID)
            
            thoughts.append(newThought)
        }
        
        return thoughts
    }
}
