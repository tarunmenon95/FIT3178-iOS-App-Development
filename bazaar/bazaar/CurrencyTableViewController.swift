//  CurrencyTableViewController.swift
//  bazaar


import UIKit

//Codable struct to parse currencyData
struct currencyData: Codable{
    var base_code : String
    var conversion_rates : Dictionary<String, Double>
}


//The CurrencyTableViewController handles all relevant actions/information for adding/displaying currencies in the table view
//which are retrieved via API query

class CurrencyTableViewController: UITableViewController {

    //Class Variables
    let SECTION_CURRENCY = 0
    let CELL_ITEM = "currencyCell"
    let apikey = " 514604fa79f89199d08b2dba"
    //req-https://v6.exchangerate-api.com/v6/514604fa79f89199d08b2dba/latest/AUD
    var currencies : [GeneralisedItem] = []
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
    }
    
    //When view loads, complete API Query to retrieve currency data, then store into currencies array to populate table view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //API Query
        guard let url = URL(string: "https://v6.exchangerate-api.com/v6/514604fa79f89199d08b2dba/latest/USD")
        else{
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
            }
            else if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let curInfo = try decoder.decode(currencyData.self, from: data)
                    let rates = curInfo.conversion_rates
                    
                    //Create currency items and add to array
                    for elem in rates {
                        let name = elem.key
                        let val = elem.value
                        let currency = GeneralisedItem(newName: name, newValue: val,newType: "Currency",newSymbol: name)
                        self.currencies.append(currency)
                    }
                    
                    //Reload table
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                 }
                catch {
                    print(error)
                }
                
            }
        }
        task.resume()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_CURRENCY:
            return currencies.count
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let itemCell = tableView.dequeueReusableCell(withIdentifier: CELL_ITEM, for: indexPath)
            let item = currencies[indexPath.row]
            itemCell.textLabel?.text = item.name
            itemCell.detailTextLabel?.text =  String(item.value)
            return itemCell
        
        
    }

}
