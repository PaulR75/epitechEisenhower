//
//  TasksViewController.swift
//  EpitechEisenhower
//
//  Created by paul on 04/04/2018.
//  Copyright © 2018 Epitech. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class TasksViewController: UIViewController{
    
    @IBOutlet weak var titleTask: UITextView!
    @IBOutlet weak var peopleView: UICollectionView!
    @IBOutlet weak var dateView: UITextField!
    @IBOutlet weak var taskDescription: UITextView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var importantButton: UIButton!
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    
    @IBOutlet weak var addPeopleButton: UIButton!
    
    private var idTask: String?
    private var important: Bool = false
    
    var Mydata: [String:String] = [String:String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTask.text = Mydata["title"]
        taskDescription.text = Mydata["description"]
        dateView.text = Mydata["date"]
        idTask = Mydata["id"]
        saveBtn.layer.cornerRadius = 5
        deleteBtn.layer.cornerRadius = 5
        titleTask.layer.cornerRadius = 5
        taskDescription.layer.cornerRadius = 5
        addPeopleButton.layer.cornerRadius = addPeopleButton.frame.width / 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func randomString(len:Int) -> String {
        let charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var c = Array(charSet)
        var s:String = ""
        for n in (1...10) {
            s.append(c[Int(arc4random()) % c.count])
        }
        return s
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        if ((titleTask.text!.count == 0) || (dateView.text!.count == 0) || (taskDescription.text!.count == 0)){
            return
        }
        if (idTask == nil){
            idTask = randomString(len: 10)
        }
        let taskRef = db.collection("tasks").document(idTask!).setData(["title": titleTask.text!, "date": dateView.text!, "description": taskDescription.text!, "important": false], options: SetOptions.merge())
        let taskuserRef = db.collection("TasksToUser").whereField("tasksId", isEqualTo: idTask).whereField("userId", isEqualTo: currentUser!.uid).getDocuments { (querySnapshot, err) in
            if (err != nil){
                print(err)
            } else{
                for document in querySnapshot!.documents{
                    return
                }
            }
            self.db.collection("TasksToUser").document().setData(["tasksId": self.idTask, "userId": self.currentUser!.uid], options: SetOptions.merge())
        }
    }
}
