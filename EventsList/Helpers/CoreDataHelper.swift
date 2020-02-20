import CoreData
import UIKit

let objDataHelper = CoreDataHelper()

class CoreDataHelper: NSObject {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context:NSManagedObjectContext!
    
    func openDatabse(VC: UIViewController,arrKeys : [String],arrValues : [String]) {
        context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Events", in: context)
        let newTask = NSManagedObject(entity: entity!, insertInto: context)
        
        if UserDefaults.standard.value(forKey: "id") == nil {
            UserDefaults.standard.set(1, forKey: "id")
        } else if UserDefaults.standard.value(forKey: "id") != nil {
            UserDefaults.standard.set(UserDefaults.standard.value(forKey: "id") as! Int + 1, forKey: "id")
        }
        
        newTask.setValue(UserDefaults.standard.value(forKey: "id"), forKey: "id")

        for i in 0..<arrKeys.count {
            newTask.setValue(arrValues[i], forKey: arrKeys[i])
        }

        
        toastMessage("Saviing..")
        do {
            try context.save()
            let alertController = UIAlertController(title: "Done", message: "Saved Successfully.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: { (Action) in
                VC.popToBack()
            })
            alertController.addAction(OKAction)
            VC.present(alertController, animated: true, completion: nil)
            fetchData()
        } catch {
            VC.alert(message: "Something went wrong, Please try again.", title: "Failed")
        }
    }
    
    //MARK:- Constants and Variables
    var arrTotalData = [Dictionary<String, Any>]()
    var arrPersonal = [Dictionary<String,Any>]()
    var arrProfessional = [Dictionary<String,Any>]()
    var arrSocial = [Dictionary<String, Any>]()
    var arrOthers = [Dictionary<String, Any>]()


    let arrType = ["Personal","Professional","Social","Others"]

    //MARK:- Custom Functions
    func fetchData() {
        arrTotalData.removeAll()
        arrPersonal.removeAll()
        arrProfessional.removeAll()
        arrSocial.removeAll()
        arrOthers.removeAll()
        
        context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                
                let id      = data.value(forKey: "id") as! Int
                let type = data.value(forKey: "type") as! String
                let name = data.value(forKey: "title") as! String
                let descriptionNote = data.value(forKey: "note") as! String
                let appointmentDate = data.value(forKey: "date") as! String
                let img1 = data.value(forKey: "img1") as! String
                let img2 = data.value(forKey: "img2") as! String
                let img3 = data.value(forKey: "img3") as! String
                let img4 = data.value(forKey: "img4") as! String
                let img5 = data.value(forKey: "img5") as! String
                let ocassion = data.value(forKey: "ocassion") as! String

                let dict = ["img1":img1,"type": type, "id": id,"note": descriptionNote,"title":name,"date":appointmentDate,"img2":img2,"img3":img3,"img4":img4,"img5":img5,"ocassion":ocassion] as [String : Any]
                arrTotalData.append(dict)
                
                switch dict["type"] as! String {
                case arrType[0] :
                    arrPersonal.append(dict)
                case arrType[1] :
                    arrProfessional.append(dict)
                case arrType[2] :
                    arrSocial.append(dict)
                case arrType[3] :
                    arrOthers.append(dict)
                default:
                    break
                }
            }
        } catch {
            toastMessage("\(error.localizedDescription)")
        }
    }
    
    func delete(VC: UIViewController, selected: Int) {
        context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        var fetchedEntities = NSArray()
        let predicate = NSPredicate(format: "id == %d", selected)
        fetchRequest.predicate = predicate
        fetchedEntities = try! context.fetch(fetchRequest) as NSArray
        do {
            for sequence in fetchedEntities {
                context?.delete(sequence as! NSManagedObject)
                do {
                    try context.save()
                    toastMessage("Deleted Successfully")
                    fetchData()
                } catch {
                    VC.alert(message: "Something went wrong, Please try again.", title: "Updating data Failed")
                }
            }
        }
    }
    
    func update(VC: UIViewController,arrKeys : [String],arrValues : [String], selectedID: Int) {
        context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        var fetchedEntities = NSArray()
        let predicate = NSPredicate(format: "id == %d", selectedID)
        fetchRequest.predicate = predicate
        fetchedEntities = try! context.fetch(fetchRequest) as NSArray
        for i in 0..<arrKeys.count {
            fetchedEntities.setValue(arrValues[i], forKey: arrKeys[i])
        }
        toastMessage("Saving..")
        do {
            try context.save()
            fetchData()
            let alertController = UIAlertController(title: "Done", message: "Updated Successfully.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: { (Action) in
                if let nav = VC.navigationController?.viewControllers {
                    for controller in nav {
                        if controller is ListVC {
                            VC.navigationController?.popToViewController(controller, animated: true)
                            break
                        }
                    }
                }
//                VC.pushTo(VC: "FullDetailsVC")
            })
            alertController.addAction(OKAction)
            VC.present(alertController, animated: true, completion: nil)
        } catch {
            VC.alert(message: "Something went wrong, Please try again.", title: "Updating data Failed")
        }
    }
}
