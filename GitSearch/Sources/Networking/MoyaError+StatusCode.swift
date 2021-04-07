import Alamofire
import Moya

extension Swift.Error {
  var httpStatusCode: Int? {
    (self as? MoyaError)?.response?.statusCode
  }
}
