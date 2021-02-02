import UIKit
import GoogleMaps
import GooglePlaces

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var srchBar: UISearchBar!
    var mylist: UIBarButtonItem?
    
    private var tableDataSource: GMSAutocompleteTableDataSource!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource.delegate = self
        
        tableView.delegate = tableDataSource
        tableView.dataSource = tableDataSource
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mylist = UIBarButtonItem(image: #imageLiteral(resourceName: "list_icon"), style: .plain, target: self, action: #selector(myListIconClick))
        navigationItem.rightBarButtonItems = [mylist!]
    }
    
    @objc func myListIconClick(_ sender: UIBarButtonItem) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        guard let mylistVc = storyBoard.instantiateViewController(withIdentifier: "MyLocationsViewController") as? MyLocationsViewController else { return }
        mylistVc.onLocationSelected = { [weak self] location in
            if let lat = Double(location.latitude ?? ""), let lon = Double(location.longitude ?? "") {
                self?.gotoLocation(lat: lat, lon: lon)
            }
        }
        navigationController?.pushViewController(mylistVc, animated: true)
    }
    
    func gotoLocation(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 17.0)
        mapView?.isMyLocationEnabled = true
        mapView?.animate(to: camera)
    }
    
}

extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location = locations.last

        if let lat = location?.coordinate.latitude, let lon = location?.coordinate.longitude {
            gotoLocation(lat: lat, lon: lon)
            locationManager.stopUpdatingLocation()
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.isHidden = (searchBar.text == "")
        tableDataSource.sourceTextHasChanged(searchText)
    }
}

extension HomeViewController: GMSAutocompleteTableDataSourceDelegate {
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        tableView.reloadData()
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        tableView.reloadData()
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        gotoLocation(lat: place.coordinate.latitude, lon: place.coordinate.longitude)
        
        let locations = PersistenceManager.shared.fetch(Locations.self)
        
        DispatchQueue.global(qos: .background).async {
            for loc in locations {
                if loc.placeId == place.placeID {
                    return
                }
            }
            DispatchQueue.main.sync {
                let location = Locations(context: PersistenceManager.shared.context)
                location.name = place.name ?? ""
                location.address = place.formattedAddress ?? ""
                location.latitude = "\(place.coordinate.latitude)"
                location.longitude = "\(place.coordinate.longitude)"
                PersistenceManager.shared.save()
            }
        }
        
        
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        tableView.isHidden = true
        return true
    }
}
