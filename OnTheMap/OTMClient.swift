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
    
    struct Auth {
        static var id = ""
        static var objectId = ""
        static var sessionId = ""
    }
    
    private enum HttpMethods: String {
        case put  = "PUT"
        case post = "POST"
    }
    
    private enum Endpoint {
        static let base = "https://onthemap-api.udacity.com/v1"
    
        case getUser
        case createSessionId
        case studentLocationList
        case updateStudentLocation(String)
        case getStudentLocation(String)
        case getStudentLocationListByLimit(Int)
        
        private var stringValue: String {
            switch self {
                case .createSessionId: return Endpoint.base + "/session"
                case .getUser: return Endpoint.base + "/users/" + Auth.sessionId
                case .studentLocationList: return Endpoint.base + "/StudentLocation"
                case .updateStudentLocation(let id): return Endpoint.base + "/StudentLocation/\(id)"
                case .getStudentLocationListByLimit(let limit): return Endpoint.base + "/StudentLocation?limit=\(limit)&order=-updatedAt"
                case .getStudentLocation(let uniqueKey): return Endpoint.base + "/StudentLocation?uniqueKey=\(uniqueKey)"
            }
        }
        
        var url: URL { return URL(string: stringValue)! }
    }
    
    
    //MARK: - Private Methods
    private class func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping((Result<ResponseType, OTMError>)->Void)) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error { completion(.failure(.unableToComplete)); return }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse)); return
            }
            
            guard let data = data else { completion(.failure(.invalidData)); return }
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let responseObjc = try jsonDecoder.decode(responseType.self, from: data)
                completion(.success(responseObjc))
            } catch { completion(.failure(.unableToComplete)) }
        }.resume()
    }
    
    private class func taskForPostRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, httpMethod: HttpMethods = .post, body: RequestType, creatingSession flag: Bool = false, responseType: ResponseType.Type, completion: @escaping((Result<ResponseType, OTMError>)->Void)) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if flag { request.addValue("application/json", forHTTPHeaderField: "Accept") }
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error { completion(.failure(.unableToComplete)); return }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    completion(.failure(.invalidResponse)); return
                }
                
                guard var data = data else { completion(.failure(.invalidData)); return }
                if flag { data = data.subdata(in: (5..<data.count)) }
                
                do {
                    let responseObjc = try JSONDecoder().decode(responseType.self, from: data)
                    completion(.success(responseObjc))
                } catch {
                    
                    let body = String(data: data, encoding: String.Encoding.utf8)
                    print(body)
                    
                    completion(.failure(.unableToComplete))
                }
            }.resume()
        } catch { completion(.failure(.unableToComplete)) }
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
        
        print("\n update PUT method, URL: ", Endpoint.updateStudentLocation(Auth.sessionId).url, "\n")
        
        taskForPostRequest(url: Endpoint.updateStudentLocation(Auth.sessionId).url, httpMethod: .put, body: body, responseType: StudentLocationPutResponse.self) { result in
            switch result {
                case .success(let result):
                    DispatchQueue.main.async {
                        print("result: ", result)
                        completion(true, nil)
                    }
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async { completion(false, error) }
            }
        }
    }
    
    class func createSession(username: String, password: String, completion: @escaping((Bool, OTMError?)->Void)) {
        let body = SessionRequest(udacity: [SessionRequest.email: username, SessionRequest.pass: password])
        taskForPostRequest(url: Endpoint.createSessionId.url, httpMethod: .post, body: body, creatingSession: true, responseType: SessionResponse.self) { result in
            switch result {
                case .success(let sessionResp):
                    if sessionResp.account.registered {
                        Auth.id = sessionResp.session.id 
                        Auth.sessionId = sessionResp.account.key
                    }
                    DispatchQueue.main.async { completion(sessionResp.account.registered, nil) }
                case .failure(let error): DispatchQueue.main.async { completion(false, error) }
            }
        }
    }
    
    
    #warning("I tried to implement this method, but data returned from the server is unusable")
    class func getUser(completion: @escaping(Bool, OTMError?)->Void) {
        taskForGetRequest(url: Endpoint.getUser.url, responseType: UserResponse.self) { result in
            switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        StudentModel.user = response.user
                        completion(true, nil)
                    }
                case .failure(let error): DispatchQueue.main.async { completion(false, error) }
            }
        }
    }
}
