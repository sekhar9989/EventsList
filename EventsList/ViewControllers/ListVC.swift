

import UIKit

class ListVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tblVwDetails: UITableView!
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblNoRecords: UILabel!
    @IBOutlet weak var colVw: UICollectionView!
    
    //MARK:- Variables
    var from = Int()
    var arrSelected = [Dictionary<String, Any>]()
    var scrollingUp = true
    var lastContentOffset: CGFloat = 0
    
    //MARK:- View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        objDataHelper.fetchData()
        lblHeader.text = "\(objDataHelper.arrType[from]) Events"
        let str = objDataHelper.arrType[from]
        let strValue = "Click on '+' to add events to '\(str) category'"
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: strValue)
        attributedString.setColor(color: #colorLiteral(red: 0.1171190515, green: 0.1793293953, blue: 0.2407048345, alpha: 1) , forText: str)
        attributedString.setColor(color: #colorLiteral(red: 0.1171190515, green: 0.1793293953, blue: 0.2407048345, alpha: 1) , forText: "+")
        lblNoRecords.attributedText = attributedString
        switch from {
        case 0:
            arrSelected = objDataHelper.arrPersonal
        case 1 :
            arrSelected = objDataHelper.arrProfessional
        case 2 :
            arrSelected = objDataHelper.arrSocial
        case 3 :
            arrSelected = objDataHelper.arrOthers
        default:
            break
        }
        
        tblVwDetails.animateTable()
        tblVwDetails.isHidden = arrSelected.count == 0
    }
    
    //MARK:- IBActions
    @IBAction func actionAdd(_ sender: Any) {
        pushTo(VC: "CreateVC")
    }
    
}

extension ListVC: UITableViewDelegate, UITableViewDataSource, UIDropInteractionDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSelected.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTVC", for: indexPath) as! ListTVC
        let dict = arrSelected[indexPath.row]
        cell.lblTitle.text = dict["title"] as? String
        cell.lblTime.text = dict["date"] as? String
        var img = UIImage()
        if (dict["img1"] as? String)?.count ?? 0 > 3 {
            cell.imgVw.image = ConvertBase64StringToImage(imageBase64String: dict["img1"] as? String ?? "") as UIImage
        } else {
            switch from {
            case 0 :
                img = #imageLiteral(resourceName: "schedule")
            case 1:
                img = #imageLiteral(resourceName: "time-and-date")
            case 2:
                img = #imageLiteral(resourceName: "event")
            case 3:
                img = #imageLiteral(resourceName: "calendar")
            default:
                break
            }
            cell.imgVw.image = img
        }
        cell.lblTime.superview?.layer.shadowColor = getHueColor(Float(indexPath.row), 20).cgColor
        cell.imgVw.layer.shadowColor = getHueColor(Float(indexPath.row), 20).cgColor

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "FullDetailsVC") as! FullDetailsVC
        nextVC.dict = arrSelected[indexPath.row]
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let modifyAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let dict = self.arrSelected[indexPath.row]
            objDataHelper.delete(VC: self, selected: dict["id"] as! Int)
            self.viewWillAppear(true)
            success(true)
        })
        modifyAction.image = UIImage(named: "bin")
        modifyAction.backgroundColor = #colorLiteral(red: 0.1836382151, green: 0.3331800103, blue: 0.5062610507, alpha: 1)
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
    
}

extension ListVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCVC", for: indexPath) as! HomeCVC
        cell.lbl.text = objDataHelper.arrType[indexPath.item]
        cell.vwBackGround.layer.shadowColor = from == indexPath.row ? #colorLiteral(red: 0.1836382151, green: 0.3331800103, blue: 0.5062610507, alpha: 1).cgColor:UIColor.clear.cgColor
        cell.vwBackGround.backgroundColor = from == indexPath.row ? #colorLiteral(red: 0.1836382151, green: 0.3331800103, blue: 0.5062610507, alpha: 1) : .white
        cell.lbl.textColor = from == indexPath.row ? .white : #colorLiteral(red: 0.1836382151, green: 0.3331800103, blue: 0.5062610507, alpha: 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(rotationAngle: 90)
        UIView.animate(withDuration: 0.5) {
            cell.transform = CGAffineTransform.identity
            self.view.layoutIfNeeded()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        from = indexPath.item
        collectionView.reloadData()
        viewWillAppear(true)
    }
}
