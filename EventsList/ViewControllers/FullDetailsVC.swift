
import UIKit

class FullDetailsVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblAppointment: UILabel!
    @IBOutlet weak var lblReminder: UILabel!
    @IBOutlet weak var colVwImages: UICollectionView!
    
    //MARK:- Variables
    var dict = Dictionary<String, Any>()
    var arrImages = [UIImage]()
    
    //MARK:- View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text = dict["title"] as? String
        lblHeader.text = dict["type"] as? String
        lblDescription.text = dict["note"] as? String
        lblAppointment.text = dict["date"] as? String
        lblReminder.text = dict["ocassion"] as? String

        for i in 1...5 {
            if (dict["img\(i)"] as? String)?.count ?? 0 > 3 {
                arrImages.append(ConvertBase64StringToImage(imageBase64String: dict["img\(i)"] as! String))
            }
        }
        colVwImages.reloadData()
    }
    
    //MARK:- IBActions
    @IBAction func actionBack(_ sender: Any) {
        popToBack()
    }
    @IBAction func actionEdit(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateVC") as! CreateVC
        nextVC.dict = dict
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension FullDetailsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FullDetailsCVC", for: indexPath) as! FullDetailsCVC
        cell.imgVW.image = arrImages[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "ImageVC") as! ImageVC
        nextVC.img = arrImages[indexPath.row]
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
}
