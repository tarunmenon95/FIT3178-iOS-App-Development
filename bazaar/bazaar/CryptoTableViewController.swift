//  CryptoTableViewController.swift
//  bazaar


import UIKit

//Codable struct for parsing responseData
struct responseData: Codable{
    var data: [CryptoData]
}

//Codable struct for parsing CryptoData
struct CryptoData: Codable{
    var name: String
    var symbol: String
    var quote: CryptoQuote
}

//Codable struct for parsing CrpytoQuote
struct CryptoQuote: Codable{
    var USD : USD
}

//Codable struct for parsing USD
struct USD : Codable{
    var price : Double
}


//The CryptoTableViewController handles all relevant actions/information for retrieving data of all cryptocurrencies and displaying
//them in the given table view
class CryptoTableViewController: UITableViewController {
    
    //Class Variables
    var API_KEY = "YPLFAE6NHIS6LIEX"
    let SECTION_CRYPTO = 0
    let CELL_CRYPTO = "cryptoCell"
    var cryptocurrencies: [GeneralisedItem] = []

    //When view loads, complete API Query, parse data and store relevant information into cryptocurrencies array
    override func viewDidLoad() {
        super.viewDidLoad()

        //API Query
        let CryptoURL = URL(string: "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?start=1&limit=50&convert=USD")
        if let unwrappedURL = CryptoURL {
            var request = URLRequest(url: unwrappedURL)
            request.addValue("00442964-46da-4ce7-b8b1-27639d1e3352", forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print(error)
                }
                else if let data = data {
                    do {
                      
                        let decoder = JSONDecoder()
                        let cryptoInfo = try decoder.decode(responseData.self, from: data)
                        let cd = cryptoInfo.data
                        
                        //Create generalised item for each crypto, then store into array
                        for elem in cd {
                            let name = elem.name
                            let price = elem.quote.USD.price
                            let symb = elem.symbol
                            let crypto = GeneralisedItem(newName: name, newValue: price,newType: "Crypto",newSymbol: symb)
                            self.cryptocurrencies.append(crypto)
                        }
                        
                        //Reload table view
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                }
                    catch{
                        print(error)
            }
            }
            
            }
            task.resume()
        }
    }
    
    //When segueing to DetailedInformation screen, set variables for the API Query
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cryptoSegue"{
            let destination = segue.destination as! DetailedInformationViewController
            
            if let cell = sender as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell){
                destination.navigationItem.title = cryptocurrencies[indexPath.row].name
                destination.symbol = cryptocurrencies[indexPath.row].symbol
                destination.type = "Crypto"
            }
        }
    }

    // MARK: - Table view data sourc
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_CRYPTO:
            return cryptocurrencies.count
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cryptoCell = tableView.dequeueReusableCell(withIdentifier: CELL_CRYPTO, for: indexPath)
        let item = cryptocurrencies[indexPath.row]
        cryptoCell.textLabel?.text = item.name
        cryptoCell.detailTextLabel?.text =  String(item.value)
        return cryptoCell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
    }

}
