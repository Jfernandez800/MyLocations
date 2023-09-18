import UIKit
import CoreLocation
import CoreData

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
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var managedObjectContext: NSManagedObjectContext!
    //Chapter 27 - You’re adding this variable because you need to store the current date in the new Location object.
    var date = Date()
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
        //chapter 27 - This now uses the new property instead of creating the date on the fly.
        dateLabel.text = format(date: date)
        
        //Chapter 26 - Hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    @IBAction func done() {
        guard let mainView = navigationController?.parent?.view
        else { return }
        let hudView = HudView.hud(inView: mainView, animated: true)
        hudView.text = "Tagged"
        // 1 - Create a new Location instance. Because this is a managed object, you have to use its init(context:) method.
        let location = Location(context: managedObjectContext)
        // 2 - Set its properties to whatever the user entered in the screen.
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        // 3 - You now have a new Location object whose properties are all filled in, but if you were to look in the data store at this point, you’d still see no objects there.
        do {
            try managedObjectContext.save()
            afterDelay(0.6) {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            }
        } catch {
            // 4 - Output the error and then terminate the application via the system method fatalError.
            fatalError("Error: \(error)")
        }
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
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
    
    //Chapter 26 - Whenever the user taps somewhere in the table view, the gesture recognizer calls this method. it also passes a reference to itself as a parameter, which lets you ask gestureRecognizer where the tap happened.
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer){
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 0 &&
            indexPath!.row == 0 {
            return
        }
        descriptionTextView.resignFirstResponder()
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
}
