//
//  ComicTableViewController.swift
//  WebTests
//
//  Created by Dev1 on 29/11/2018.
//  Copyright © 2018 Dev1. All rights reserved.
//

//autentificar servidor, API Rest
// tiene varias formas
/* html
 header -> authorization
 body
 html
 
 Lsa 3 formas:
 API Rest esta basada en json
 1.- basic authentication
 en base 64, se envia usuario:contraseña en todas las peticiones
 
 2.- OAUTH 2, basada en token, lo veremos
 primero hace la basica mas api key
 el sistema me devuelve un token que yo almaceno
 yo envio el token en cada llamada
 triple paso, el sistema me devuelve un token persistente que yo le envio y me devuelve un token que caduca a la hora por ejemplo
 3.-desafios de autentificacion
 certificado de certificacion, seguridad social
 protocolo ntlp
 
 ats en appel, son normas de transporte de seguridad en appel
 regla 1 -> el sistema no puede conectar JAMAS a una pagina que no tenga certificado https
 2 excepciones,
 1 recuperar audio o video
 2 usando safari
 
 appel desde ios 9 obliga a usar su libreria de conexion sino te tiran abajo el proyecto. alamofire la usa
 */

/*
 he marcado gih repositorio
 barrita azul son los cambios, pinchandola puedo descartar los cambios
 arriba izquierda el segundo con forma de caja es el gib
 branches son los cambios
 tag son las etiquetas
 remotos son las versiones que hay en los servidores remotos, gibhud
 */


import UIKit

/* entramos en https://developer.marvel.com/
   tienen api gratis
  get key, nos damos de alta
 public  89c787f1a15c710a23002f5169c9d4d0
 privada 2d696a47fd76904791ac5d2bd09a526c2a76df99
 ponemos *.marvel.com y update
 
 hacemos el storyboard, tabla y custon celda con imagen y 2 label
 
 luego creamos archivo swift de tool
 
 en https://developer.marvel.com/documentation/generalinfo
 
 Status Code: 200   ->> es correcto
 Access-Control-Allow-Origin: *
 Date: Wed, 18 Dec 2013 22:00:55 GMT
 Connection: keep-alive
 ETag: f0fbae65eb2f8f28bdeea0a29be8749a4e67acb3
 Content-Length: 54943
 Content-Type: application/json
 
 https://developer.marvel.com/documentation/authorization vemos cosas
 
 */


/*
 animatables, valores de las vistas que puedo cambiar con el tiempo
 opacidad (alpha), empiezo con 10 y le digo que en 1 segundo sea 0 y el lo va cambiando
 clase estatica de uiView
 
 */

class ComicTableViewController: UITableViewController {
   
   override func viewDidLoad() {
      super.viewDidLoad()
      conexionMarvel()
      //si el observador dice okcarga reloadtabla con los datos
      NotificationCenter.default.addObserver(forName:NSNotification.Name("OKCARGA"), object: nil, queue: OperationQueue.main) {
         _ in
         self.tableView.reloadData()
         guard let blur = self.navigationController?.view.viewWithTag(200) as? UIVisualEffectView,
         let activity = self.navigationController?.view.viewWithTag(201) as? UIActivityIndicatorView else {
            return
         }
         //borro las pantallas de carga
       //  blur.removeFromSuperview()
      //   activity.stopAnimating()
      //   activity.removeFromSuperview()
         
         //lo de arriba lo sustituyo por, hace animacion de 1 segundo que cuando acabe me de un alpha 0 a blur
       //  UIView.animate(withDuration: 1.0) {
      //      blur.alpha = 0.0
     //    }
         
         //quiero animacion de 1 segundo y que haga blur y activity opaco a 0 y cuando termine pare animacion y remueva ventanas
         UIView.animate(withDuration: 1.0, animations: {blur.alpha = 0.0; activity.alpha = 0.0}) {
            finished in
            if finished {
               blur.removeFromSuperview()
               activity.stopAnimating()
               activity.removeFromSuperview()
               
            }
         }
         
      }
      
      //pantalla de carga, lo hago sobre el navigation para que tape todo
      let blurEffect = UIBlurEffect(style: .regular)
      let blurredEffectView = UIVisualEffectView(effect: blurEffect)
      blurredEffectView.frame = navigationController?.view.frame ?? CGRect.zero
      blurredEffectView.tag = 200
      navigationController?.view.addSubview(blurredEffectView)
      //cacharro dando vueltas
      let activity = UIActivityIndicatorView(style: .whiteLarge)
      activity.frame = navigationController?.view.frame ?? CGRect.zero
      activity.tag = 201
      activity.startAnimating()
      navigationController?.view.addSubview(activity)
   }
   
   // MARK: - Table view data source
   override func numberOfSections(in tableView: UITableView) -> Int {
      // #warning Incomplete implementation, return the number of sections
      return 1
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      // #warning Incomplete implementation, return the number of rows
      return datosCarga?.data.count ?? 0
   }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath) as! ComicViewCell
    
      if let datosComic = datosCarga?.data.results[indexPath.row] {
         cell.cabecera.text = datosComic.title
         var descriptionText:String = ""
         if let descripcion = datosComic.description {
             descriptionText += descripcion
         } else {
            descriptionText = "Descripcion no disponible"  
         }

         if let precio = datosComic.prices.first?.price  {
            descriptionText += "\n"
            descriptionText += "Precio: \(precio)"
         }
         
         cell.detalle.text = descriptionText
          // de tools del otro proyecto hemos copiado recuperaURL
      
         if let imagenURL = datosComic.thumbnail.fullPath{
            recuperaURL(url: imagenURL){
               imagen in
               // se usa para traerlo al hilo principal
               DispatchQueue.main.async {
                   //hemos copiado archivo extensions del otro proyecto y arrastrado al proyecto
                  if let resize = imagen.resizeImage(newWidth: cell.imagen.bounds.size.width){
                    cell.imagen.image = resize
                  }
               }
            }
         }
   
      //   print(datosComic.thumbnail.fullPath)
   /*      if let precioTexto =  datosComic.prices.first?.price {
             cell.detalle.text = String(precioTexto)
         }
   */
      }
      
      return cell
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
   
   //quito el observador
   deinit {
      NotificationCenter.default.removeObserver(self, name: NSNotification.Name("OKCARGA"), object: nil)
   }
   
}

