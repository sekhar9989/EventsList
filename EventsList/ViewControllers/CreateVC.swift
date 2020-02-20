
import UIKit

class CreateVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var txtFldType: UITextField!
    @IBOutlet weak var txtFldTitle: UITextField!
    @IBOutlet weak var txtVwDescription: UITextView!
    @IBOutlet weak var txtFldDateTime: UITextField!
    @IBOutlet weak var colVwImages: UICollectionView!
    @IBOutlet weak var txtFldReminderTime: UITextField!
    @IBOutlet weak var lblAddImages: UILabel!
    @IBOutlet weak var btnAdd: MyButton!
    
    //MARK:- Constants and Variables
    let dateFormatter = DateFormatter()
    let locale = NSLocale.current
    var datePicker = UIDatePicker()
    let toolBar = UIToolbar()
    var selectedImages = [UIImage]()
    let objCameraGallery = GalleryCamera()
    var typePicker = UIPickerView()
    var dict : Dictionary<String, Any>?
    
    //MARK:- View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        txtVwDescription.text = "Enter description"
        txtVwDescription.textColor = UIColor.lightGray
        doDatePicker()
        objCameraGallery.delegate = self
        typePicker.delegate = self
        txtFldType.inputView = typePicker
        if dict != nil {
            txtFldTitle.text = dict!["title"] as? String
            txtFldType.text = dict!["type"] as? String
            txtFldDateTime.text = dict!["date"] as? String
            txtFldReminderTime.text = dict!["ocassion"] as? String
            for i in 1...5 {
                if (dict!["img\(i)"] as! String).count > 3 {
                    selectedImages.append(ConvertBase64StringToImage(imageBase64String: dict!["img\(i)"] as! String))
                }
            }
            if (dict!["note"] as! String).count != 0 {
                txtVwDescription.text = dict!["note"] as? String
                txtVwDescription.textColor = .black
            } else {
                txtVwDescription.text = "Enter description"
                txtVwDescription.textColor = UIColor.lightGray
            }
            colVwImages.reloadData()
            btnAdd.setTitle("Update", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        btnAdd.addgradientAnimation()
    }
    
    func doDatePicker() {
        // DatePicker
        datePicker.backgroundColor = UIColor.white
        datePicker.timeZone = NSTimeZone.local
        datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePicker.minimumDate = Date()
        
        // ToolBar
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = #colorLiteral(red: 0.1836382151, green: 0.3331800103, blue: 0.5062610507, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        txtFldDateTime.inputAccessoryView = toolBar
        txtFldDateTime.inputView = datePicker
    }
    
    
    @objc func doneClick() {
        dateFormatter.dateFormat = "dd-MM-yyyy  hh:mm a"
        txtFldDateTime.text = dateFormatter.string(from: datePicker.date)
        txtFldDateTime.resignFirstResponder()
    }
    
    @objc func cancelClick() {
        txtFldDateTime.resignFirstResponder()
    }
    
    //MARK:- IBActions
    @IBAction func actionBack(_ sender: Any) {
        popToBack()
    }
    
    @IBAction func actionSave(_ sender: Any) {
        self.view.endEditing(true)
        if txtFldType.text!.count == 0 {
            toastMessage("Please select event type")
        } else if txtFldTitle.text!.count == 0 {
            toastMessage("Pleaase enter event title")
        } else if txtFldDateTime.text!.count == 0 {
            toastMessage("Please select event date")
        } else if txtFldReminderTime.text!.count == 0 {
            toastMessage("Please enter ocassion ")
        } else {
            let arrKeys = ["type","title","note","date","img1","img2","img3","img4","img5","ocassion"]
            var arrImagesStrings = [String]()
            for i in 0..<selectedImages.count {
                arrImagesStrings.append(ConvertImageToBase64String(img: selectedImages[i]))
            }
            let balanceImages = 5 - arrImagesStrings.count
            for _ in 0..<balanceImages {
                arrImagesStrings.append("")
            }
            var notes = String()
            if txtVwDescription.textColor == UIColor.black {
                notes = txtVwDescription.text
            } else {
                notes = ""
            }
            let arrValues = [ txtFldType.text!, txtFldTitle.text!,notes,txtFldDateTime.text!,arrImagesStrings[0],arrImagesStrings[1],arrImagesStrings[2],arrImagesStrings[3],arrImagesStrings[4],txtFldReminderTime.text!]
            if dict != nil {
                objDataHelper.update(VC: self, arrKeys: arrKeys, arrValues: arrValues, selectedID: dict!["id"] as! Int)
            } else {
                objDataHelper.openDatabse(VC: self, arrKeys: arrKeys, arrValues: arrValues)
            }
        }
    }

    @IBAction func actionAddImages(_ sender: Any) {
        if selectedImages.count < 5 {
            objCameraGallery.showAlertChooseImage(self)
        } else {
            toastMessage("Maximum images selected")
        }
    }
}

extension CreateVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        colVwImages.isHidden = false
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreateCVC", for: indexPath) as! CreateCVC
        cell.imgVwSelected.image = selectedImages[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImages.remove(at: indexPath.item)
        colVwImages.reloadData()
        if selectedImages.count == 0 {
            colVwImages.isHidden = true
        }
    }
    
    
}

extension CreateVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case txtFldType:
            txtFldTitle.becomeFirstResponder()
        case txtFldTitle:
            txtFldReminderTime.becomeFirstResponder()
        case txtFldReminderTime:
            txtFldDateTime.becomeFirstResponder()
        case txtFldDateTime:
            txtVwDescription.becomeFirstResponder()
        default:
            resignFirstResponder()
        }
        return true
    }
}

extension CreateVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if txtVwDescription.textColor == UIColor.lightGray {
            txtVwDescription.text = nil
            txtVwDescription.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if txtVwDescription.text.isEmpty {
            txtVwDescription.text = "Enter description"
            txtVwDescription.textColor = UIColor.lightGray
        }
    }
}

extension CreateVC: ImageSelected {
    func finishPassing(selectedImg: UIImage) {
        selectedImages.append(selectedImg)
        colVwImages.reloadData()
    }
}

extension CreateVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return objDataHelper.arrType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            txtFldType.text = objDataHelper.arrType[row]
        }
        return objDataHelper.arrType[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == typePicker {
            txtFldType.text = objDataHelper.arrType[row]
            self.view.endEditing(true)
        }
    }
}
