import Moya

struct LoggingPlugin: PluginType {
  func willSend(_ request: RequestType, target: TargetType) {
    let headers = request.request?.allHTTPHeaderFields ?? [:]
    let url = request.request?.url?.absoluteString ?? "nil"
    let path = url.replacingOccurrences(of: target.baseURL.absoluteString, with: "")
    if let body = request.request?.httpBody {
      let bodyString = String(bytes: body, encoding: String.Encoding.utf8) ?? "nil"
      log.info("""
                       \n
                       <willSend: \(path) - \(Date().debugDescription)>
                             url: \(url)
                         headers: \(headers)
                            body: \(bodyString)
               """)
    } else {
      log.info("""
                       \n
                       <willSend: \(path) - \(Date().debugDescription)>
                             url: \(url)
                         headers: \(headers)
                            body: nil
               """)
    }
  }

  func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
    switch result {
    case let .success(response):
      let request = response.request
      let url = request?.url?.absoluteString ?? "nil"
      let method = request?.httpMethod ?? "nil"
      let statusCode = response.statusCode
      var bodyString = "nil"
      if let data = request?.httpBody,
         let string = String(bytes: data, encoding: String.Encoding.utf8) {
        bodyString = string
      }
      var responseString = "nil"
      if let reString = String(bytes: response.data, encoding: String.Encoding.utf8) {
        responseString = reString
      }
      log.info("""
                       \n
                       <didReceive: \(method) statusCode: \(statusCode)>
                               url: \(url)
                              body: \(bodyString)
                          response: \(responseString)
               """)
    case let .failure(error):
      log.error(error)
    }
  }
}

