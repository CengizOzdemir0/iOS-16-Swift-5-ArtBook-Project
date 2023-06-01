//
//  ViewController.swift
//  artBookProject
//
//  Created by sys on 30.05.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableVliew: UITableView!
    //isim ve id çekmek için
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedPainting = ""
    var selectedPaintingId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        tableVliew.delegate = self
        tableVliew.dataSource = self
        
        getData()
    }
    // sayfa açılandığında yenilenen verileri çekmek için
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    
        // name datasını core datadan çekmek
    @objc func getData() {
            // sayfa ilk yüklenirken table boşaltma
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
            // data core bağlanma
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            
            
            do{
                // dizi öndüğü için result içine alıp for ile dönüp verileri alacağız
             let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                           if let name = result.value(forKey: "name") as? String {
                               self.nameArray.append(name)
                           }
                        if let id = result.value(forKey: "id") as? UUID {
                            self.idArray.append(id)
                        }
                        //reflesh etme
                        self.tableVliew.reloadData()
                        
                        
                       }
                }
                
                

                
            
            } catch {
                print("error")
            }
            
            
        }
        
        
        
    
    @objc func addButtonClicked(){
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    // 2 method ile tıklandığında yapılacak işlem
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaintingId = selectedPaintingId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    //silme işlemi
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do {
            let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableVliew.reloadData()
                                do{
                                    try context.save()
                                } catch {
                                    print("error")
                                }
                                break
                            }
                        }
                    }
                }
            } catch {
                print("error")
            }
            
        }
    }

}

