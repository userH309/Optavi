import UIKit
import HidingNavigationBar

class mainVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var favBtnLbl: UIBarButtonItem!
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var realestateBtn: UIButton!
    @IBOutlet weak var jobBtn: UIButton!
    @IBOutlet weak var carBtn: UIButton!
    @IBOutlet weak var booksBtn: UIButton!
    
    var favBtnStatus:Bool!
    var btnSelect = ""
    var navBarHideManager:HidingNavigationBarManager?
    var downloadedData = downloadData(itemObjects: ["":"" as AnyObject])
    var favStorageInstance = favStorage()
    var filterArray = [downloadData]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        navBarHideManager = HidingNavigationBarManager(viewController: self, scrollView: itemsTableView)
        buttonSelected()
        favBtnStatus = false
        favStorageInstance.load()
        //We want to start downloading data as soon as the view loads. The download is marked completed when we have the data we want. Since the tableview does not contain anything yet, we have to reload the tableview in order to trigger the tableview function underneath, so the user can actually see the data we fetched.
        downloadedData.jsonRequest
        {
            self.filterArray = self.downloadedData.storedDataArray
            self.itemsTableView.reloadData()
        }
    }
    
    //We use the pod HidingNavigationBar to get a better user experience. When customer scrolls down, the nav bar will hide, when user scrolls up he/she will see the nav bar again.
    override func viewWillAppear(_ animated: Bool)
    {
        navBarHideManager?.viewWillAppear(true)
    }
    override func viewDidLayoutSubviews()
    {
        navBarHideManager?.viewDidLayoutSubviews()
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        navBarHideManager?.viewWillDisappear(true)
    }
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool
    {
        navBarHideManager?.shouldScrollToTop()
        return true
    }
    
    //We want our every row in the tableview to have a height of 170 so our data can fit inside of them.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 170.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //User will select the array by tapping/not tapping the "favoritter" button. depending on this, we need to have enough rows so we can present all elements in the selected array to the tableview.
        if favBtnStatus == false
        {
            return filterArray.count
        }
        else
        {
            return favStorageInstance.favArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //Use a dequeReusableCell so when a cell goes offscreen it will be reused when scrolling, this way is more memory efficient.
        if let cell = itemsTableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? itemCell
        {
            if favBtnStatus == false
            {
                //We mainly pump out elements from the filterArray since the "favoritter" button is not tapped, if we detect that favArray has an element with the same itemID, we need to know the index number to the element in the favArray. If we try to get the element using the indexPath.row we will get an error "index out of range" because the amount of rows depends on the number of elements in the filterArray, which is most cases is a bigger array.
                if let i = favStorageInstance.favArray.index(where:
                    { $0.itemId == filterArray[indexPath.row].itemId })
                {
                    //For the user to distinguish between a favourite/non favourite we have either a filled heart or an empty, heartStatus true/false, configureCell function use this info to set the image accordingly.
                    cell.configureCell(item: favStorageInstance.favArray[i], heartStatus: true)
                }
                else
                {
                    cell.configureCell(item: filterArray[indexPath.row], heartStatus: false)
                }
            }
            else
            {
                //We want the user to have the opportunity see only his/her favourites by tapping the "favoritter" button. We use the load function so user can see the favourites wether the device is online/offline, app is closed or the device has been turned off/on.
                let favData = favStorageInstance.favArray[indexPath.row]
                cell.configureCell(item: favData, heartStatus: true)
            }
            return cell
        }
        else
        {
            return UITableViewCell()
        }
    }
    
    //By using the didSelectRow, we know what row the user tapped. We need to know this in order to change the data in that specific cell.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let cell = itemsTableView.cellForRow(at: indexPath) as? itemCell
        {
            storageHandler(theIndexPath: indexPath, theCell: cell)
        }
    }
    
    //This function will be triggered when the user tap on a row. We have two main statements because user can decide to view all data or only favourites.
    func storageHandler(theIndexPath: IndexPath, theCell:itemCell)
    {
        //The favBtnStatus is false tells us that the user has not tapped the "favoritter button".
        if favBtnStatus == false
        {
            //Two things can happen when selecting a row. 1: The data is already stored in the favourites array favArray, in that case we use the /* 1 - Getting index number, then store. */ trick as mentioned above, but instead of storing, we will remove it from the array, user can now see an empty heart.
            if let i = favStorageInstance.favArray.index(where:
                { $0.itemId == filterArray[theIndexPath.row].itemId })
            {
                theCell.configureCell(item: favStorageInstance.favArray[i], heartStatus: false)
                favStorageInstance.removeObject(id: favStorageInstance.favArray[i].itemId)
                favStorageInstance.favArray.remove(at: i)
            }
            else
            {
                //2: The row selected is not a favourite, data will then be stored in the favourite array, user will see a filled heart.
                let data = filterArray[theIndexPath.row]
                theCell.configureCell(item: data, heartStatus: true)
                favStorageInstance.toStorage(favData: data)
            }
        }
        if favBtnStatus == true
        {
            //favBtnStatus == true tells us that the user has tapped the "favoritter" button. This information tells us that user can only see his favorites. That means when tapping a cell it will be removed.
            favStorageInstance.removeObject(id: favStorageInstance.favArray[theIndexPath.row].itemId)
            favStorageInstance.favArray.remove(at: theIndexPath.row)
            itemsTableView.reloadData()
        }
    }
    
    //This function runs when user tap the "favoritter" button. If user has favourites, he/she will now see them. The "Favoritter" will change title to "Alle", and vice versa if the user tap again. This indicates which array we load from.
    @IBAction func favButtonTapped(_ sender: UIBarButtonItem)
    {
        if favBtnLbl.title == "Favoritter"
        {
            bottomView.isHidden = true
            favBtnLbl.title = "Alle      "
            favBtnStatus = true
            scrollTop()
        }
        else
        {
            bottomView.isHidden = false
            favBtnLbl.title = "Favoritter"
            favBtnStatus = false
            scrollTop()
        }
    }
    
    //User can sort the data displayed on screen based on what button user tap in the bottom bar. User has five options: view all, realestate, job, car or books. As default we fill up the filterArray with data that we got from the JSON response. Every element in this array has its own AdType identifier. We choose to filter and store elements based on this identifier.
    @IBAction func allBtnTapped(_ sender: UIButton)
    {
        btnSelect = "all"
        buttonSelected()
        filterArray = downloadedData.storedDataArray
        scrollTop()
    }
    @IBAction func realestateBtnTapped(_ sender: UIButton)
    {
        btnSelect = "realestate"
        buttonSelected()
        filterArray = downloadedData.storedDataArray.filter({ $0.itemAdType == "REALESTATE"})
        scrollTop()
    }
    @IBAction func jobBtnTapped(_ sender: UIButton)
    {
        btnSelect = "job"
        buttonSelected()
        filterArray = downloadedData.storedDataArray.filter({ $0.itemAdType == "JOB"})
        scrollTop()
    }
    @IBAction func carBtnTapped(_ sender: UIButton)
    {
        btnSelect = "car"
        buttonSelected()
        filterArray = downloadedData.storedDataArray.filter({ $0.itemAdType == "CAR"})
        scrollTop()
    }
    @IBAction func booksBtnTapped(_ sender: UIButton)
    {
        btnSelect = "books"
        buttonSelected()
        filterArray = downloadedData.storedDataArray.filter({ $0.itemAdType == "BAP"})
        scrollTop()
    }
    
    //We have to make sure that number of rows in section is bigger than 0, or else the app is going to crash since we're refering to row 0 when scrolling to top. We will not have a row if the array is empty.
    func scrollTop()
    {
        if itemsTableView.numberOfRows(inSection: 0) > 0
        {
            itemsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            itemsTableView.reloadData()
        }
        else
        {
            itemsTableView.reloadData()
        }
    }
    
    //For the user to remember what bottom bar button he tapped we render the image black for not yet tapped and blue for tapped.
    func buttonSelected()
    {
        switch btnSelect
        {
        case "realestate":
            allBtn.setImage(#imageLiteral(resourceName: "all"), for: .normal)
            realestateBtn.setImage(#imageLiteral(resourceName: "realestateSelected"), for: .normal)
            jobBtn.setImage(#imageLiteral(resourceName: "job"), for: .normal)
            carBtn.setImage(#imageLiteral(resourceName: "car"), for: .normal)
            booksBtn.setImage(#imageLiteral(resourceName: "books"), for: .normal)
        case "job":
            allBtn.setImage(#imageLiteral(resourceName: "all"), for: .normal)
            realestateBtn.setImage(#imageLiteral(resourceName: "realestate"), for: .normal)
            jobBtn.setImage(#imageLiteral(resourceName: "jobSelected"), for: .normal)
            carBtn.setImage(#imageLiteral(resourceName: "car"), for: .normal)
            booksBtn.setImage(#imageLiteral(resourceName: "books"), for: .normal)
        case "car":
            allBtn.setImage(#imageLiteral(resourceName: "all"), for: .normal)
            realestateBtn.setImage(#imageLiteral(resourceName: "realestate"), for: .normal)
            jobBtn.setImage(#imageLiteral(resourceName: "job"), for: .normal)
            carBtn.setImage(#imageLiteral(resourceName: "carSelected"), for: .normal)
            booksBtn.setImage(#imageLiteral(resourceName: "books"), for: .normal)
        case "books":
            allBtn.setImage(#imageLiteral(resourceName: "all"), for: .normal)
            realestateBtn.setImage(#imageLiteral(resourceName: "realestate"), for: .normal)
            jobBtn.setImage(#imageLiteral(resourceName: "job"), for: .normal)
            carBtn.setImage(#imageLiteral(resourceName: "car"), for: .normal)
            booksBtn.setImage(#imageLiteral(resourceName: "booksSelected"), for: .normal)
        default:
            allBtn.setImage(#imageLiteral(resourceName: "allSelected"), for: .normal)
            realestateBtn.setImage(#imageLiteral(resourceName: "realestate"), for: .normal)
            jobBtn.setImage(#imageLiteral(resourceName: "job"), for: .normal)
            carBtn.setImage(#imageLiteral(resourceName: "car"), for: .normal)
            booksBtn.setImage(#imageLiteral(resourceName: "books"), for: .normal)
        }
    }
}
