//
//  PassageiroViewController.swift
//  Uber Clone
//
//  Created by João Carlos Paiva on 07/01/21.
//  Copyright © 2021 João Carlos Paiva. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import MapKit

class PassageiroViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var gerenciadorDeLocalizacao = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configurarMapa()
    }
    
    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var botaoChamar: UIButton!
    var chamarUber = false
    
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
    
    func configurarMapa () {
        self.gerenciadorDeLocalizacao.delegate = self
        self.gerenciadorDeLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        self.gerenciadorDeLocalizacao.requestWhenInUseAuthorization()
        self.gerenciadorDeLocalizacao.startUpdatingLocation()
    }
    
    //Recuperando as coordenadas da localização do usuário e fazendo com que o mapa foque nele.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordenadas = self.gerenciadorDeLocalizacao.location?.coordinate {
            let regiao: MKCoordinateRegion = MKCoordinateRegion(center: coordenadas, latitudinalMeters: 200, longitudinalMeters: 200)
            self.mapa.setRegion(regiao, animated: true)
            //Criando uma anotação no local em que o usuário está 
            let anotacaoUsuario = MKPointAnnotation()
            anotacaoUsuario.coordinate = coordenadas
            anotacaoUsuario.title = "Seu local"
            self.mapa.addAnnotation(anotacaoUsuario)
        }
    }
    
    /*Quando o usuário clica no botão, é feita uma verificação se a variável "chamarUber" é true ou false. Caso ela seja false (como de padrão) é alterado o título do botão para "Cancelar Uber" e o valor da variável é alterado para true. Quando o usuário clica novamente no botão, é feita uma nova verificação se a variável é true ou false. Caso ela seja true, o título do botão volta a ser "Chamar Uber" e é cancelada a requisição para chamar um uber.
    Primeiro clique no botão -> Chama o uber e altera o título para "Cancelar Uber"
    Segundo clique no botão -> Cancela o uber e altera o título para "Chama Uber"
 */
    @IBAction func chamarUber(_ sender: Any) {
        if self.chamarUber == true {
            self.botaoChamar.setTitle("Chamar Uber", for: .normal)
            self.chamarUber = false
            //Codar a parte de apagar a requisição do firebase
        }else {
            //Recuperando os dados necessários para o motorista identificar o local em que o usuário está e qual seu nome e email. Esses dados estão sendo salvos no database
            let database = Database.database().reference()
            let autenticacao = Auth.auth()
            //Recuperando o email do usuário através do email cadastrado na autenticação
            if let email = autenticacao.currentUser?.email {
                //Recuperando os dados de latitude e longitude
                if let latitude = self.gerenciadorDeLocalizacao.location?.coordinate.latitude {
                    if let longitude = self.gerenciadorDeLocalizacao.location?.coordinate.longitude {
                        //criando um nó "requisições"
                        let requisicoes = database.child("requisicoes")
                        let dadosUsuario = ["nome": "", "email": email, "latidude": latitude, "longitude": longitude] as [String : Any]
                        //Criando mais um nó com uma identificação única e adicionando o valor contido no dicionário dadosUsuario
                        requisicoes.childByAutoId().setValue(dadosUsuario)
                    }
                }
            }
            self.botaoChamar.setTitle("Cancelar Uber", for: .normal)
            self.chamarUber = true
        }
    }
    
    //Verificando se o usuário permitiu o acesso à sua localização e criando um alerta caso ele não tenha permitido
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedWhenInUse && status != .notDetermined {
            let alerta = UIAlertController(title: "Permissão de localização", message: "É necessário acessar sua localização para chamar um Uber", preferredStyle: .alert)
            let naoPermitit = UIAlertAction(title: "Não permitir", style: .destructive, handler: nil)
            let permitit = UIAlertAction(title: "Permitir", style: .default) { (acao) in
                //Abrindo as configurações para que o usuário altere para autorizado durante o uso
                if let abrirConfiguracoes = NSURL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(abrirConfiguracoes as URL)
                }
            }
            alerta.addAction(naoPermitit)
            alerta.addAction(permitit)
            present(alerta, animated: true, completion: nil)
        }
    }
}
