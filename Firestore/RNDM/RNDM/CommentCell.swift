//
//  CommentCell.swift
//  RNDM
//
//  Created by Owen Henley on 10/3/18.
//  Copyright © 2018 Owen Henley. All rights reserved.
//

import UIKit
import Firebase

protocol CommentDelegate {
    func commentOptionsTapped(comment: Comment)
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    @IBOutlet weak var optionsMenu: UIImageView!
    
        // MARK: - Variables
    private var comment: Comment!
    private var delegate: CommentDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configueCell(comment: Comment, delegate: CommentDelegate) {
        usernameLbl.text = comment.username
        commentLbl.text = comment.commentText
        optionsMenu.isHidden = true
        self.comment = comment
        self.delegate = delegate
        
        
        // Date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: comment.timestamp)
        timestampLbl.text = timestamp
        
        if comment.userID == Auth.auth().currentUser?.uid {
            optionsMenu.isHidden = false
            optionsMenu.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(commentOptionsTapped))
            optionsMenu.addGestureRecognizer(tap)
        }
    }
    
    @objc func commentOptionsTapped() {
        delegate?.commentOptionsTapped(comment: comment)
    }
}
