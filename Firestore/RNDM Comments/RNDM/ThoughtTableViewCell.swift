//
//  ThoughtTableViewCell.swift
//  RNDM
//
//  Created by Owen Henley on 10/2/18.
//  Copyright © 2018 Owen Henley. All rights reserved.
//

import UIKit
import Firebase

class ThoughtTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var randomThoughtLAbel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var likesLAbel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    //Variables
    private var thought: Thought!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeImageView.addGestureRecognizer(tap)
        likeImageView.isUserInteractionEnabled = true
    }
    
    @objc func likeTapped() {
        Firestore.firestore().document("thoughts/\(thought.documentID!)").updateData([NUM_LIKES : thought.numLikes + 1])
    }
    
    
    func configureCell(thought: Thought) {
        self.thought = thought
        usernameLabel.text      = thought.username
        randomThoughtLAbel.text = thought.thoughtText
        likesLAbel.text         = String(thought.numLikes)
        commentsLabel.text      = String(thought.numComments)
        
        // Date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: thought.timestamp)
        dateLabel.text = timestamp
    }
}
