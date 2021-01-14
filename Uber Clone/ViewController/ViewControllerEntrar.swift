//
//  ViewControllerEntrar.swift
//  Uber Clone
//
//  Created by João Carlos Paiva on 26/12/20.
//  Copyright © 2020 João Carlos Paiva. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ViewControllerEntrar: UIViewController {
    @IBOutlet weak var senha: UITextField!
    @IBOutlet weak var email: UITextField!
    
    func getAlert (title: String, message: String, titleAction: String) {
        let alerta = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmar = UIAlertAction(title: titleAction, style: .default, handler: nil)
        alerta.addAction(confirmar)
        present(alerta, animated: true, completion: nil)
    }
    
    @IBAction func entrar(_ sender: Any) {
        if let emailRecuperado = self.email.text {
            if emailRecuperado != "" {
                if let senhaRecuperada = self.senha.text {
                    if senhaRecuperada != "" {
                        let autenticacao = Auth.auth()
                        autenticacao.signIn(withEmail: emailRecuperado, password: senhaRecuperada) { (usuario, erro) in
                            if erro == nil {
                                if usuario == nil {
                                    print("erro ao cadastrar usuário")
                                    self.getAlert(title: "Ocorreu um erro inesperado", message: "Não foi possível verificar suas credenciais, por favor, tente novamente", titleAction: "OK")
                                }else {
                                    print("Sucesso ao cadastrar usuário")
                                    //Transferindo o usuário para a tela inicial do app
                                    self.performSegue(withIdentifier: "segueLogin", sender: nil)
                                }
                            }else {
                                print("Erro ao cadastrar usuário")
                                self.getAlert(title: "Ocorreu um erro inesperado", message: "Não foi possível verificar suas credenciais, por favor, tente novamente", titleAction: "OK")
                            }
                        }
                    }else {
                        self.getAlert(title: "Tente novamente", message: "Preencha corretamente a sua senha, por favor.", titleAction: "OK")
                    }
                }
            }else {
                self.getAlert(title: "Tente novamente", message: "Preencha corretamente o seu e-mail, por favor.", titleAction: "OK")
            }
        }
    }
    
    @IBAction func loginFacebook(_ sender: Any) {
        let autenticacao = LoginManager()
        autenticacao.logIn(permissions: [.publicProfile, .email, .userBirthday], viewController: self) { (resultado) in
            switch resultado {
            case .cancelled:
                print("Usuário clicou no botão cancelar")
            case .success(_, _, _):
                self.performSegue(withIdentifier: "segueLogin", sender: nil)
                self.facebookDados()
            case .failed(_):
                print("Ocorreu um erro inesperado")
            }
            
        }
    }
    
    func facebookDados () {
        if AccessToken.current != nil {
            GraphRequest(graphPath: "me", parameters: ["fields": "email, name, birthday"]).start { (conexao, resultados, erro) in
                //Recuperando o array de dados do usuário contidos em "resultados"
                let dict = resultados as! [String: AnyObject] as NSDictionary
                let nome = dict.object(forKey: "name") as! String
                let email = dict.object(forKey: "email") as! String
                let aniversario = dict.object(forKey: "birthday") as! String
                //let localizacao = dict.object(forKey: "user_location") as! String
                let dadosUsuario = ["nome": nome, "email": email, "aniversario": aniversario]
                print(dadosUsuario)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //Fazendo a barra de navegação aparecer 
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "Entrar"
    }
    
    //Fazendo o teclado fechar no momento em que o usuário clica na tela 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}
