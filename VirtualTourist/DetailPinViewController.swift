//
//  DetailPinViewController.swift
//  VirtualTourist
//
//  Created by Yang Ji on 11/10/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailPinViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: -Properties
    var curPin : Pin!
    var curMapRegion : MKCoordinateRegion!
    var flickrClient : FlickrClient!
    var controllerUtilities : ControllerUtilites!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var sharedContext : NSManagedObjectContext{
        return CoreDataStack.sharedInstance().persistentContainer.viewContext
    }
    
    // MARK: -IBOutles
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionButtonOutlet: UIButton!
    @IBOutlet weak var noImageLabel: UILabel!
    
    // store updated indexes, this is used in fetch result delegate
    var blockOperations: [BlockOperation] = []

    // MARK: -LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        noImageLabel.isHidden = true
        collectionView.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize all the shits with global variable
        initializeAllGlobalVars()
        
        refreshFetchResult()
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            // when downloading disable button
            self.newCollectionButtonOutlet.isEnabled = false
            downloadImages(pin: curPin)
//            flickrClient.downloadImagesForPin(
//                curPin: self.curPin,
//                completionHandler: {(sucess, error) in
//                guard (error == nil) else {
//                    self.controllerUtilities.showErrorAlert(title: "Download Fail in Detail VC", message: (error?.localizedDescription)!)
//                    return
//                }
//                    
//                if sucess {
//                    self.refreshFetchResult()
//                    // If still zero, edge case
//                    if self.fetchedResultsController.fetchedObjects?.count == 0 {
//                        self.collectionView.isHidden = true
//                        self.noImageLabel.isHidden = false
//                    }
//                }
//                self.newCollectionButtonOutlet.isEnabled = true
//            })
        }
    
    }
   
    @IBAction func pressNewCollectionButton(_ sender: UIButton) {
        self.newCollectionButtonOutlet.isEnabled = false
        deleteExistingPhototInCoreData()
        downloadImages(pin: curPin)
        
    }
    
    func downloadImages(pin: Pin) {
        flickrClient.downloadImagesForPin(curPin: pin) { (sucess, error) in
            guard (error == nil) else {
                self.controllerUtilities.showErrorAlert(title: "Download Fail in Detail VC", message: (error?.localizedDescription)!)
                return
            }
            if sucess {
                self.refreshFetchResult()
                // If still zero, edge case
                if self.fetchedResultsController.fetchedObjects?.count == 0 {
                    self.collectionView.isHidden = true
                    self.noImageLabel.isHidden = false
                }
            }
            self.newCollectionButtonOutlet.isEnabled = true
        }
    }
    
    func deleteExistingPhototInCoreData() {
        for photo in fetchedResultsController.fetchedObjects! as [Photo] {
            sharedContext.delete(photo)
        }
        CoreDataStack.sharedInstance().saveContext()
    }
}

