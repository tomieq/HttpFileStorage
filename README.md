# HttpFileStorage.swift

A simple http server that stores, serves and deletes files

`PUT http://[ip]:[port]/{filename}`

`GET http://[ip]:[port]/{filename}`

`DELETE http://[ip]:[port]/{filename}`

```
swift build -j 1
./build/debug/HttpFileStorage port=8080 workingDir=/home/pi/tmp
```

### Sample code to upload file
```
import Foundation
import FoundationNetworking

if let url = URL(string: "http://[ip]:[port]/sample.txt") {
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.httpBody = "test".data(using: .utf8)
    URLSession.shared.dataTask(with: request) { _, response, error in
        let responseCode = (response as? HTTPURLResponse)?.statusCode
        print("DBG: response code: \(responseCode ?? 0) \(error.debugDescription)")
    }.resume()
}
```
