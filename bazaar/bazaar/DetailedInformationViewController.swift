//  DetailedInformationViewController.swift
//  bazaar

import UIKit

//Codable struct to parse stockQuotes
struct stockQuote : Codable{
    var c : Double
    var h : Double
    var l : Double
    var o : Double
    var pc : Double
    var t: Double
}

//Codable struct to parse financials
struct financials : Codable{
    var metric : finData
}

//Codable struct to parse finData
struct finData : Codable{
    var FiftyTwoWeekHigh : Double?
    var FiftyTwoWeekLow : Double?
    var beta : Double?
    var marketCapitalization : Double?
    var TenDayAvg : Double?
    
    private enum CodingKeys:String, CodingKey {
        case beta
        case FiftyTwoWeekHigh = "52WeekHigh"
        case FiftyTwoWeekLow = "52WeekLow"
        case marketCapitalization
        case TenDayAvg = "10DayAverageTradingVolume"
        
    }
    
}

//Codable struct to parse cryptoCoin
struct cryptoCoin:Codable{
    var price: String
    var max_supply:String?
    var market_cap: String?
    var rank: String?
    var high: String?
    var daily: cryptoDaily?
    
    private enum CodingKeys:String, CodingKey {
        case price
        case max_supply
        case market_cap
        case rank
        case high
        case daily = "1d"
    }
}

//Codable struct to parse crpytoDaily
struct cryptoDaily: Codable{
    var volume : String?
    var price_change: String?
    var volume_change: String?
}

protocol graphTypeDelegate {
    func selectGraphType(type: String, symbol: String)
}

//The DetailedInformationViewController handles all relevant actions/information for creating and displaying the detailed information for
//any given stock/crypto, furthermore contains the DetailedGraph view. The class utilised core data and database listeners to add favourites
//items to the core data as display them in the users watchlist

class DetailedInformationViewController: UIViewController, DatabaseListener {
    
    //Class Variables
    var graphDelegate: graphTypeDelegate?
    var listenerType = ListenerType.generalItem
    weak var databaseController: DatabaseProtocol?
    var symbol = ""
    var type = ""

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    //View labels
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var closeLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var betaLabel: UILabel!
    @IBOutlet weak var weekHighLabel: UILabel!
    @IBOutlet weak var weekLowLabel: UILabel!
    @IBOutlet weak var marketCapLabel: UILabel!
    @IBOutlet weak var tenDayAverageLabel: UILabel!

    @IBOutlet weak var openHeader: UILabel!
    @IBOutlet weak var closeHeader: UILabel!
    @IBOutlet weak var highHeader: UILabel!
    @IBOutlet weak var lowHeader: UILabel!
    @IBOutlet weak var currentHeader: UILabel!
    @IBOutlet weak var betaHeader: UILabel!
    @IBOutlet weak var weekHighHeader: UILabel!
    @IBOutlet weak var weekLowHeader: UILabel!
    @IBOutlet weak var marketCapHeader: UILabel!
    @IBOutlet weak var tendayAvgHeader: UILabel!
    
