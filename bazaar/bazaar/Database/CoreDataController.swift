//  CoreDataController.swift
//  bazaar


import CoreData
import UIKit

//The CoreDataController implements our DataBaseProtocol and thus its defined functions, we implement
//all necessary functions for operations related to core data such as adding/removing general items aswell as
//creating listeners and updating core data database changes aswell as operations on the persistent container.

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
   
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var allGeneralItemsFetchedResultsController: NSFetchedResultsController<GeneralItem>?
    
    //Initiliaser, creates persistent container to store data.
    override init() {
    persistentContainer = NSPersistentContainer(name: "BazaarDataModel")
    persistentContainer.loadPersistentStores() { (description, error) in
        if let error = error {
            fatalError("Failed to load core data stack with error: \(error)")
            }
        }
        super.init()
    }
    
    //Cleanup function that saves changes to our persistent storage
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do{
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to core data \(error)")
            }
        }
    }
    
    //addListener function adds a listener which listens for changes based on set type
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .generalItem{
            listener.onGeneralItemChange(change: .update, generalItem: fetchAllGeneralItems())
        }
    }
    
    //removeListener removes listener
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    //addGeneralItem function creates and adds a generalItem object to our persistent storage
    func addGeneralItem(name: String, value: Double, type: String, symbol:String) -> GeneralItem {
        let genItem = NSEntityDescription.insertNewObject(forEntityName: "GeneralItem", into: persistentContainer.viewContext) as! GeneralItem
        genItem.name = name
        genItem.value = value
        genItem.type = type
        genItem.symbol = symbol
        return genItem
    }
    
    //Removes item from persistent storage
    func removeGeneralItem(generalItem: GeneralItem) {
        persistentContainer.viewContext.delete(generalItem)
    }
    
    //Function to fetch all general items stored within core data
    func fetchAllGeneralItems() -> [GeneralItem] {
        
        if allGeneralItemsFetchedResultsController == nil {
            
            let request: NSFetchRequest<GeneralItem> = GeneralItem.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSortDescriptor]
            
            allGeneralItemsFetchedResultsController = NSFetchedResultsController<GeneralItem>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allGeneralItemsFetchedResultsController?.delegate = self
   
            do {
                try allGeneralItemsFetchedResultsController?.performFetch()
            } catch {
                print("fetch failed")
            }
        }
        
        if let genItems = allGeneralItemsFetchedResultsController?.fetchedObjects {
            return genItems
        }
        
        return[GeneralItem]()
    }
    
    //Deprecated
    func createDefaultGeneralItems() {
        //
    }
    
    //Function to invoke in tandem with our fetched results controller in fetchAllMeals
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allGeneralItemsFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .generalItem {
                    listener.onGeneralItemChange(change: .update, generalItem: fetchAllGeneralItems())
                }
            }
        }
    }
    
    //Function to edit existing items in core data
    func editItem(name:String, value:Double, symbol:String, type:String){
           
            var genItem = [GeneralItem]()
            
            let request: NSFetchRequest<GeneralItem> = GeneralItem.fetchRequest()
            let predicate = NSPredicate(format: "symbol =%@", symbol)
            
            request.predicate = predicate
            
            do{
                try genItem = persistentContainer.viewContext.fetch(request)
            } catch {
                print("fetch item error")
            }
            
            if let curItem = genItem.first {
                persistentContainer.viewContext.delete(curItem)
                let _ = addGeneralItem(name: name, value: value, type: type, symbol: symbol)
            }
            
            do{
                
            try persistentContainer.viewContext.save()
            
            } catch {
                print("fail save")
            }
                
            
    }
}

