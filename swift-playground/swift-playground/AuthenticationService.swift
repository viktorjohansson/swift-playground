//
//  PostService.swift
//  swift-playground
//
//  Created by viktor johansson on 15/02/16.
//  Copyright © 2016 viktor johansson. All rights reserved.
//

import Foundation
import Alamofire

// MARK: Protocols
protocol AuthenticationServiceDelegate {
    func setAuthenticationData(json: AnyObject)
}

class AuthenticationService {
    
    // MARK: Setup
    var delegate: AuthenticationServiceDelegate?
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let url = "https://catchit.se/"
    
    // MARK: POST-Requests
    func registerUser(email: String, password: String, username: String) {
        let parameters = [
            "user": [
                "email": email,
                "name": username,
                "password": password
            ]
        ]
        Alamofire.request(.POST, url + "users.json", parameters: parameters)
            .responseJSON { response in
                if response.result.isSuccess {
                    let json = response.result.value
                    // True if registration is complete. This should be changed for better readability.
                    if json!.count > 1 {
                        let userEmail = json?["email"] as! String
                        if let userToken = json?["authentication_token"] as? String {
                            let username = json?["name"] as! String
                            let userId = json?["id"] as! Int
                            let headers = ["X-User-Email": userEmail, "X-User-Token": userToken]
                            self.userDefaults.setObject(userEmail, forKey: "email")
                            self.userDefaults.setObject(userToken, forKey: "token")
                            self.userDefaults.setInteger(userId, forKey: "id")
                            self.userDefaults.setObject(headers, forKey: "headers")
                            self.userDefaults.setObject(username, forKey: "name")
                            self.userDefaults.setObject("https://catchit.se/", forKey: "url")
                            if self.delegate != nil {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.delegate?.setAuthenticationData(true)
                                })
                            }
                        } else {
                            print("Could not create user, used email or bad input")
                            if self.delegate != nil {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.delegate?.setAuthenticationData(false)
                                })
                            }
                        }
                    } else {
                        print("Could not create user, no response from server")
                        if self.delegate != nil {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.delegate?.setAuthenticationData(false)
                            })
                        }
                    }
                } else {
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setAuthenticationData(false)
                        })
                    }
                    print("Could not connect to server")
                }
        }			
    }
    
    func loginUser(email: String, password: String) {
        let parameters = [
            "user": [
                "email": email,
                "password": password
            ]
        ]
        Alamofire.request(.POST, url + "users/sign_in.json", parameters: parameters)
            .responseJSON { response in
                if response.result.isSuccess {
                    let json = response.result.value
                    // True if email and password is corrent. This should be changed for better readability.
                    if json!.count > 1 {
                        let username = json?["name"] as! String
                        let userEmail = json?["email"] as! String
                        let userToken = json?["authentication_token"] as! String
                        let userId = json?["id"] as! Int
                        let headers = ["X-User-Email": userEmail, "X-User-Token": userToken]
                        self.userDefaults.setObject(userEmail, forKey: "email")
                        self.userDefaults.setObject(userToken, forKey: "token")
                        self.userDefaults.setInteger(userId, forKey: "id")
                        self.userDefaults.setObject(headers, forKey: "headers")
                        self.userDefaults.setObject(username, forKey: "name")
                        self.userDefaults.setObject("https://catchit.se/", forKey: "url")
                        if self.delegate != nil {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.delegate?.setAuthenticationData(true)
                            })
                        }
                    } else {
                        print("Wrong email or password")
                        if self.delegate != nil {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.delegate?.setAuthenticationData(false)
                            })
                        }
                    }
                } else {
                    print("Could not connect to server")
                    if self.delegate != nil {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.delegate?.setAuthenticationData(false)
                        })
                    }
                }
        }
    }

    
}
