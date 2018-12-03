//
//  Modelo.swift
//  WebTests
//
//  Created by Dev1 on 30/11/2018.
//  Copyright © 2018 Dev1. All rights reserved.
//


import CoreData

import UIKit



/* me interesa struct y data
   primer nivel interesa etag y data
  en data me interesa results
 
 pool and refest, con el etag podemos actualizar los datos
 vamos a meterlo ahora en base de datos
 1 .-modelo de datos
 2.- configurar coredata, contexto, cargar, etc.. copiar del otro proyecto
 3.- modificar la carga en el modelo de este proyecto, funcion cargar, en vez de guardar datos en arraya meterlo en base de datos
 4.- entrar en la tabla y los datos en vez de cogerlos de memoria cogerlos con NSFETCHEDR result controller
 5.- pantalla detalle
 6.- pantallas que conecten
*/

//tenemos que ir moviendonos por el json cogiendo los campos que nos interesen
struct RootJson:Codable {
   let etag:String
   struct Data:Codable {
      let  count:Int
      struct Results:Codable {
         let id:Int
         let title:String
         let issueNumber:Int
         let variantDescription:String
         let description:String?
         // es un array
         struct Prices:Codable {
            let type:String
            let price:Double
         }
         let prices:[Prices]
         struct Thumbnail:Codable {
            let path:URL
            //extension es palabra reservada
            // extension ahora se llama en mi pgm imagenExtension
            let imageExtension:String
            enum CodingKeys:String, CodingKey{
               case path
               case imageExtension = "extension"
            }
            //se podria crear esta variable calculada para el path completo
            // ponemos ? por si acaso se toma como un campo del json y porque pathComponents?.url?
            // es opcional
            var fullPath:URL? {
               var pathComponents = URLComponents(url: path, resolvingAgainstBaseURL: false)
               pathComponents?.scheme = "https"
             return pathComponents?.url?.appendingPathComponent("portrait_incredible").appendingPathExtension(imageExtension)
               
            }
         }
         let thumbnail:Thumbnail
         struct Creators:Codable {
            let items:[Items]
            struct Items:Codable {
               let name:String
               let role:String
            }
         }
         let creators:Creators
      }
      let results:[Results]
   }
   //no es un array, solo un registro
   let data:Data
}

var datosCarga:RootJson?

//la clase UserDefaults es una clase que es persistente, se guarda en disco para siguiente aplicacion
//lo voy a usar para guardar el etag, seria un fallo de seguridad
var etag:String?

func cargar(datos:Data) {
   let decode = JSONDecoder()
   do {
      datosCarga = try decode.decode(RootJson.self, from: datos)
      //guardo el etag para que exista en proxima ejecucion
      UserDefaults.standard.set(datosCarga?.etag, forKey: "etag")
      //appdelegate, se ha añadido una linea para que carge el etag si existe, igual al sharepreferences de android
      etag = datosCarga?.etag
      // hacemos una notificacion para avisar a la tabla cuando recarga los datos
      NotificationCenter.default.post(name: NSNotification.Name("OKCARGA"), object: nil)
   } catch{
      print("Fallo en la serializacion \(error)")
   }
   
}

// coredata
//structura para la base de datos
struct RootBD:Codable {
   var count:Int
   var id:Int
   var title:String
   var issueNumber:Int
   var variantDescription:String
   var descripcion:String?
   // prices ya no es un array
   var prices:Double
   //url imagen
   var imagenURL:URL
   //autores en un array
   var autores:[String]
   
   /*creamos el constructor para cuando insertemos con add
   init(count: Int, id: Int, title: String, issueNumber: Int, variantDescription: String,
        descripcion: String?, prices: Double,imagenURL: URL,autores: [String] ){
      self.count = count
      self.id = id
      self.title = title
      self.issueNumber = issueNumber
      self.descripcion = descripcion
      self.prices = prices
      self.imagenURL = URL(string:"https//google.es")!
      self.autores[] = autores[]
   }
 */
}
 

var datosCargaBD:RootBD?


//creo el contenedor de persistencia, PS
var persistentContainer: NSPersistentContainer = {
   let container = NSPersistentContainer(name: "Comics")
   container.loadPersistentStores { (storeDescripcion, error) in
      if let error = error as NSError? {
         fatalError("Error inicializacion de la base de datos")
      }
   }
   return container
}()

//voy a crear el contexto
var context:NSManagedObjectContext {
   return persistentContainer.viewContext
}

//grabacion del contexto, el commit
func saveContext(){
   // si hay cambios
   if context.hasChanges{
      // un do try catch porque graba en bd
      do {
         try context.save()
      } catch{
         print("Error en la grabacion en base de datos \(error)")
      }
   }
}

