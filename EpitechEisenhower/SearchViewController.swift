//
//  SearchViewController.swift
//  EpitechEisenhower
//
//  Created by paul_vntrs on 2018-04-08.
//  Copyright © 2018 Epitech. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

class People{
    var id: String!
    var email: String!
    init(_ id: String, _ email: String) {
        self.id = id
        self.email = email
    }
}

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var peopleData: [People] = [People]()
    let db = Firestore.firestore()
    var previousView: TasksViewController!
    var callback: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let peoplesRef = db.collection("users").getDocuments(){querySnapshot,err in
            if (err != nil){
                print(err)
                return
            }
            else{
                for document in querySnapshot!.documents{
                    self.peopleData.append(People(document.documentID, document.data()["email"] as! String))
                    self.tableView.reloadData()
                    print(self.peopleData)
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peopleData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = peopleData[indexPath.row].email
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(peopleData[indexPath.row])
        previousView.peopleToInvite.append(peopleData[indexPath.row])
        previousView.peopleView.reloadData()
        dismiss(animated: true)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}


