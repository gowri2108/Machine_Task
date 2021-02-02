
import Foundation
import CoreData

public class Locations: NSManagedObject {

}

extension Locations {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Locations> {
        return NSFetchRequest<Locations>(entityName: "Locations")
    }

    @NSManaged public var latitude: String?
    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var longitude: String?
    @NSManaged public var placeId: String?

}
