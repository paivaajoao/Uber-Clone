//
//  ViewController.swift
//  Uber Clone
//
//  Created by João Carlos Paiva on 22/12/20.
//  Copyright © 2020 João Carlos Paiva. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        let autenticacao = Auth.auth()
        autenticacao.addStateDidChangeListener { (auth, usuario) in
            if usuario != nil {
                let referencia = Database.database().reference()
                
                //acessando os dados contidos no nó "usuariosEmail"
                let usuariosEmail = referencia.child("usuariosEmail")
                
                //acessando os dados contidos no nó do usuário logado 
                let dadosUser = usuariosEmail.child(autenticacao.currentUser!.uid)
                dadosUser.observe(.value) { (dados) in
                    let dict = dados.value as? NSDictionary
                    //recuperando o dado referente ao tipo de usuário
                    let tipoUsuario = dict?["tipoUsuario"] as? String ?? ""
                    print(tipoUsuario)
                    
                    if tipoUsuario == "Passageiro" {
                        self.performSegue(withIdentifier: "segueDireta", sender: nil)
                    }else {
                        self.performSegue(withIdentifier: "segueTable", sender: nil)
                    }
                }
                print("O usuário está logado pelo Firebase")
            }
        }
        
        //Verificando se o usuário está logado com facebook e o redirecionando diretamente para a tela inicial do app caso ele esteja
        if AccessToken.isCurrentAccessTokenActive {
            self.performSegue(withIdentifier: "segueDireta", sender: nil)
            print("O usuário está logado pelo Facebook")
        }else {
            print("O usuário não está logado pelo facebook")
        }
    }
    
    //Escondendo a barra de navegação
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationItem.title = "Uber"
        
    }


}

