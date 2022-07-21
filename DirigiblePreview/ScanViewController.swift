//
//  ScanViewController.swift
//  DirigiblePreview
//
//  Created by Dermendzhiev, Teodor (external - Project) on 19.07.22.
//

import UIKit
class ScanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScannerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var history = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        history = UserDefaults.standard.object(forKey: "history") as? [String] ?? [String]()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return history.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "scan-cell", for: indexPath)
            } else {
                return tableView.dequeueReusableCell(withIdentifier: "add-url-cell", for: indexPath)
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "history-cell", for: indexPath)
            cell.textLabel?.text = history[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 200
            }
            return 60
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "History"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let vc = ScannerViewController()
                vc.delegate = self
                present(vc, animated: true)
            }
            if indexPath.row == 1 {
                openURLAlert()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func didFoundCode(code: String) {
        history.append(code)
        UserDefaults.standard.set(history, forKey: "history")
        tableView.reloadData()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "webapp") as! WebAppViewController
        vc.appUrl = code
        present(vc, animated: true)
    }
    
    func openURLAlert() {
        let alert = UIAlertController(title: "Open URL", message: "Write a URL", preferredStyle: .alert)
  
        alert.addTextField { (textField) in
            textField.text = ""
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if let code = textField?.text {
                self.didFoundCode(code: code)
            }
            
        }))

        self.present(alert, animated: true, completion: nil)
    }
}