    //When the view loads, complete a series of API Queries to retrieve the key summary statistics of the selected stock/crypto
    //Data is used to display in relevant labels in the view
    override func viewDidLoad() {
        super.viewDidLoad()

        graphDelegate?.selectGraphType(type: type, symbol: symbol)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        symbolLabel.text = symbol
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        //Stock API Query
        if type == "Stock"  {
            guard let url = URL(string: "https://finnhub.io/api/v1/quote?symbol=\(symbol)&token=c2vjl72ad3ifkigbq5o0")
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
                        let stock = try decoder.decode(stockQuote.self, from: data)
                        
                        //Update labels with data
                        DispatchQueue.main.async {
                            self.priceLabel.text = String(stock.c)
                            self.openLabel.text = String(stock.o)
                            self.closeLabel.text = String(stock.pc)
                            self.highLabel.text = String(stock.h)
                            self.lowLabel.text = String(stock.l)
                            self.currentLabel.text = String(stock.c)
                            
                            self.openHeader.text = "Open"
                            self.closeHeader.text = "Close"
                            self.highHeader.text = "High"
                            self.lowHeader.text = "Low"
                            self.betaHeader.text = "Beta"
                            self.currentHeader.text = "Current"
                            self.weekHighHeader.text = "52 Week High"
                            self.weekLowHeader.text = "52 Week Low"
                            self.marketCapHeader.text = "Market Capitilization"
                            self.tendayAvgHeader.text = "10 Day Vol Average"
                        }
                     }
                    catch {
                        print(error)
                    }
                    
                }
            }
            
            task.resume()
            
            //Second API Query
            guard let secondurl = URL(string: "https://finnhub.io/api/v1/stock/metric?symbol=\(symbol)&metric=all&token=c2vjl72ad3ifkigbq5o0")
            else{
                print("Invalid URL")
                return
            }
            

            let otherTask = URLSession.shared.dataTask(with: secondurl) { (data, response, error) in
                if let error = error {
                    print(error)
                }
                else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let finances = try decoder.decode(financials.self, from: data)
                        
                        //Update labels
                        DispatchQueue.main.async {
                            self.betaLabel.text = String(finances.metric.beta ?? 0)
                            self.weekHighLabel.text = String(finances.metric.FiftyTwoWeekHigh ?? 0)
                            self.weekLowLabel.text = String(finances.metric.FiftyTwoWeekLow ?? 0)
                            self.marketCapLabel.text = String(finances.metric.marketCapitalization ?? 0)
                            self.tenDayAverageLabel.text = String(finances.metric.TenDayAvg ?? 0)
                        }
                     }
                    catch {
                        print(error)
                    }
                    
                }
            }
            otherTask.resume()
        }
        
        //Crypto API Query
        if type == "Crypto" {
                guard let url = URL(string: "https://api.nomics.com/v1/currencies/ticker?key=e9a5092e5343677facc0784bb58c64043ab47d95&ids=\(symbol)&interval=1d&convert=USD&per-page=100&page=1")
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
                            let crypt = try decoder.decode([cryptoCoin].self, from: data)
                            let elem = crypt[0]
                                                
                            //Update labels
                            DispatchQueue.main.async {
                         
                                self.priceLabel.text = String(elem.price)
                                self.openHeader.text = "Rank"
                                self.openLabel.text = elem.rank
                                self.highHeader.text = "All Time High"
                                self.highLabel.text = elem.high
                                self.lowHeader.text = "Market Cap"
                                self.lowLabel.text = elem.market_cap
                                self.betaHeader.text = "Max Supply"
                                self.betaLabel.text = elem.max_supply
                                
                                if let day = elem.daily{
                                    self.closeHeader.text = "Volume"
                                    self.closeLabel.text = day.volume
                                    self.currentHeader.text = "Daily Price Change"
                                    self.currentLabel.text = day.price_change
                                    self.weekHighHeader.text = "Daily Volume Change"
                                    self.weekHighLabel.text = day.volume_change
                                }
                            }
                         }
                        catch {
                            print(error)
                        }
                    }
                }
            task.resume()
        }
    }
    
    //favButton allows user to favourite the given item and add it to the users watchlist
    //Adds item to core data if it doesnt already exist there
    @IBAction func favButton(_ sender: Any) {
        let itemSymbol = symbol
        let itemType = type
        let itemPrice = Double(priceLabel.text ?? "13.21") ?? 13.21
        let itemName = navigationItem.title
        var exists = false
        let curWatchList = databaseController?.fetchAllGeneralItems()
        
        //Check whether item exists already
        for i in curWatchList ?? [] {
            if i.symbol == itemSymbol{
                exists = true
            }
        }
        
        //Add if not already in core data
        if exists == false{
            let _ = databaseController?.addGeneralItem(name:itemName ?? "NA" ,value: itemPrice, type: itemType, symbol: itemSymbol)
        }
        databaseController?.cleanup()
        navigationController?.popViewController(animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
    }
    
    //Embedded segue to Detailed Graph, change variables for the API Query
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedSegue"){
            let destination = segue.destination as! DetailedGraphViewController
            destination.symbol = symbol
            destination.type = type
            
        }
    }

    func onGeneralItemChange(change: DatabaseChange, generalItem: [GeneralItem]) {
        //
    }
   
}
