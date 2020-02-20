
import UIKit

class ImageVC: UIViewController {

    @IBOutlet weak var imgVw: UIImageView!
    
    var img = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgVw.image = img
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView(sender:)))
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(rotateActionForImage(sender:)))
        imgVw.addGestureRecognizer(panGesture)
        imgVw.addGestureRecognizer(pinchGesture)
        imgVw.addGestureRecognizer(rotate)
        
    }
    
    @IBAction func actionBack(_ sender: Any) {
        popToBack()
    }
    
    @objc func pinchedView(sender:UIPinchGestureRecognizer){
        if let view = sender.view {
            view.transform = view.transform.scaledBy(x: sender.scale, y: sender.scale)
            sender.scale = 1
        }
    }
    
    @objc  func draggedView(_ panGesture:UIPanGestureRecognizer){
        let translation = panGesture.translation(in: view)
        panGesture.setTranslation(CGPoint.zero, in: view)
        let imgView = panGesture.view
        imgView?.center = CGPoint(x: (imgView?.center.x)!+translation.x, y: (imgView?.center.y)!+translation.y)
        imgView?.isMultipleTouchEnabled = true
        imgView?.isUserInteractionEnabled = true
    }
    
    @objc func rotateActionForImage(sender:UIRotationGestureRecognizer){
        let viewDrag = sender.view
        viewDrag?.transform=(viewDrag?.transform.rotated(by:sender.rotation))!
        sender.rotation=0
    }
}
