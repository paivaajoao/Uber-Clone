//
//  CadastrarViewController.swift
//  Uber Clone
//
//  Created by João Carlos Paiva on 26/12/20.
//  Copyright © 2020 João Carlos Paiva. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FBSDKLoginKit
import Firebase


class CadastrarViewController: UIViewController {
    
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var nomeCompleto: UITextField!
    @IBOutlet weak var senha: UITextField!
    @IBOutlet weak var senhaConfirmada: UITextField!
    @IBOutlet weak var tipoUsuario: UISwitch!
    
    var dataBase: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         if let token = AccessToken.current,
         !token.isExpired {
         let token = token.tokenString
         let requisicao = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
         requisicao.start { (conecao, resultados, error) in
         print("\(resultados)")
         }
         }else {
         let facebookButton = FBLoginButton()
         //facebookButton.center = view.center
         facebookButton.delegate = self
         facebookButton.permissions = ["public_profile", "email"]
         //view.addSubview(facebookButton)
         }
         
         // Do any additional setup after loading the view.
         */
    }
    
    func getAlert (title: String, message: String, titleAction: String) {
        let alerta = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmar = UIAlertAction(title: titleAction, style: .default, handler: nil)
        alerta.addAction(confirmar)
        present(alerta, animated: true, completion: nil)
    }
    
    @IBAction func cadastrarUsuario(_ sender: Any) {
        if let emailR = self.email.text {
            if emailR != "" {
                if let nomeCompletoR = self.nomeCompleto.text {
                    if nomeCompletoR != "" {
                        if let senhaR = self.senha.text {
                            if senhaR != "" {
                                if let senhaConfirmadaR = self.senhaConfirmada.text {
                                    if senhaR == senhaConfirmadaR {
                                        if senhaR != "123456" {
                                            if senhaR != "" {
                                                //Digitar todo o código que será executado caso passe pela verificação
                                                Auth.auth().createUser(withEmail: emailR, password: senhaR) { (usuario, erro) in
                                                    if erro == nil {
                                                        print("Sucesso ao cadastrar usuário")
                                                        if usuario == nil {
                                                            self.getAlert(title: "Tente novamente", message: "Ocorreu um erro inesperado ao cadastrar o usuário. Por favor, tente novamente", titleAction: "OK")
                                                        }else {
                                                            //Redirecionando o usuário para a tela inicial do app e adicionando seus dados para  banco de dados do DataBase do Firebase
                                                            var tipoUsuario = ""
                                                            //Verificando se a pessoa que se cadastrou é passageiro ou motorista
                                                            if self.tipoUsuario.isOn {
                                                                tipoUsuario = "Motorista"
                                                            }else {
                                                                tipoUsuario = "Passageiro"
                                                            }
                                                            self.dataBase = Database.database().reference()
                                                            let userId = Auth.auth().currentUser?.uid
                                                            //Criando o primeiro nó do Database
                                                            let usuario = self.dataBase.child("usuariosEmail")
                                                            let dadosUsuario = ["nome": nomeCompletoR, "email": emailR, "tipo": tipoUsuario]
                                                            usuario.child(userId!).setValue(dadosUsuario)
                                                            //Redirecionando o usuário para a tela inicial do app
                                                            self.performSegue(withIdentifier: "segueDestino", sender: nil)
                                                        }
                                                    }else {
                                                        print("Ocorreu um erro ao cadastrar usuário")
                                                        //Verificar qual foi o erro e informar o usuário
                                                        let erroR = erro as! NSError
                                                        if let codigo = erroR.code as? Int {
                                                            print(codigo)
                                                            var mensagemErro = ""
                                                            switch codigo {
                                                            case 17008:
                                                                mensagemErro = "E-mail inválido, digite um e-mail válido."
                                                                break
                                                                
                                                            case 17026:
                                                                mensagemErro = "Senha inválida, digite uma senha com 6 caracteres incluindo números e letras"
                                                                break
                                                                
                                                            case 17007:
                                                                mensagemErro = "O e-mail informado já está em uso, por favor digite um e-mail ainda não usado"
                                                                break
                                                                
                                                            default:
                                                                mensagemErro = "Dados incorretos"
                                                            }
                                                            self.getAlert(title: "Tente novamente", message: mensagemErro, titleAction: "OK")
                                                        }
                                                    }
                                                }
                                            }else {
                                                self.getAlert(title: "Tente novamente", message: "Digite uma senha válida com números e letras e tente novamente.", titleAction: "OK")
                                            }
                                        }else {
                                            self.getAlert(title: "Tente novamente", message: "As senhas não podem conter números em sequência.", titleAction: "OK")
                                        }
                                    }else {
                                        self.getAlert(title: "Tente novamente", message: "As senhas devem ser iguais.", titleAction: "OK")
                                    }
                                }
                            }else {
                                self.getAlert(title: "Tente novamente", message: "Digite uma senha válida e tente novamente.", titleAction: "OK")
                            }
                        }
                    }else {
                        self.getAlert(title: "Tente novamente", message: "Digite seu nome de usuário e tente novamente.", titleAction: "OK")
                    }
                }
            }else {
                self.getAlert(title: "Tente novamente", message: "Digite um e-mail válido.", titleAction: "OK")
            }
        }
    }
    @IBAction func botaoLogin(_ sender: Any) {
        self.facebookLogin()
    }
    
    func facebookLogin () {
        //Abrindo o navegador do facebook para que o usuário consiga preencher seus dados de login
        let loginManager = LoginManager()
        //Informando ao usuários os dados que serão coletados que no caso são: email e perfil e verificando o que o usuário
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { (resultado) in
            switch resultado {
            case .cancelled :
                print("Usuário clciou no botão cancelar")
            case .success(_, _, _)://Levando o usuário para a tela inicial do app
                self.facebookDados()
                self.performSegue(withIdentifier: "segueDestino", sender: nil)
            case .failed(_):
                print("Ocorreu um erro inesperado")
            }
        }
    }
    func facebookDados () {
        if AccessToken.current != nil {
            GraphRequest(graphPath: "me", parameters: ["fields": "email, name"]).start { (conexao, resultados, erro) in
                //Recuperando o array de dados do usuário contidos em "resultados"
                let dict = resultados as! [String: AnyObject] as NSDictionary
                let nome = dict.object(forKey: "name") as! String
                let email = dict.object(forKey: "email") as! String
                let dadosUsuario = ["nome": nome, "email": email]
                self.dataBase = Database.database().reference()
                //Criando o primeiro nó
                let usuariosFacebook = self.dataBase.child("usuariosFacebook")
                usuariosFacebook.setValue(dadosUsuario)
            }
        }else {
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true )
        self.navigationItem.title = "Cadastro"
    }
    
    //Fazendo o teclado fechar no momento em que o usuário clica na tela 
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
