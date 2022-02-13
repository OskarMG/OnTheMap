//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 10/2/22.
//

import UIKit

class OTMClient {
    
    //MARK: - Properties
    static private let defaults = UserDefaults.standard
    static let udacitySignUp = "https://auth.udacity.com/sign-up"
    
    struct Auth {
        static var id = ""
        static var objectId = ""
        static var sessionId = ""
    }
    
    private enum HttpMethods: String {
        case put  = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
    
    private enum Endpoint {
        static let base = "https://onthemap-api.udacity.com/v1"
    
        case getUser(String)
        case createSession
        case studentLocationList
        case updateStudentLocation(String)
        case getStudentLocation(String)
        case getStudentLocationListByLimit(Int)
        
        private var stringValue: String {
            switch self {
                case .createSession: return Endpoint.base + "/session"
                case .getUser(let id): return Endpoint.base + "/users/" + id
                case .studentLocationList: return Endpoint.base + "/StudentLocation"
                case .updateStudentLocation(let id): return Endpoint.base + "/StudentLocation/\(id)"
                case .getStudentLocationListByLimit(let limit): return Endpoint.base + "/StudentLocation?limit=\(limit)&order=-updatedAt"
                case .getStudentLocation(let uniqueKey): return Endpoint.base + "/StudentLocation?uniqueKey=\(uniqueKey)"
            }
        }
        
        var url: URL { return URL(string: stringValue)! }
    }
    
    
    //MARK: - Private Methods
    private class func formatString(strData: String, completion: @escaping((Data?)->Void)) {
        let trash = ")]}\'\n"
        if strData.contains(trash) {
            let result = strData.replacingOccurrences(of: trash, with: "")
            completion(Data(result.utf8))
        } else { completion(nil) }
    }
    
