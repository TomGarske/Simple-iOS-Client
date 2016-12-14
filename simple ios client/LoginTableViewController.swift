//
//  LoginTableViewController.swift
//  simple ios client
//
//  Created by Thomas Garske on 12/11/16.
//  Copyright © 2016 csci4211. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var registerButton: UIButton!

    var serverPath="http://192.168.0.23:5000/api/v1.0/"

    override func viewDidLoad() {
        super.viewDidLoad()
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
    }

    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    override func viewDidAppear(_ animated: Bool) {
        confirmPassword.isHidden = true
        registerButton.isHidden = true
        isRegistering = false
    }

    var isRegistering = false
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var success : Bool = true
        if( identifier == "segue_login"){
            success = attemptLogin()
            if (!success) {
                registerButton.isHidden = false
            }
        }
        return success
    }

    func attemptLogin() -> Bool {
        //self.login(username: self.usernameTF.text!, password: self.passwordTF.text!)
        self.setUserId(id: -1)
        self.login(username: self.usernameTF.text!, password:self.passwordTF.text!)
        var success =  (self.getUserId() > 0)
        if(isRegistering){
            self.login(username: self.usernameTF.text!, password:self.passwordTF.text!)
            success = registerUser()
        }
        return success
    }

    func registerUser() -> Bool{
        return true
    }

    @IBAction func didTapRegisterUser(_ sender: Any) {
        confirmPassword.isHidden = false
        registerButton.isHidden = true
        isRegistering = true
    }
}

extension UIViewController {
    func getUserId() -> Int{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.userid
    }

    func setUserId(id : Int){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.userid = id
    }
}

// Extension for sending post requests
extension LoginViewController {

    func login(username : String, password : String){
        print("logging in....")
        var url = URL(string: serverPath + "userlogin")!
        if(self.isRegistering){
            url = URL(string: serverPath + "users")!
        }

        let session = URLSession.shared

        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()

        do {
            let json = [ "username":username,"password":password] as [String : String]
            // Set Data to JSON Object
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)

            // Set URLRequest body and header
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.cachePolicy = .reloadIgnoringCacheData
            if(!self.isRegistering){
                request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            }
            request.httpBody = jsonData

            let semaphore = DispatchSemaphore(value: 0)

            // Send request and capture response
            _ = session.dataTask(with: request){ data,response,error in
                if let httpResponse = response as? HTTPURLResponse {
                    print(httpResponse.statusCode)
                    if( httpResponse.statusCode != 201 ){
                        semaphore.signal()
                        return
                    }
                }
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                if json != nil {
                    let dict = (json as! NSDictionary!)
                    if((dict?.allKeys.count)! > 0){
                        let id = dict!["userid"] as? NSNumber
                        self.setUserId(id: (id?.intValue)!)
                    }
                }
                semaphore.signal()
            }.resume()

            _=semaphore.wait(timeout: .distantFuture)
        }catch { print(error) }
    }
}
