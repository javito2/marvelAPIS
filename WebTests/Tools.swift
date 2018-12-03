//
//  Tools.swift
//  WebTests
//
//  Created by Dev1 on 29/11/2018.
//  Copyright © 2018 Dev1. All rights reserved.
//

import UIKit
import CommonCrypto


let publicKey = "89c787f1a15c710a23002f5169c9d4d0"
let privateKey = "2d696a47fd76904791ac5d2bd09a526c2a76df99"

//es pagina web autorization
var baseURL = URL(string: "https://gateway.marvel.com/v1/public")!

func conexionMarvel() {
    //usamos esto porque asi está en un ejemplo, hora unix
   let ts = "\(Date().timeIntervalSince1970)"
    //formo la firma
   let valorFirmar = ts+privateKey+publicKey
    
   //monto la llamada con sus parametros, me lo dice la pagina  web
   let queryts = URLQueryItem(name: "ts", value: ts)
   let queryApikey = URLQueryItem(name: "apikey", value: publicKey)
    // valorFirmar.MD5, estoy llamando al metod MD5 que pertece ya a clase string
   let queryHash = URLQueryItem(name: "hash", value: valorFirmar.MD5)
   let queryLimit = URLQueryItem(name:"limit", value: "100")
   let queryOrder = URLQueryItem(name:"orderBy", value: "onsaleDate")
   let queryFormat = URLQueryItem(name:"format", value: "hardcover")
   
   var url = URLComponents()
   url.scheme = baseURL.scheme
   url.host = baseURL.host
   url.path = baseURL.path
   url.queryItems = [queryts, queryApikey, queryHash, queryLimit, queryOrder, queryFormat]
   
    // inicializamos conexion
   let session = URLSession.shared
     //digo a la url que voy
   var request = URLRequest(url: url.url!.appendingPathComponent("comics"))
       //tengo que hacer un get, tambien put
   request.httpMethod = "GET"
   request.addValue("*/*", forHTTPHeaderField: "Accept")
   
   /*
   if let etag = etag {
      request.addValue(etag, forHTTPHeaderField: "If-None-Match")
   }
   */
   session.dataTask(with: request) { (data, response, error) in
      guard let data = data,
        let response = response as? HTTPURLResponse,
        error == nil else {
            if let error = error {
               print("Error en la comunicación \(error)")
             }
             return
        }
      if response.statusCode == 200 {
         //llamo a mi funcion
      //   print(String(data: data, encoding: .utf8)!)
         cargar(datos: data)
         /* en el json tenemos 20 registros
          enpiezan en el id
         con codable no tengo que meter todas los campos
          etag es identificador
         cada grupo de datos tiene que se un codable diferente
         buscar el ultimo nivel
          primera es data
          creo modelo.swift
         */
      } else {
         print(response.statusCode)
         
      }
    // resume lanza la llamada
   }.resume()
}

//la llamada es con parametros
/* esta es la llamada
 For example, a user with a public key of "1234" and a private key of "abcd"
 could construct a valid call as follows:
 http://gateway.marvel.com/v1/public/comics?ts=1&apikey=1234&hash=ffd275c5130566a2916217b101f26150
 (the hash value is the md5 digest of 1abcd1234)
 */


//funcion para recuperar la fecha para el timeStam
func getDateTime() -> String {
   let fecha = Date()
    //hay que formatear la fecha, usamos la clase Dateformatter
   let formatter = DateFormatter()
    //   otra forma, año+hora
    //formatter.dateStyle = .full
    // formatter.timeStyle = .full
   formatter.dateFormat = "ddMMyyyyhhmmss"
   return formatter.string(from: fecha)
}


// lo meto a la clase string, para usarla sera stringMDR = string.MD5
// el valor firma hay que convertirlo en md5 que es con lo que trabaja la pagina web
// si la pagina web usa otro formato hay que transformarlo a dicho formato
// el md5 no se usa mucho
extension String {
   var MD5:String? {
    
      guard let messageData = self.data(using: .utf8) else {
         return nil
      }
    // necesito un valor de tipo data al que le digo la longitud y lo relleno de 0
    // importo -- import CommonCrypto
      var datoMD5 = Data(count: Int(CC_MD5_DIGEST_LENGTH))
    // me da igual lo que me devuelve la funcion, por eso pongo _
    // tengo de parametro de mi clousure bytes
    _ = datoMD5.withUnsafeMutableBytes { bytes in
         messageData.withUnsafeBytes { messageBytes in
            CC_MD5(messageBytes, CC_LONG(messageData.count), bytes)
         }
      }
    //tengo que cambiar de formato la cadena, creo un String vacio
      var MD5String = String()
    //me recorro datoMD5 caracter a caracter y lo voy metiendo en c
      for c in datoMD5 {
        // hago el formato al caracter c y lo voy metiendo en la cadena
        // para pasar a hexadecimal, %02x
         MD5String += String(format: "%02x", c)
      }
      return MD5String
   }
}

func recuperaURL(url:URL, callback:@escaping (UIImage) -> Void) {
   let conexion = URLSession.shared
   //datatask devuelve codigo fuente
   //downloadtask devuelve el sitio en disco donde se ha descargado la url
   //uploadtask puedo subir datos
   //url o urlrequest, request quiero modificar las cabeceras en la peticion
   
   /* para enviar datos
    let request = URLRequest(url:url)
    request.httpBody
    
    */
   conexion.dataTask(with: url) { (data, response, error) in
      // hace la conexion a la url y cuando se ejecuta la llamada hace la funcion del clousure y siempre devuelve 3 parametros
      // los 3 parametros son opcionales aunque no se vea, por eso el guard
      guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
         if let error = error {
            print("Error en la conexión de red \(error.localizedDescription)")
         }
         return
      }
      // 200 significa que ha ido bien, hay mas codigos que se pueden mirar en wikipedia
      if response.statusCode == 200 {
         if let imagen = UIImage(data: data) {
            callback(imagen)
         }
      }
      //resume termina la conexion
      }.resume()
}

