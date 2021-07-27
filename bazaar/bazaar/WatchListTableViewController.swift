//  WatchListTableViewController.swift
//  bazaar


import UIKit
import UserNotifications

//The WatchListTableViewController handles all relevant actions/information for displaying all items stored within the users
//watch list. The watch list utlises core daa to ensure the items persist after the application is closed. The class also uses
//User notifications to alert the user to the current trends of the watch lists value.
class WatchListTableViewController: UITableViewController, DatabaseListener{
    
    //Class Variables
    var price = 0.0
    let SECTION_ITEM = 0
    var count = 0
    let CELL_ITEM = "watchCell"
    var currentWatchList : [GeneralItem] = []
    var cryptoPrices : [GeneralisedItem] = []
    var stockPrices : [GeneralisedItem] = []
    
    //Core Data
    var listenerType = ListenerType.generalItem
    weak var databaseController: DatabaseProtocol?
    
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
    }

    //When the view loads, initialise databaseController and call cryptoCheck and stockUpdate to update watched items to
    //realtime values
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        //Update Cryptos
        cryptoCheck()
        //Update Stocks
        stockUpdate()
    }
    
    //Fucntion that updates current watch list when a change is detected in core data
    func onGeneralItemChange(change: DatabaseChange, generalItem: [GeneralItem]) {
        currentWatchList = generalItem
        tableView.reloadData()
    }
 
    //Add / Remove Listeners
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    //When seguein to DetailedInformation screen, set variables to currently selected item for API Query
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "watchlistSegue"{
            let destination = segue.destination as! DetailedInformationViewController
            
            if let cell = sender as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell){
                destination.navigationItem.title = currentWatchList[indexPath.row].name
                destination.symbol = currentWatchList[indexPath.row].symbol
                destination.type = currentWatchList[indexPath.row].type
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_ITEM:
            return currentWatchList.count
        default:
            return 0
        }
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let itemCell = tableView.dequeueReusableCell(withIdentifier: CELL_ITEM, for: indexPath)
            let item = currentWatchList[indexPath.row]
            itemCell.textLabel?.text = item.name
            itemCell.detailTextLabel?.text =  String(item.value)
            return itemCell
    }
    

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Remove from core data when deleting
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let genItem = currentWatchList[indexPath.row]
            databaseController?.removeGeneralItem(generalItem: genItem)
        }
    }

    //Function to create user notififcation and add to notifcation center.
    //Notifies current trend of watched crypto's
    func cryptoNotif(value: Double){
        let content = UNMutableNotificationContent()
        let value = Int(value)
        
        if value > 0{
            content.title = "Crypto Trending Up!"
            content.body = "Your Tracked Crypto have gone up $\(value) since your last visit!"
        }
        else{
            let value = -value
            content.title = "Crypto Trending Down!"
            content.body = "Your Tracked Crypto have gone down $\(value) since your last visit!"
        }
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "cryptoNotif", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    //Function to update all stocks in watchlist to realtime values
    func stockUpdate(){
        let curWatchList = self.databaseController?.fetchAllGeneralItems()
        for i in curWatchList ?? [] {
            if i.type == "Stock"{
                stockCheck(aSymbol: i.symbol, i: i)
            }
        }
    }
    
    //Function to do api query on given stock, will then update values in core data
    func stockCheck(aSymbol:String, i:GeneralItem){
        
        //Api Query
        guard let url = URL(string: "https://finnhub.io/api/v1/quote?symbol=\(aSymbol)&token=c2vjl72ad3ifkigbq5o0")
        else{
            print("Invalid URL")
            return
        }
        
        let otherTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
            }
            else if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let fins = try decoder.decode(stockQuote.self, from: data)

                    //Update price in core data
                    self.price = fins.c
                    let _ = self.databaseController?.editItem(name: i.name, value: self.price, symbol: i.symbol, type: i.type)
                 }
                
                catch {
                    print(error)
                }
            }
        }
        otherTask.resume()
    }
    
    //Function to update all cryptos in watchlist to real time values
    func cryptoCheck(){
     
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
                        
                        //Get all real time prices
                        for elem in cd {
                            
                            let name = elem.name
                            let price = elem.quote.USD.price
                            let symb = elem.symbol
                            let crypto = GeneralisedItem(newName: name, newValue: price,newType: "Crypto",newSymbol: symb)
                            self.cryptoPrices.append(crypto)
                            
                        }
                        var cryptoChange = 0.0
                        
                        //Update all cryptos to new values
                        let curWatchList = self.databaseController?.fetchAllGeneralItems()
                        for i in curWatchList ?? [] {
                            if i.type == "Crypto"{
                                _ = i.name
                                _ = i.symbol
                                let oldPrice = i.value
                                
                                for j in self.cryptoPrices{
                                    if j.symbol == i.symbol{
                                        self.price = j.value
                                        break
                                    }
                                }
                                if i.value != self.price {
                                    let _ = self.databaseController?.editItem(name: i.name, value: self.price, symbol: i.symbol, type: i.type)
                                    cryptoChange += Double(self.price - oldPrice)
                                }
                            }
                        }
                        self.cryptoNotif(value: cryptoChange)
        
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

}
