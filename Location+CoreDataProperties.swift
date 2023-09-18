//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by James Fernandez on 9/18/23.
//
//

import Foundation
import CoreData
import CoreLocation

//The @NSManaged keyword tells the compiler that these properties will be resolved at runtime by Core Data. When you put a new value into one of these properties, Core Data will place that value into the data store for safekeeping, instead of in a regular instance variable.
extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: Date
    @NSManaged public var locationDescription: String
    @NSManaged public var category: String
    @NSManaged public var placemark: CLPlacemark?

}

extension Location : Identifiable {

}
