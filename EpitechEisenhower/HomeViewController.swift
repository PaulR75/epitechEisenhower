//
//  HomeViewController.swift
//  EpitechEisenhower
//
//  Created by paul on 29/03/2018.
//  Copyright © 2018 Epitech. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    fileprivate let reuseIdentifier = "EHTaskCell"
    fileprivate let itemsPerRow: CGFloat = 2.0
    fileprivate let sectionInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    var data: [String:String] = ["Test1": "Test1",
                                 "Test2": "Test2",
                                 "Test3": "Test3",
                                 "Test4": "Test4"
                                 ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //addCell.layer.cornerRadius = 5
    }
    

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count * 4
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.layer.cornerRadius = 5
        cell.backgroundColor = clearGreenColor
        return cell
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
}
