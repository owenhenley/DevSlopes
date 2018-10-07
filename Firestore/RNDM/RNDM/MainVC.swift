//
//  MainViewController.swift
//  RNDM
//
//  Created by Owen Henley on 10/2/18.
//  Copyright © 2018 Owen Henley. All rights reserved.
//

import UIKit
import Firebase

class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate, ThoughtDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var segmentControl: UISegmentedControl!
    @IBOutlet private weak var tableView: UITableView!
    
    // Variables
    
    private var thoughts = [Thought]()
    private var thoughtsCollectionRef: CollectionReference!
    private var thoughtsListener: ListenerRegistration!
    private var selectedCatagory = ThoughtCatagory.funny.rawValue
    private var handle: AuthStateDidChangeListenerHandle?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate   = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        thoughtsCollectionRef = Firestore.firestore().collection(THOUGHTS_REF)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        handle = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
                self.present(loginVC, animated: true, completion: nil)
            } else {
                self.setListener()
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if thoughtsListener != nil {
            thoughtsListener.remove()
        }
    }
    
    func thoughtOptionsTapped(thought: Thought) {
        let alert = UIAlertController(title: "Delete", message: "", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete Though", style: .default) { (action) in
            Firestore.firestore().collection(THOUGHTS_REF).document(thought.documentID).delete(completion: { (error) in
                if let error = error {
                    debugPrint("Error deleting from Firestore: \(error.localizedDescription)")
                } else {
                    alert.dismiss(animated: true, completion: nil)
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
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
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
        } catch {
            debugPrint("Error Signing Out: \(error.localizedDescription)")
        }
    }
    
    //MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thoughts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "thoughtCell", for: indexPath) as! ThoughtTableViewCell
        
        cell.configureCell(thought: thoughts[indexPath.row], delegate: self)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toComments", sender: thoughts[indexPath.row])
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            
            guard let destinationVC = segue.destination as? CommentsVC else { return }
            
            if let thought = sender as? Thought {
                destinationVC.thoughts = thought
            }
        }
    }
}

enum ThoughtCatagory : String {
    case funny   = "funny"
    case serious = "serious"
    case crazy   = "crazy"
    case popular = "popular"
}
