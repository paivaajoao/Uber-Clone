//
//  TableViewControllerRequisicoes.swift
//  Uber Clone
//
//  Created by João Carlos Paiva on 17/01/21.
//  Copyright © 2021 João Carlos Paiva. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class TableViewControllerRequisicoes: UITableViewController {
    
    var requisicoes: [Requisicoes] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let referencia = Database.database().reference()
        //acessando os dados do nó requisicoes
        let requisicoes = referencia.child("requisicoes")
        requisicoes.observe(.childAdded) { (dados) in
            //convertando os dados para um formato que o swift entenda
            let dadosRequisicao = dados.value as? NSDictionary
            //recuperando o dado "nome" através do seu índice
            let nomeR = dadosRequisicao?["nome"] as? String ?? ""
            //recuperando o dado "email" através do seu índice
            let emailR = dadosRequisicao?["email"] as? String ?? ""
            //recuperando o dado "longitude" através do seu índice
            let longitude = dadosRequisicao?["longitude"] as! Double
            //recuperando o dado "latitude" através do seu índice
            let latitude = dadosRequisicao?["latidude"] as! Double
            
            
            let requisicaoInicializada = Requisicoes(nome: nomeR, email: emailR, latitude: latitude, longitude: longitude)
            self.requisicoes.append(requisicaoInicializada)
            print(self.requisicoes)
            
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func sair(_ sender: Any) {
        let alerta = UIAlertController(title: "Deseja mesmo sair do app?", message: "Você terá que utlizar seu E-mail e senha quando entrar novamente", preferredStyle: .actionSheet)
        let cancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        let sairDoApp = UIAlertAction(title: "Sair", style: .destructive) { (acao) in
            let autenticacao = Auth.auth()
            do {
                //Tentando deslogar o usuário
                try autenticacao.signOut()
                //Deslogando o usuário do facebook
                let logout = LoginManager()
                logout.logOut()
                
                //Fazendo com que a view volte ao início depois de deslogar o usuário
                self.dismiss(animated: true, completion: nil)
            }
            catch {
                //Caso não seja possíel deslogar o usuário do app
                print("Não foi possível deslogar o usuário")
            }
        }
        alerta.addAction(cancelar)
        alerta.addAction(sairDoApp)
        self.present(alerta, animated: true, completion: nil)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requisicoes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celula = tableView.dequeueReusableCell(withIdentifier: "celulaReuso", for: indexPath)
        //recuperando um dado por linha
        let requisicaoCelula = self.requisicoes[indexPath.row]
        celula.textLabel?.text = requisicaoCelula.nome
        celula.detailTextLabel?.text = requisicaoCelula.email
        return celula
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
