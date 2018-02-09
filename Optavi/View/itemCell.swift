import UIKit
import SDWebImage

class itemCell: UITableViewCell
{
    @IBOutlet weak var adImg: UIImageView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var titleField: UITextView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var heartBtn: UIButton!
    
    //We use this function to take our stored data and display it to user, using labels and image.
    func configureCell(item: downloadData, heartStatus: Bool)
    {
        let urlString = item.itemIMG

        //We are using a pod called SDWebImage for displaying our image on screen based on an input url. We use this pod because it can load from the memory cache and the file cache. To avoid downloading an image two times we will check if its stored in cache. If its not in mem cache we will check file cache else we will download an store it. This makes it flexible, we could convert the image into NSData and store in core data, but it will not be as efficient.
        if let imgCached = SDImageCache.init().imageFromCache(forKey: urlString)
        {
            adImg.image = imgCached
        }
           else
        {
            let url = URL(string: urlString)
            adImg.sd_setImage(with: url, completed: nil)
        }

        priceLbl.text = item.itemPrice
        titleField.text = item.itemTitle
        locationLbl.text = item.itemLocation
        
        if heartStatus == true
        {
            heartBtn.setImage(#imageLiteral(resourceName: "heart-filled"), for: .normal)
        }
        else
        {
            heartBtn.setImage(#imageLiteral(resourceName: "heart-empty"), for: .normal)
        }
    }    
}
