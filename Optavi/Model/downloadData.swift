import Foundation
import Alamofire

class downloadData
{
    var storedDataArray = [downloadData]()
    
    private var _itemIMG:String!
    private var _itemAdType:String!
    private var _itemPrice:String!
    private var _itemTitle:String!
    private var _itemLocation:String!
    private var _itemId:String!
    
    var itemIMG:String
    {
        get
        {
            if _itemIMG == nil
            {
                _itemIMG = ""
                
            }
            return _itemIMG
        }
        set
        {
            _itemIMG = newValue
        }
    }
    var itemAdType:String
    {
        return _itemAdType
    }
    var itemPrice:String
    {
        get
        {
            if _itemPrice == nil
            {
                _itemPrice = ""
                
            }
            return _itemPrice
        }
        set
        {
            _itemPrice = newValue
        }
    }
    var itemTitle:String
    {
        get
        {
            if _itemTitle == nil
            {
                _itemTitle = ""
                
            }
            return _itemTitle
        }
        set
        {
            _itemTitle = newValue
        }
    }
    var itemLocation:String
    {
        get
        {
            if _itemLocation == nil
            {
                _itemLocation = ""
                
            }
            return _itemLocation
        }
        set
        {
            _itemLocation = newValue
        }
    }
    var itemId:String
    {
        get
        {
            return _itemId
        }
        set
        {
            _itemId = newValue
        }
    }
    
    //Inside this initialiser we hand-pick every bit of information that we want to store for later use.
    init (itemObjects: Dictionary<String,AnyObject>)
    {
        if let image = itemObjects["image"]
        {
            if let url = image["url"] as? String
            {
                let urlMerge = ("\(IMG_URL)\(url)")
                _itemIMG = urlMerge
            }
        }
        if let adType =  itemObjects["ad-type"] as? String
        {
            _itemAdType = adType
        }
        if let price = itemObjects["price"]
        {
            if let value = price["value"] as? Double
            {
                _itemPrice = "\(String(format: "%.0f",value)),-"
            }
        }
        if let description = itemObjects["description"] as? String
        {
            _itemTitle = description
        }
        if let location = itemObjects["location"] as? String
        {
            _itemLocation = location
        }
        if let id = itemObjects["id"] as? String
        {
            _itemId = id
        }
    }
    
    //We use pod alamofire to get data response in JSON. Since we have to dig into the JSON response.result.value we have to cast all the the constants as the correct types. At one point we will get an array with dictionary items. We will iterate through the entire array. For each of the items we will run the initialiser so we can get all the nitty gritty bits and pieces we're looking for. Mark as complete when finished.
    func jsonRequest(completed: @escaping downloadComplete)
    {
        Alamofire.request(BASE_URL).responseJSON
        {
            (response) in
            if let dict = response.result.value as? Dictionary<String, AnyObject>
            {
                if let items = dict["items"] as? [Dictionary<String, AnyObject>]
                {
                    for obj in items
                    {
                        let storeData = downloadData(itemObjects: obj)
                        self.storedDataArray.append(storeData)
                    }
                }
            }
            completed()
        }
    }
}
