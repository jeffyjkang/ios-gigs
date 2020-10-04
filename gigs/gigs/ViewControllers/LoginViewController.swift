//
//  LoginViewController.swift
//  gigs
//
//  Created by Jeff Kang on 10/3/20.
//

import UIKit

enum LoginType {
    case signUp
    case signIn
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var gigController: GigController?
    var loginType = LoginType.signUp
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var loginTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginTypeChanged(_ sender: UISegmentedControl) {
        print("loginType changed")
        if sender.selectedSegmentIndex == 0 {
            loginType = .signUp
            loginButton.setTitle("Sign Up", for: .normal)
        } else {
            loginType = .signIn
            loginButton.setTitle("Sign In", for: .normal)
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        print("loginButton tapped")
        if let username = usernameTextField.text, !username.isEmpty,
           let password = passwordTextField.text, !password.isEmpty {
            
            let user = User(username: username, password: password)
            
            switch loginType {
            case .signUp:
                gigController?.signUp(with: user, completion: { (result) in
                    do {
                        let success = try result.get()
                        if success {
                            DispatchQueue.main.async {
                                let alertController = UIAlertController(title: "Sign up Successful", message: "Now please log in", preferredStyle: .alert)
                                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(alertAction)
                                self.present(alertController, animated: true) {
                                    self.loginType = .signIn
                                    self.loginTypeSegmentedControl.selectedSegmentIndex = 1
                                    self.loginButton.setTitle("Sign In", for: .normal)
                                }
                            }
                        }
                    } catch {
                        print("Error signing up: \(error)")
                    }
                })
            case .signIn:
                gigController?.signIn(with: user, completion: { (result) in
                    do {
                        let success = try result.get()
                        if success {
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    } catch {
                        if let error = error as? GigController.NetworkError {
                            switch error {
                            case .failedSignIn:
                                print("Sign in failed")
                            case .noData, .noToken:
                                print("No data received")
                            default:
                                print("Other error occured")
                            }
                        }
                    }
                })
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
