//
//  mainDisplayViewController.swift
//  memPOP
//
//  Created by Emily on 2018-10-23.
//  Copyright © 2018 Iota Inc. All rights reserved.
//

import UIKit
import CoreData

class mainDisplayViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var arrLabel = [String]()
    var arrImg = [UIImage]()
    var addedImages = [NSManagedObject]()
    var addedToDos = [NSManagedObject]()
    
    var hotspots = [HotspotMO]()
    var photo: PhotosMO?
    
    var mainEditIsTapped : Bool = false;
    let headerID = "headerID"
    
    @IBOutlet weak var collectionView: UICollectionView! // = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout.init())
    
    let fetchRequest: NSFetchRequest<HotspotMO> = HotspotMO.fetchRequest()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func load () {
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.relationshipKeyPathsForPrefetching = ["photos"]

        do {
            let hotspots = try PersistenceService.context.fetch(fetchRequest)
            self.hotspots = hotspots
        } catch {
            print("failed fetching")
        }
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        load()
        self.collectionView.reloadData()
       
        if(mainEditIsTapped) {
            collectionView.reloadData()
        }
        mainEditIsTapped = false
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func mainEditTapped(_ sender: UIButton) {
        mainEditIsTapped = !mainEditIsTapped
        collectionView.reloadData()
        print("MainEditTapped")
        
    
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotspots.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        if(hotspots[indexPath.row].photos?.anyObject() != nil){
            let photosMO = hotspots[indexPath.row].photos?.allObjects
            let photo = photosMO![0] as! PhotosMO
            if(photo.photo != nil){
                cell.image.image = (UIImage(data: photo.photo! as Data))
            } else {
                cell.image.image = (UIImage(named: "defaultPhoto"))
            }
        } else {
            cell.image.image = (UIImage(named: "defaultPhoto"))
        }
       // cell.label.text = arrLabel[indexPath.row]
 
        
       // let photosMO = hotspots[indexPath.row].photos?.allObjects
       // let photo = (photosMO[0] as AnyObject).value(forKey: "photo")
        //cell.image.image = (UIImage(data: photo as! Data))
        cell.label.text = hotspots[indexPath.row].name
        //cell.label.text = arrLabel[indexPath.row]


        // Check if editing is enabled, if it is, show a white border around all hotspots and show a gear icon
        if(mainEditIsTapped) {
            cell.cellEditButton.isHidden = false
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 3
        } else {
            cell.cellEditButton.isHidden = true
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 0
        }
        
        return cell
    }
 
    // checks which hotspot user selected
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(String(indexPath.row))
        print("tapped hotspot")
        
        let overviewVC = storyboard?.instantiateViewController(withIdentifier: "HotspotOverviewViewController") as! HotspotOverviewViewController
        overviewVC.selectedHotspot = hotspots[indexPath.row]
        
   
        for photo in (hotspots[indexPath.row].photos?.allObjects)! {
            addedImages.append(photo as! NSManagedObject)
        }
        
        for toDoItem in (hotspots[indexPath.row].toDo?.allObjects)! {
            addedToDos.append(toDoItem as! NSManagedObject)
        }
        
        overviewVC.addedImages = addedImages
        overviewVC.addedToDos = addedToDos
        
        // remove all so that previous selections objects are not also passed 
        addedImages.removeAll()
        addedToDos.removeAll()
        
        navigationController?.pushViewController(overviewVC, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    

}
