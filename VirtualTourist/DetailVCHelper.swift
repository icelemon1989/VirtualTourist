//
//  DetailVCHelper.swift
//  VirtualTourist
//
//  Created by Yang Ji on 12/21/16.
//  Copyright © 2016 Yang Ji. All rights reserved.
//

import CoreData
import MapKit

extension DetailPinViewController {
    
    // MARK: Creating a Fetched Results Controller -- initi
    func initializeFetchedResultsController() -> NSFetchedResultsController<Photo> {
        let request = NSFetchRequest<Photo>(entityName: "Photo")
        request.predicate = NSPredicate(format: "pin = %@", self.curPin)
        request.sortDescriptors = []
        
        let localFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        localFetchedResultsController.delegate = self
        
        return localFetchedResultsController
    }
    
    // MARK: -init and configuration func
    func initializeAllGlobalVars() {
        fetchedResultsController = initializeFetchedResultsController()
        flickrClient = FlickrClient.sharedClient()
        controllerUtilities = ControllerUtilites.sharedUtilites()
        
        /* Set up collection View Flow Layout */
        setupCollectionViewFlowLayout()
        
        /* setup top map to display the pin on the map*/
        configureMapView(pin: curPin, mapRegion: curMapRegion)
        
        /* comform collectionView delegate and dataSource */
        collectionView.delegate = self
        collectionView.dataSource = self
        //collectionView.prefetchDataSource = self
    }
    
    func setupCollectionViewFlowLayout() {
        
        let space : CGFloat = 3.0
        let dimension = (view.frame.size.width - 2 * space) / 3.0
        
        cvFlowLayout.minimumLineSpacing = space
        cvFlowLayout.minimumInteritemSpacing = space
        cvFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    // MARK: -MapView properity configurate and add annotation
    func configureMapView(pin: Pin, mapRegion: MKCoordinateRegion) {
        // display current Pin
        mapView.addAnnotation(curPin)
        // set mapview properties
        mapView.setCenter(curPin.coordinate, animated: true)
        mapView.setRegion(curMapRegion, animated: true)
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.sizeToFit()
    }
    
    // MARK: -Help Function refreshFetchResult
    func refreshFetchResult() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    // MARK: -Delete Existing Photo in Core Data
    func deleteExistingPhototsInCoreData() {
        for photo in fetchedResultsController.fetchedObjects! as [Photo] {
            sharedContext.delete(photo)
        }
        CoreDataStack.sharedInstance().saveContext()
    }

    
}
