//  HotspotOverviewViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Emily on 2018-10-23.
//  Programmers: Matthew Gould
//  Copyright © 2018 Iota Inc. All rights reserved.

//===================================================================================================
// Changes that have been made in v1.0
// Fetching of name and description of hotspot selected
// Added a collection view to display details about the hotspot

//===================================================================================================
// Changes that have been made in v2.0
// Fetching of name, description, todo items, and photos of hotspot selected
// UI changes to clean up the look of the view controller
// Not displaying empty fields to avoid cluttering the view
// Updated navigation bar
// Created a Master view controller to switch between overview and navigation mode
// Updated collection view to scroll within the entire view

//===================================================================================================
// Changes that have been made in v3.0
// Added constraint variables to hide/show different UI elements within the code

import CoreData
import UIKit

class HotspotOverviewViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource {
    
    //===================================================================================================
    // MARK: Variables declaration
    //===================================================================================================
    var addedToDos = [NSManagedObject]()
    var addedImages = [NSManagedObject]()
    var selectedHotspot: NSManagedObject?
    
    //===================================================================================================
    // MARK: Outlets
    //===================================================================================================
    @IBOutlet var toDoTable: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var descriptionView: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var toDoTableHeight: NSLayoutConstraint!
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet var toDoListLabel: UILabel!
    @IBOutlet var photosLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var toDoListHeight: NSLayoutConstraint!
    @IBOutlet var descriptionHeight: NSLayoutConstraint!
    @IBOutlet var photosSpace: NSLayoutConstraint!
    @IBOutlet var descriptionSpace: NSLayoutConstraint!
    @IBOutlet var descriptionSpaceTrailing: NSLayoutConstraint!
    
    //===================================================================================================
    // MARK: Override Functions
    //===================================================================================================
    override func viewDidLoad() {
        
        // Set up to do table, description label and collection view with dynamic height
        toDoTable.bounces = false
        toDoTable.isScrollEnabled = false
        toDoTable.reloadData()
        toDoTable.layoutIfNeeded()
        toDoTableHeight.constant = toDoTable.contentSize.height
        
        // Hide the label if there are no ToDos
        if (toDoTableHeight.constant == 0){
            toDoListLabel.isHidden = true
            toDoTableHeight.constant = 0
            toDoListHeight.constant = 0 
            descriptionSpace.constant = 0
        }
        else {
            toDoTableHeight.constant = toDoTable.contentSize.height
            descriptionSpace.constant = 30
        }
        
        // Fetch and display the description of the hotspot selected
        descriptionView.text = ((selectedHotspot?.value(forKey: "info")) as? String)
        
        // Hide the text view if there is no description
        if(descriptionView.text == nil){
            descriptionLabel.isHidden = true
            descriptionHeight.constant = 0
            photosSpace.constant = 0
            descriptionSpaceTrailing.constant = 0
        }
        else if(descriptionView.text?.isEmpty)!{
            descriptionLabel.isHidden = true
            descriptionHeight.constant = 0
            photosSpace.constant = 0
            descriptionSpaceTrailing.constant = 0
        }
        else {
            photosSpace.constant = 30
            descriptionHeight.constant = 40
            descriptionSpaceTrailing.constant = 10 
        }
        
        collectionView.bounces = false
        collectionView.isScrollEnabled = false
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionViewHeight.constant =  collectionView.contentSize.height
        
        // Hide the collection view if there are no photos
        if (collectionView.numberOfItems(inSection: 0) == 0){
            photosLabel.isHidden = true 
        }
    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //===================================================================================================
    // MARK: Functions
    //===================================================================================================
    public func tableView(_ toDoTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Returns the number of ToDos for the hotspot selected
        return addedToDos.count
    }
    
    // Load To-Do List
    public func tableView(_ toDoTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Use the single "photoCell" cell created in the storyboard as a template for every ToDo item
        let toDoCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cellToDo")
    
        toDoCell.textLabel?.text = (addedToDos[indexPath.row].value(forKey: "toDoItem") as! String)
        toDoCell.backgroundColor = UIColor(red:0.16, green:0.19, blue:0.21, alpha:1.0)
        toDoCell.textLabel?.textColor = UIColor.white
        
        return(toDoCell)
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Returns the number of photos for the hotspot selected
        return addedImages.count
    }
    
    // Load photos
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Use the single "photoCellOnly" cell created in the storyboard as a template for every Photo item
        let photoOnlyCell:  CollectionViewPhoto = collectionView.dequeueReusableCell(withReuseIdentifier: "photoOnlyCell", for: indexPath) as! CollectionViewPhoto
        
        // Check if there are no images or if nil
        let imageData = addedImages[indexPath.row].value(forKey: "photo")
        if(imageData != nil){
            let image = UIImage(data: imageData as! Data)
            photoOnlyCell.image.image = image
        }
        else {
            photoOnlyCell.image.image = (UIImage(named: "defaultPhoto"))
        }
        
        return photoOnlyCell
    }
    
}

