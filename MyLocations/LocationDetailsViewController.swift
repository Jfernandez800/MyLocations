import UIKit
import CoreLocation

//Chapter 25 - creating a new constant named dateFormatter of type DateFormatter. This constant is private so it cannot be used outside of this Swift file. You’re also giving dateFormatter an initial value, but what follows the = is not an ordinary value, because it is a closure.
private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .medium
  formatter.timeStyle = .short
  return formatter
}()

class LocationDetailsViewController: UITableViewController {
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func done() {
        //Chapter 26 - This is some syntactic sugar to allow you to check for optionals and handle nil conditions easily.
        guard let mainView = navigationController?.parent?.view
        else { return }
        let hudView = HudView.hud(inView: mainView, animated: true)
        hudView.text = "Tagged"
        
        //Chapter 26 - tells the app to close the Tag Location screen after 0.6 seconds.
        afterDelay(0.6) {
            hudView.hide()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    
    //Chapter 25 - -set the category name to “No Category”, which is the category at the top of the list in the category picker.
    var categoryName = "No Category"
    
    //Chapter 25 - sets a value for every label.
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionTextView.text = ""
        categoryLabel.text = ""
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        categoryLabel.text = categoryName
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        dateLabel.text = format(date: Date())
        
        //Chapter 26 - Hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    //Chapter 25 - similar to how the placemark was formatted on the main screen, except that you also include the country here.
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let tmp = placemark.subThoroughfare {
            text += tmp + " "
        }
        if let tmp = placemark.thoroughfare {
            text += tmp + ", "
        }
        if let tmp = placemark.locality {
            text += tmp + ", "
        }
        if let tmp = placemark.administrativeArea {
            text += tmp + " "
        }
        if let tmp = placemark.postalCode {
            text += tmp + ", "
        }
        if let tmp = placemark.country {
            text += tmp
        }
        return text
    }
    
    //Chapter 25 - asks the DateFormatter to turn the Date into a String and returns that.
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
    
    //assigns the category to the detailLabel
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    
    //Chapter 26 - limits taps to just the cells from the first two sections.
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    //Chapter 26 - andles the actual taps on the rows.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath ){
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }
    
    //Chapter - Whenever the user taps somewhere in the table view, the gesture recognizer calls this method. it also passes a reference to itself as a parameter, which lets you ask gestureRecognizer where the tap happened.
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer){
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0 &&
            indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
    }
}
