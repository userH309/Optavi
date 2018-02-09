import Foundation
import CoreData

class favStorage
{
    var favArray = [downloadData]()
    var itemArray = [Item]()
    
    //With this function we can pass on values to the save function.
    func toStorage(favData: downloadData)
    {
        save(title: favData.itemTitle, price: favData.itemPrice, location: favData.itemLocation, id: favData.itemId, img: favData.itemIMG)
        favArray.append(favData)
    }
    
    //This function is vital for retrieving the data from persistent store. This function is called when the app starts. It allows the user to see his/her data even though his device if offline. We use the fetching function for the actual retrive data job.
    func load()
    {
        fetching()
        for items in itemArray
        {
            let data = downloadData(itemObjects: ["":"" as AnyObject])
            data.itemTitle = items.title!
            data.itemPrice = items.price!
            data.itemLocation = items.location!
            data.itemId = items.itemID!
            data.itemIMG = items.imgString!
            favArray.append(data)
        }
    }
    
    //When user removes a favourite, we have to tell this to managed object context so it can be removed from persistent store. In order to know exactly what item to remove, we use the predicate class and search for the id.
    func removeObject(id:String)
    {
        let fetchRequest:NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "itemID==\(id)")
        
        if let result = try? viewContext.fetch(fetchRequest)
        {
            for object in result
            {
                viewContext.delete(object)
            }
        }
        ad.saveContext()
    }
    
    //Inside the the entity "Item" we have our data attributes, and we have to set the search criteria to take a look in correct location so that we can get our data.
    func fetching()
    {
        let fetchRequest:NSFetchRequest<Item> = Item.fetchRequest()
        do
        {
            itemArray = try viewContext.fetch(fetchRequest)
        }
        catch
        {
        }
    }
    
    //We get all the values through the parameters and then store it to our attributes. The real core data storing happens when we use saveContext.
    func save(title:String, price:String, location:String, id:String, img:String)
    {
        let context = viewContext
        let item = Item(context: context)
        item.title = title
        item.price = price
        item.location = location
        item.itemID = id
        item.imgString = img
        ad.saveContext()
    }
}
