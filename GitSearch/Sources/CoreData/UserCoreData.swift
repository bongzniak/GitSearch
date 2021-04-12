import Foundation
import CoreData

@objc(User)
public class UserCoreData: NSManagedObject {

}

extension UserCoreData {

    public class func fetchRequest() -> NSFetchRequest<UserCoreData> {
      NSFetchRequest<UserCoreData>(entityName: "User")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var avatarUrl: String?
}
