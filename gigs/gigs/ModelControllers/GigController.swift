//
//  GigController.swift
//  gigs
//
//  Created by Jeff Kang on 10/3/20.
//

import Foundation

class GigController {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
    
    enum NetworkError: Error {
        case noData
        case failedSignUp
        case failedSignIn
        case noToken
        case tryAgain
        case failedCreatingGig
    }
    
    private let baseURL = URL(string: "https://lambdagigapi.herokuapp.com/api")!
    private lazy var signUpURL = baseURL.appendingPathComponent("/users/signup")
    private lazy var signInURL = baseURL.appendingPathComponent("/users/login")
    
    private lazy var allGigsURL = baseURL.appendingPathComponent("/gigs/")
    
    var bearer: Bearer?
    
    var gigs: [Gig] = []
    
    // helper method for posting
    private func postRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    // sign up method
    func signUp(with user: User, completion: @escaping (Result<Bool,NetworkError>) -> Void) {
        
        var request = postRequest(for: signUpURL)
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
                // handle error
                if let error = error {
                    print("Sign up failed with error: \(error)")
                    completion(.failure(.failedSignUp))
                    return
                }
                // handle response
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    print("Sign up was unsuccessful")
                    completion(.failure(.failedSignUp))
                    return
                }
                completion(.success(true))
            }
            task.resume()
        } catch {
            print("Error encoding user: \(error)")
            completion(.failure(.failedSignUp))
        }
    }
    
    // sign in method
    func signIn(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        var request = postRequest(for: signInURL)
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                // handle error
                if let error = error {
                    print("Sign in failed with error: \(error)")
                    completion(.failure(.failedSignIn))
                    return
                }
                // handle response
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    print("Sign in was unsuccessful")
                    completion(.failure(.failedSignIn))
                    return
                }
                // handle data
                guard let data = data else {
                    print("Data was not received")
                    completion(.failure(.noData))
                    return
                }
                // decode bearer
                do {
                    self.bearer = try JSONDecoder().decode(Bearer.self, from: data)
                    completion(.success(true))
                } catch {
                    print("Error decoding bearer: \(error)")
                    completion(.failure(.noToken))
                }
            }
            task.resume()
        } catch {
            print("Error encoding user: \(error.localizedDescription)")
            completion(.failure(.failedSignIn))
        }
    }
    
    // fetch all gigs
    func fetchAllGigs(completion: @escaping (Result<[Gig], NetworkError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noToken))
            return
        }

        var request = URLRequest(url: allGigsURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")

        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error receiving gigs data: \(error)")
                completion(.failure(.tryAgain))
                return
            }
            if let response = response as? HTTPURLResponse,
               response.statusCode == 401 {
                completion(.failure(.noToken))
                return
            }
            
            guard let data = data else {
                print("No data received from getAllGigs")
                completion(.failure(.noData))
                return
            }

            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.dateDecodingStrategy = .iso8601
                let gigs = try jsonDecoder.decode([Gig].self, from: data)
                self.gigs = gigs
                print("complete")
                completion(.success(gigs))
            } catch {
                print("Error decoding gigs data: \(error)")
                completion(.failure(.tryAgain))
            }
        }
        task.resume()
    }
    
    // create gig
    
    func createGig(with gig: Gig, completion: @escaping(Result<Gig, NetworkError>) -> Void) {
        guard let bearer = bearer else {
            completion(.failure(.noToken))
            return
        }
        
        var request = postRequest(for: allGigsURL)
        request.setValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .iso8601
            let jsonData = try jsonEncoder.encode(gig)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
                if let error = error {
                    print("Creating gig failed with error: \(error)")
                    completion(.failure(.failedCreatingGig))
                    return
                }
                if let response = response as? HTTPURLResponse,
                      response.statusCode == 401 {
                    completion(.failure(.noToken))
                    return
                }
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    print("Creating gig failed")
                    completion(.failure(.failedCreatingGig))
                    return
                }
                completion(.success(gig))
            }
            task.resume()
        } catch {
            print("Error encoding gig: \(error)")
            completion(.failure(.failedCreatingGig))
        }
        
    }
    
}
