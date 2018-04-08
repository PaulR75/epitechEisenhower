//
//  HomeViewController.swift
//  EpitechEisenhower
//
//  Created by paul on 29/03/2018.
//  Copyright © 2018 Epitech. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth


class Task{
    var title = ""
    var description = ""
    var date = ""
    var id = ""
    var important = false
    init(_ title: String, _ description: String, _ date: String, _ id: String, _ important: Bool){
        self.title = title
        self.description = description
        self.date = date
        self.id = id
        self.important = important
    }
}

class myCell: UICollectionViewCell{
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var important: UIImageView!
    @IBOutlet weak var urgent: UIImageView!
    @IBOutlet weak var date: UILabel!
}

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
   
    @IBOutlet var collView: UICollectionView!
    fileprivate let reuseIdentifier = "EHTaskCell"
    fileprivate let itemsPerRow: CGFloat = 2.0
    fileprivate let sectionInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    let db = Firestore.firestore()
    var tasks: [Int:Task] = [Int:Task]()
    var currentRow: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
        let taskRef = db.collection("TasksToUser").getDocuments() { (querySnapshot, err) in
            if let err = err{
                print("Error getting documents: \(err)")
            }
            else{
                var i = 0
                for document in querySnapshot!.documents{
                    if let err = err{
                            print("Error getting documents: \(err)")
                    }
                    else{
                    if document.data()["userId"] as! String == user!.uid{
                        let taskRef2 = self.db.collection("tasks").document(document.data()["tasksId"] as! String).getDocument(completion: { (document, error) in
                            print(document?.data())
                            i = i + 1
                            let res = document?.data()!
                            let tmpimportant = (res!["important"] as! Int == 0) ? false : true
                            self.tasks[i] = Task(res!["title"] as! String, res!["description"] as! String, res!["date"] as! String, (document?.documentID)!, tmpimportant)
                            print(self.tasks)
                            self.collView.reloadData()
                            })
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentRow = indexPath.row
        if (indexPath.row == 0){
             performSegue(withIdentifier: "Tasksegue", sender: "test")
        }
        performSegue(withIdentifier: "Tasksegue", sender: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tasks.count + 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row == 0){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath)
            cell.layer.cornerRadius = 5
            return cell
        }
        else{
            let cell: myCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! myCell
            cell.title.text = tasks[indexPath.row]?.title
            if (tasks[indexPath.row]?.important != true){
                 cell.important.alpha = 0.2
            }
            else{
                cell.important.alpha = 1
            }
        
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            cell.date.text = tasks[indexPath.row]?.date
            cell.layer.cornerRadius = 5
            if (Date() >= formatter.date(from: (tasks[indexPath.row]!.date))! && tasks[indexPath.row]?.important == true){
                cell.backgroundColor = redColor
                cell.urgent.alpha = 1
            }
            else if (Date() >= formatter.date(from: (tasks[indexPath.row]?.date)!)! && tasks[indexPath.row]?.important == false) {
                cell.backgroundColor = greenColor
                cell.urgent.alpha = 1
            }
            else if (Date() < formatter.date(from: (tasks[indexPath.row]?.date)!)! && tasks[indexPath.row]?.important == true){
                cell.backgroundColor = blueColor
                cell.urgent.alpha = 0.2
            }
            else {
                 cell.backgroundColor = clearGreenColor
                 cell.urgent.alpha = 0.2
            }
            return cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: 83)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return sectionInsets.left
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Tasksegue"){
            let destination = segue.destination as! TasksViewController
            if sender as? String != "test"{
                print(tasks)
                print(currentRow)
                destination.Mydata = tasks[currentRow]!
            }
        }
    }
    
    @IBAction func addTask(_ sender: Any) {
        performSegue(withIdentifier: "Tasksegue", sender: "test")
    }
    
}
