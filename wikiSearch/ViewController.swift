//
//  ViewController.swift
//  wikiSearch
//
//  Created by Mac19 on 12/05/21.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var buscarText: UITextField!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let urlWikipedia = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Wikipedia-logo-v2-es.svg/135px-Wikipedia-logo-v2-es.svg.png"){
            webView.load(URLRequest(url: urlWikipedia))
        }
        
        
        
    }
    @IBAction func buscarPalabra(_ sender: UIButton) {
        buscarText.resignFirstResponder()
        guard let palabraB = buscarText.text else{
            return
        }
        buscarWiki(palabras: palabraB)
    }
    
    
    func buscarWiki(palabras: String){
        if let urlAPI = URL(string: "https://es.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&titles=\(palabras.replacingOccurrences(of: " ", with: "%20"))"){
            let peticion = URLRequest(url: urlAPI)
            
            let tarea = URLSession.shared.dataTask(with: peticion) { (datos, respuesta, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }else{
                    do {
                        let objJson =  try JSONSerialization.jsonObject(with: datos!, options:  JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        
                        let querySubJson = objJson["query"] as! [String: Any]
                       
                        
                        let pagesSubJson = querySubJson["pages"] as! [String: Any]
                        
                        let pagesId = pagesSubJson.keys
                        
                        
                       
                        let llaveExt = pagesId.first!
                        print("pages id: \(llaveExt)")
                        let idSubJson = pagesSubJson[llaveExt] as! [String: Any]
                        
                        if let extracto = idSubJson["extract"] as? String{
                            //imprimir en la ui
                            DispatchQueue.main.async {
                                self.webView.loadHTMLString(extracto, baseURL: nil)
                            }
                        }else {
                            if llaveExt == "-1" {
                               print("pages id: \(llaveExt)")
                                
                                DispatchQueue.main.async {
                                    let alerta = UIAlertController(title:"ERROR", message: "Esta busqueda no es valida", preferredStyle: .alert)
                                    
                                    let aceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
                                    alerta.addAction(aceptar)
                                    self.present(alerta, animated: true)
                                }
                                
                               
                            }
                        }
                        
                        
                        
                        
                    } catch  {
                        print("Error al procesar el JSON\(error.localizedDescription)")
                    }
                }
                
            }
            tarea.resume()
            
        }
        
        
    }

}

