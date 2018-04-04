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
    init(_ title: String, _ description: String, _ date: String){
        self.title = title
        self.description = description
        self.date = date
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
    
    override func viewWillAppear(_ animated: Bool) {
       // tasks.removeAll()
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
//                            newTask.id = document?.documentID as! String
//                            newTask.date = document?.data()!["date"] as! String
//                            newTask.description = document!.data()!["description"] as! String
//                            newTask.title = document!.data()!["title"] as! String
                            self.tasks[i] = Task(document?.documentID as! String, "t", "t")
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
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            cell.date.text = tasks[indexPath.row]?.date
            cell.layer.cornerRadius = 5
            cell.backgroundColor = clearGreenColor
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
                destination.Mydata = ["Test":"Test"]
            }

        }
    }
    
    @IBAction func addTask(_ sender: Any) {
        performSegue(withIdentifier: "Tasksegue", sender: "test")
    }
    
}
