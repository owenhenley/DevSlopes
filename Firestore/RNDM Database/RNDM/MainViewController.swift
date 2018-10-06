//
//  MainViewController.swift
//  RNDM
//
//  Created by Owen Henley on 10/2/18.
//  Copyright © 2018 Owen Henley. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView!
    
    // Variables
    
    private var thoughts = [Thought]()
    private var thoughtsCollectionRef: CollectionReference!
    private var thoughtsListener: ListenerRegistration!
    private var selectedCatagory = ThoughtCatagory.funny.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate   = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        thoughtsCollectionRef = Firestore.firestore().collection(THOUGHTS_REF)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        thoughtsListener.remove()
    }
    
    // MARK: - Methods
    func setListener() {
        
        if selectedCatagory == ThoughtCatagory.popular.rawValue {
            thoughtsListener = thoughtsCollectionRef
                //                .whereField(CATAGORY, isEqualTo: selectedCatagory)
                .order(by: NUM_LIKES, descending: true)
                .addSnapshotListener { (snapshot, error) in
                    
                    if let error = error {
                        debugPrint("Error fetching docs: \(error)")
                    } else {
                        self.thoughts.removeAll()
                        self.thoughts = Thought.parseData(snapshot: snapshot)
                        
                        self.tableView.reloadData()
                    }
            }
        } else {
            thoughtsListener = thoughtsCollectionRef
                .whereField(CATAGORY, isEqualTo: selectedCatagory)
                .order(by: TIMESTAMP, descending: true)
                .addSnapshotListener { (snapshot, error) in
                    if let error = error {
                        debugPrint("Error fetching docs: \(error)")
                    } else {
                        self.thoughts.removeAll()
                        self.thoughts = Thought.parseData(snapshot: snapshot)
                        
                        self.tableView.reloadData()
                    }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func segmentDidChange(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            selectedCatagory = ThoughtCatagory.funny.rawValue
        case 1:
            selectedCatagory = ThoughtCatagory.serious.rawValue
        case 2:
            selectedCatagory = ThoughtCatagory.crazy.rawValue
        default:
            selectedCatagory = ThoughtCatagory.popular.rawValue
        }
        
        thoughtsListener.remove()
        setListener()
        
    }
    
    //MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thoughts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "thoughtCell", for: indexPath) as! ThoughtTableViewCell
        
        cell.configureCell(thought: thoughts[indexPath.row])
        
        return cell
    }    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}

enum ThoughtCatagory : String {
    case funny   = "funny"
    case serious = "serious"
    case crazy   = "crazy"
    case popular = "popular"
}