    private class func taskForGetRequest<ResponseType: Decodable>(url: URL, getUser flag: Bool = false, responseType: ResponseType.Type, completion: @escaping((Result<ResponseType, OTMError>)->Void)) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error { completion(.failure(.unableToComplete)); return }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse)); return
            }
            
            guard var data = data else { completion(.failure(.invalidData)); return }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if flag { data = data.subdata(in: (5..<data.count)) }
            
            do {
                let responseObjc = try decoder.decode(responseType.self, from: data)
                completion(.success(responseObjc))
            } catch { completion(.failure(.unableToComplete)) }
        }.resume()
    }
    
    private class func taskForPostRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, httpMethod: HttpMethods = .post, body: RequestType, creatingSession flag: Bool = false, responseType: ResponseType.Type, completion: @escaping((Result<ResponseType, OTMError>)->Void)) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        if httpMethod == .delete {
            var xsrfCookie: HTTPCookie? = nil
            let sharedCookieStorage = HTTPCookieStorage.shared
            for cookie in sharedCookieStorage.cookies! { if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie } }
            if let xsrfCookie = xsrfCookie { request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN") }
        } else { request.addValue("application/json", forHTTPHeaderField: "Content-Type") }
        
        if flag { request.addValue("application/json", forHTTPHeaderField: "Accept") }
        
        do {
            if httpMethod != .delete { request.httpBody = try JSONEncoder().encode(body) }
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let _ = error { completion(.failure(.unableToComplete)); return }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    completion(.failure(.badCredentials)); return
                }
                
                guard var data = data else { completion(.failure(.invalidData)); return }
                if flag { data = data.subdata(in: (5..<data.count)) }
                
                do {
                    let responseObjc = try JSONDecoder().decode(responseType.self, from: data)
                    completion(.success(responseObjc))
                } catch {
                    if let strData = String(data: data, encoding: String.Encoding.utf8) {
                        formatString(strData: strData) { data in
                            guard let data = data else { completion(.failure(.invalidData)); return }
                            do {
                                let responseObjc = try JSONDecoder().decode(responseType.self, from: data)
                                completion(.success(responseObjc))
                            } catch { completion(.failure(.invalidData)) }
                        }
                    } else { completion(.failure(.invalidData)) }
                }
            }.resume()
        } catch { completion(.failure(.unableToSubmitRequest)) }
    }
    
    
    //MARK: - UserDefaults Methods
    class private func saveObjectId() { defaults.set(Auth.objectId, forKey: "objectId") }
    class func getStudentObjectId() -> String? { return defaults.object(forKey: "objectId") as? String }
    
    
    //MARK: - On The Map Network Calls
    class func getStudentLocations(completion: @escaping((Result<StudentResults, OTMError>)->Void)) {
        taskForGetRequest(url: Endpoint.getStudentLocationListByLimit(100).url, responseType: StudentResults.self) { result in
            DispatchQueue.main.async { completion(result) }
        }
    }
    
    class func addStudentLocation(body: StudentLocationRequest, completion: @escaping((Bool, OTMError?)->Void)) {
        taskForPostRequest(url: Endpoint.studentLocationList.url, body: body, responseType: StudentLocationPostResponse.self) { result in
            switch result {
                case .success(let response): DispatchQueue.main.async {
                    Auth.objectId = response.objectId
                    self.saveObjectId()
                    completion(true, nil)
                }
                case .failure(let error): DispatchQueue.main.async { completion(false, error) }
            }
        }
    }
    
    class func updateStudentLocation(body: StudentLocationRequest, completion: @escaping((Bool, OTMError?)->Void)) {
        taskForPostRequest(url: Endpoint.updateStudentLocation(Auth.objectId).url, httpMethod: .put, body: body, responseType: StudentLocationPutResponse.self) { result in
            switch result {
                case .success: DispatchQueue.main.async { completion(true, nil) }
                case .failure(let error): DispatchQueue.main.async { completion(false, error) }
            }
        }
    }
    
    class func createSession(username: String, password: String, completion: @escaping((Bool, OTMError?)->Void)) {
        let body = SessionRequest(udacity: [SessionRequest.email: username, SessionRequest.pass: password])
        taskForPostRequest(url: Endpoint.createSession.url, httpMethod: .post, body: body, creatingSession: true, responseType: SessionResponse.self) { result in
            switch result {
                case .success(let sessionResp):
                    if sessionResp.account.registered {
                        Auth.id = sessionResp.session.id 
                        Auth.sessionId = sessionResp.account.key
                        self.getUser { success in
                            if success {
                                DispatchQueue.main.async { completion(sessionResp.account.registered, nil) }
                            } else { DispatchQueue.main.async { completion(false, OTMError.invalidUser) } }
                        }
                    } else { DispatchQueue.main.async { completion(false, OTMError.invalidUser) } }
                case .failure(let error): DispatchQueue.main.async { completion(false, error) }
            }
        }
    }
    
    
    class func getUser(completion: @escaping((Bool)->Void)) {
        let request = URLRequest(url: Endpoint.getUser(Auth.sessionId).url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, var data = data else { completion(false); return }
            data = data.subdata(in: (5..<data.count))
            let str = String(decoding: data, as: UTF8.self)
            guard let newData = str.data(using: String.Encoding.utf8) else { completion(false); return }

            do {
                let respo = try JSONSerialization.jsonObject(with: newData, options: []) as? [String:AnyObject] as NSDictionary?
                if let responseObjc  = respo {
                    if let key       = responseObjc["key"]        as? String,
                       let firstName = responseObjc["first_name"] as? String,
                       let lastName  = responseObjc["last_name"]  as? String,
                       let imageUrl  = responseObjc["_image_url"] as? String,
                       let nickname  = responseObjc["nickname"]   as? String {
                        StudentModel.user = User(key: key, firstName: firstName, lastName: lastName, imageUrl: imageUrl, nickname: nickname)
                        completion(true)
                    } else { completion(false) }
                } else { completion(false) }
            } catch { completion(false) }
        }.resume()
    }
    
    
    class func logout(completion: @escaping(()->Void)) {
        taskForPostRequest(url: Endpoint.createSession.url, httpMethod: .delete, body: LogoutRequest(),  responseType: LogoutResponse.self) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    print("\n\n// SUCCESS LOGOUT //\n\n")
                    completion()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("\n\n// LOGOUT ERROR: //\n", error.localizedDescription, "\n\n")
                    completion()
                }
            }
        }
    }
}
