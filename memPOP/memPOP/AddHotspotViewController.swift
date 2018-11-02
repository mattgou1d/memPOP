//
//  AddHotspotViewController.swift
//  memPOP
//
//  Created by Emily on 2018-10-23.
//  Copyright © 2018 Iota Inc. All rights reserved.
//
import CoreData
import UIKit

class AddHotspotViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UICollectionViewDelegate,UICollectionViewDataSource, UITableViewDataSource {

    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var hotspotName: UITextField!
    @IBOutlet weak var hotspotAddress: UITextField!
    @IBOutlet weak var hotspotTransportation: UISegmentedControl!
    @IBOutlet weak var hotspotCategory: UISegmentedControl!
    @IBOutlet weak var hotspotInfo: UITextView!
    @IBOutlet weak var hotspotTodoList: UITextView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    var descriptionPlaceholder: UILabel!
    var categoryChosen:String = ""
    var transportationChosen:String = ""
    
    var addedImages = [UIImage]()
    var hotspots = [HotspotMO]()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var todoItem: UITextField!
    
    let image = UIImagePickerController()
    
    @IBAction func ImportPhoto(_ sender: Any) {
    
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        image.allowsEditing = false
        self.present(image, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        if let imagePicked = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            addedImages.append(imagePicked)
            print("picked pass")
        }
        else
        {
            print("fail")
        }
        collectionView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    //==================================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add a border around the description UI textfield, and image view
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.black.cgColor
        //imageView.layer.borderWidth = 1
        //imageView.layer.borderColor = UIColor.black.cgColor
        hotspotName.delegate = self
        hotspotAddress.delegate = self
        
        //------------------------------------------------------------------------------------------------
        // Add placeholder text for text view
        // https://stackoverflow.com/questions/27652227/text-view-placeholder-swift
        descriptionTextView.delegate = self
        descriptionPlaceholder = UILabel()
        descriptionPlaceholder.text = "Who did you go with? What did you do?"
        descriptionPlaceholder.sizeToFit()
        descriptionTextView.addSubview(descriptionPlaceholder)
        descriptionPlaceholder.frame.origin = CGPoint(x: 5, y: (descriptionTextView.font?.pointSize)! / 2)
        descriptionPlaceholder.textColor = UIColor.lightGray
        descriptionPlaceholder.isHidden = !descriptionTextView.text.isEmpty
        //------------------------------------------------------------------------------------------------
        
        //------------------------------------------------------------------------------------------------
        // Done button should only be enabled when the hotspot and address is filed
        doneButton.isEnabled = false
        [hotspotName, hotspotAddress].forEach({ $0.addTarget(self, action: #selector(editChanged), for: .editingChanged) })

    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = false
        //self.navigationItem .setHidesBackButton(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(_ descriptionTextView: UITextView) {
        descriptionPlaceholder.isHidden = !descriptionTextView.text.isEmpty
    }
    
    //==================================================================================================
    var list = ["My To-Do List"]
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (list.count)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = list[indexPath.row]
        return(cell)
    }
    
    // delete an item by a left swipe
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            self.list.remove(at:indexPath.row)
            tableView.reloadData()
        }
        
    }
    
    @IBAction func addToDo(_ sender: Any)
    {
        if (todoItem.text != "")
        {
            list.append("- " + todoItem.text!)
            todoItem.text = ""
            tableView.reloadData()
        }
    }
    //==================================================================================================
    @IBAction func donePressed(_ sender: UIButton) {
        let name = hotspotName.text!
        let address = hotspotAddress.text!
        
        let newHotspot = HotspotMO(context: PersistenceService.context)
        let newPhotos = PhotosMO(context: PersistenceService.context)
        newHotspot.name = name
        newHotspot.address = address
        
        /*
        if(hotspotCategory.selectedSegmentIndex == 1) {
            newHotspot.category = hotspotCategory.titleForSegment(at: 1)!
        }
        else if (hotspotCategory.selectedSegmentIndex == 2) {
            newHotspot.category = hotspotCategory.titleForSegment(at: 2)!
        }
        else if (hotspotCategory.selectedSegmentIndex == 3) {
            newHotspot.category = hotspotCategory.titleForSegment(at: 3)!
        }
        else {
            newHotspot.category = hotspotCategory.titleForSegment(at: 0)!
        }
        
        if(hotspotTransportation.selectedSegmentIndex == 1) {
            newHotspot.transportation = hotspotTransportation.titleForSegment(at: 1)!
        }
        else {
            newHotspot.transportation = hotspotTransportation.titleForSegment(at: 0)!
        }
        
        if(hotspotTodoList.text != nil) {
            newHotspot.todoList = hotspotTodoList.text! as String
        }
        
        if(hotspotInfo.text != nil) {
            newHotspot.info = hotspotInfo.text! as String
        }
         
        if(hotspotImage.image != nil) {
            newHotspot.picture = UIImageJPEGRepresentation(hotspotImage.image!, 1)! as NSData
        }
        */
        
        newPhotos.photo = UIImageJPEGRepresentation(addedImages[0], 1)! as NSData
        
        newHotspot.addToPhotos(newPhotos)
    
        PersistenceService.saveContext()
        
        self.hotspots.append(newHotspot)
    }
    
    // Show an alert when the user wants to delete a hotspot
    @IBAction func deleteButtonIsTapped(_ sender: UIButton) {
        // Create the alert
        let alert = UIAlertController(title: "Deleting Hotspot", message: "Are you sure you wish to delete this Hotspot? Changes will not be saved.", preferredStyle: .alert)
        
        // Create the actions
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            (action:UIAlertAction) in
            print ("pressed Delete")
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            (action:UIAlertAction) in
            print ("pressed Cancel")
        }
        
        // Add actions to alert
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        // Show the alert
        self.present(alert,animated: true, completion: nil)
    }
    
    
    //==================================================================================================
    // The name and address fields must be filed before the done button is enabled
    //https://stackoverflow.com/questions/34941069/enable-a-button-in-swift-only-if-all-text-fields-have-been-filled-out
    @objc func editChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let name = hotspotName.text, !name.isEmpty,
            let address = hotspotAddress.text, !address.isEmpty
            else {
                doneButton.isEnabled = false
                return
        }
        doneButton.isEnabled = true
    }
    //==================================================================================================

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return addedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:  CollectionViewPhotos = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPhotos", for: indexPath) as! CollectionViewPhotos
        
        cell.image.image = addedImages[indexPath.row]
        
        // Set the value of the index at which the image is added to key "index"
        cell.deletePhotoButton?.layer.setValue(indexPath.row, forKey: "index")
        // Call the deletePhoto to delete the image at a particular index
        cell.deletePhotoButton?.addTarget(self, action: #selector((deletePhoto(sender:))), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    
    // Delete image from CollectionView Object
    @objc func deletePhoto(sender:UIButton) {
        let i : Int = (sender.layer.value(forKey: "index")) as! Int
        addedImages.remove(at: i)
        print("Removed image.")
        collectionView.reloadData()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
