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
import MapKit
import UserNotifications

class TableViewControllerRequisicoes: UITableViewController, CLLocationManagerDelegate {
    
    var gerenciadorDeLocalizacao = CLLocationManager()
    var localizacaoMotorista = CLLocationCoordinate2D()
    
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
            self.configurarMapa()
            
            //Quando forem adicionados dados no nó requisições, será exibida uma notificação para o motorista caso ele esteja fora do app
            let centroDeNotificacoes = UNUserNotificationCenter.current()
            centroDeNotificacoes.requestAuthorization(options: [.sound, .alert]) { (permissao, erro) in
            }
            let conteudo = UNMutableNotificationContent()
            conteudo.title = "Nova corrida!"
            conteudo.body = "\(nomeR) está lhe esperando!"
            
            let data = Date().addingTimeInterval(5)
            let componentesData = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: data)
            let trigger = UNCalendarNotificationTrigger(dateMatching: componentesData, repeats: false)
            //criando um identificador único
            let uuid = UUID().uuidString
            let requisicao = UNNotificationRequest(identifier: uuid, content: conteudo, trigger: trigger)
            centroDeNotificacoes.add(requisicao) { (erro) in
               
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordenadas = manager.location?.coordinate {
            self.localizacaoMotorista = coordenadas
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
        
        //recuperando os dados de localização do passageiro e do motorista e verificcando a distância entre os dois
        let latitudePassageiro = requisicaoCelula.latitude
        let longitudePassageiro = requisicaoCelula.longitude
        let motoristaCLLocation = CLLocation(latitude: (self.gerenciadorDeLocalizacao.location?.coordinate.latitude)!, longitude: (self.gerenciadorDeLocalizacao.location?.coordinate.longitude)!)
       let passageiroCLLocation = CLLocation(latitude: latitudePassageiro, longitude: longitudePassageiro)
        //convertendo a distância em quilômetros e arredondando
        let distancia = round(motoristaCLLocation.distance(from: passageiroCLLocation) / 1000)
        
        celula.textLabel?.text = requisicaoCelula.nome
        celula.detailTextLabel?.text = "\(requisicaoCelula.nome) está a \(distancia) Km de distância"
        return celula
    }
    
    func configurarMapa () {
        self.gerenciadorDeLocalizacao.delegate = self
        self.gerenciadorDeLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        self.gerenciadorDeLocalizacao.requestWhenInUseAuthorization()
        self.gerenciadorDeLocalizacao.startUpdatingLocation()
    }
    
}
