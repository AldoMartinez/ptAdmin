//
//  LoginController.swift
//  ptAdmin
//
//  Created by Aldo Aram Martinez Mireles on 6/17/18.
//  Copyright © 2018 Aldo Aram Martinez Mireles. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FacebookCore
import FacebookLogin
import FirebaseAuth
import JGProgressHUD
import FirebaseUI


class LoginController: UIViewController {
    @IBOutlet weak var backgroundImage:UIImageView!
    @IBOutlet weak var tituloApp: UILabel!
    
    @IBAction func correoLoginButton(_ sender: UIButton) {
        let authUI = FUIAuth.defaultAuthUI()
        
        guard authUI != nil else{
            return
        }
        
        authUI?.delegate = self
        
        let authViewController = authUI!.authViewController()
        present(authViewController, animated: true, completion: nil)
    }

    
    // Crea un mensaje flotante temporal
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    // Creo el boton de facebook
    lazy var signInWithFacebookButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("Inicia sesión con Facebook", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonTitleFontSize)
        button.setTitleColor(Service.buttonTitleColor, for: .normal)
        button.backgroundColor = Service.buttonBackgroundColorSignInWithFacebook
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Service.buttonCornerRadius
        
        button.setImage(#imageLiteral(resourceName: "FacebookButton").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.contentMode = .scaleAspectFit
        
        button.addTarget(self, action: #selector(handleSignInWithFacebookButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Iniciamos sesion con facebook
    @objc func handleSignInWithFacebookButtonTapped(){
        hud.textLabel.text = "Logging in with Facebook..."
        hud.show(in: view, animated: true)
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (result) in
            switch result{
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
//                let viewController: UITabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Inicio") as! UITabBarController
                print("Succesfully logged in into Facebook")
                self.signIntoFirebase()
//                self.present(viewController, animated: true, completion: nil)
            case .failed(let error):
                print(error)
                self.hud.textLabel.text = "Error al iniciar sesion"
                self.hud.dismiss(afterDelay: 1, animated: true)
            case .cancelled:
                self.hud.textLabel.text = "Cancelado"
                self.hud.dismiss(afterDelay: 1, animated: true)
            }
        }
    }
    
    // Iniciamos sesion en firebase
    fileprivate func signIntoFirebase(){
        guard let authenticationToken = AccessToken.current?.authenticationToken else{ return }
        let credential = FacebookAuthProvider.credential(withAccessToken: authenticationToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if let error = error{
                print(error)
                return
            }
            print("Succesfully logged in into Firebase")
            self.hud.dismiss(animated: true)
            self.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "is", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        view.addSubview(signInWithFacebookButton)
        if #available(iOS 11.0, *) {
            signInWithFacebookButton.anchor(nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 30, rightConstant: 16, widthConstant: 0, heightConstant: 50)
        } else {
            // Fallback on earlier versions
        }
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension LoginController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        
        if error != nil {
            return
        }
        
        performSegue(withIdentifier: "is", sender: self)
        
    }
}
