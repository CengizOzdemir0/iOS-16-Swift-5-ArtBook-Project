//
//  DetailsVC.swift
//  artBookProject
//
//  Created by sys on 30.05.2023.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            saveButton.isHidden = true
            
            
            // core datadan seçilen veriyi getirme
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            // verileri almadan önce filtreleme yapmamız gerekir
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
                
            } catch {
                print("error")
            }
           
            
            
            
        } else {
            // gerek yok ama bilgi amaçlı eklenebilir
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
        
        //Recognizers
    
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
       
        
    }
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary // sadece galeri açısın demek
        picker.allowsEditing = true // forograf üzerinde ayarlamak için
        present(picker,animated: true,completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil) // geri döndüğünde kapatmak için
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate   // app delegate classını buradan çağırıyoruz
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
                                                                             
        //Attiributes
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        if let year = Int(yearText.text!) {
        newPainting.setValue(year, forKey: "year")
        }
        
        
        newPainting.setValue(UUID(), forKey: "id")
        //UI image dataya çevirme
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        do{
            try context.save()
            print("success")
        } catch {
            print("eror")
        }
        //verinin değişitğini core dataya bildirmek
        // new data viewController içinde kontrol edip tekrar çağırılıp sayfanın yenilenmesi için 
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        // kaydetme işleminden sonra geri bir önceki sayfaya dönmek
        self.navigationController?.popViewController(animated: true)
        
    }
    
  

}
