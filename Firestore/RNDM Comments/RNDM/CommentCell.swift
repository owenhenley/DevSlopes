//
//  CommentCell.swift
//  RNDM
//
//  Created by Owen Henley on 10/3/18.
//  Copyright © 2018 Owen Henley. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var timestampLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configueCell(comment: Comment) {
        usernameLbl.text = comment.username
        commentLbl.text = comment.commentText
        
        // Date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, hh:mm"
        let timestamp = formatter.string(from: comment.timestamp)
        timestampLbl.text = timestamp
    }
}
