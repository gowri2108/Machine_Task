
import UIKit

class MyLocationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noRecord: UILabel!
    var onLocationSelected: ((_ location: Locations) -> Void)?
    
    var locations: [Locations] = [] {
        didSet {
            tableView.reloadData()
            noRecord.isHidden = !(locations.count == 0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locations = PersistenceManager.shared.fetch(Locations.self)        
    }

}

extension MyLocationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationsTableViewCell", for: indexPath) as! LocationsTableViewCell
        let location = locations[indexPath.row]
        cell.nameLabel.text = location.name
        cell.addressLabel.text = location.address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = locations[indexPath.row]
        onLocationSelected?(location)
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
