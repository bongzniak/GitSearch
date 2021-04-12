//
//  User+CoreDataClass.swift
//
//
//  Created by bongzniak on 2021/04/07.
//
//

import Foundation
import CoreData

@objc(User)
public class UserCoreData: NSManagedObject {

}

extension UserCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserCoreData> {
      NSFetchRequest<UserCoreData>(entityName: "User")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var avatarUrl: String?
}
