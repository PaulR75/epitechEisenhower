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

class customCell2: UICollectionViewCell{
    
    @IBOutlet weak var labelName: UILabel!
}

class TasksViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return peopleToInvite.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "peopleCell", for: indexPath) as! customCell2
        cell.backgroundColor = UIColor.gray
        cell.layer.cornerRadius = cell.frame.width / 2
        cell.labelName.text = String(peopleToInvite[indexPath.row].email.first!)
        return cell
    }
    
    
    @IBOutlet weak var EHdatePicker: UIDatePicker!
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
    let dateFormatter = DateFormatter()
    private var idTask: String?
    private var important: Bool?
    var peopleToInvite: [People] = [People]()
    var Mydata: Task?
    
    override func viewDidLoad() {
        peopleToInvite = [People]()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        EHdatePicker.date = Date()
        super.viewDidLoad()
        titleTask.text = Mydata?.title
        taskDescription.text = Mydata?.description
        if (Mydata != nil && Mydata?.date != nil){
            EHdatePicker.date = dateFormatter.date(from: (Mydata?.date)!)!
        }
        idTask = Mydata?.id
        if (Mydata?.important == nil){
            important = true
        }
        else{
            important =  Mydata?.important
        }
        if (Mydata?.important == false){
            importantButton.alpha = 0.2
        }
        else{
            importantButton.alpha = 1
        }
        saveBtn.layer.cornerRadius = 5
        deleteBtn.layer.cornerRadius = 5
        titleTask.layer.cornerRadius = 5
        taskDescription.layer.cornerRadius = 5
        addPeopleButton.layer.cornerRadius = addPeopleButton.frame.width / 2
        let peopleRef = db.collection("TasksToUser").whereField("tasksId", isEqualTo: Mydata?.id).getDocuments { (querySnapshot, err) in
            if (err != nil){
                return
            }
            for document in querySnapshot!.documents{
                print(document.data())
                let peopleRef2 = self.db.collection("users").document(document.data()["userId"]! as! String).getDocument(completion: { (document, error) in
                    if (err != nil){
                        return
                    }
                    self.peopleToInvite.append(People(document!.documentID, document?.data()!["email"] as! String))
                    self.peopleView.reloadData()
                })
            }
        }
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
        if ((titleTask.text!.count == 0) || (taskDescription.text!.count == 0)){
            return
        }
        if (idTask == nil){
            idTask = randomString(len: 10)
        }
        let taskRef = db.collection("tasks").document(idTask!).setData(["title": titleTask.text!, "date": self.dateFormatter.string(from: EHdatePicker.date), "description": taskDescription.text!, "important": important], options: SetOptions.merge()) { (err) in
            self.navigationController?.popViewController(animated: true)
        }
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
       
        for people in peopleToInvite{
            let taskuserRef = db.collection("TasksToUser").whereField("tasksId", isEqualTo: idTask).whereField("userId", isEqualTo: people.id).getDocuments { (querySnapshot, err) in
                if (err != nil){
                    print(err)
                } else{
                    for document in querySnapshot!.documents{
                        return
                    }
                }
                self.db.collection("TasksToUser").document().setData(["tasksId": self.idTask, "userId": people.id], options: SetOptions.merge())
            }
        }
    }
    
    @IBAction func importantPressed(_ sender: Any) {
        if (important == nil){
            important = false
        }
        else{
            important = !important!
        }
        if (important == true){
            importantButton.alpha = 1
        }
        else{
            importantButton.alpha = 0.2
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "addPeople"){
            let destination = segue.destination as! SearchViewController
            destination.previousView = self
            destination.callback = peopleView
        }
        print(peopleToInvite.count)
    }
    
}
