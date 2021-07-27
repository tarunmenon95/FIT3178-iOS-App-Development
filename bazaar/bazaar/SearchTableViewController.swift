//  SearchTableViewController.swift
//  bazaar


import UIKit

//Codable struct to parse stock data from API

struct stockdata : Codable{
    var symbol:String
    var description:String
}

//The SearchTableViewController handles all relevant actions/data for searching stocks from a list returned from an API Query

class SearchTableViewController: UITableViewController, UISearchResultsUpdating{

    //Class variables
    let SECTION_SEARCH = 0
    let CELL_SEARCH = "searchCell"
    var allResults : [Stock] = []
    var filteredResults : [Stock] = []

    //Funcion updates filteredResults based on the search parameter text input by the user
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else{
            return
        }
        if searchText.count > 0 {
            filteredResults = allResults.filter({ (stock: Stock) -> Bool in
                return (stock.descript.lowercased().contains(searchText))
                })
        }
        else {
        filteredResults = allResults
        }
        tableView.reloadData()
    }
    
    //On view load, create searchController and initialise filtered results
    //Next complete API Query and parse JSON, store results into allResults
    override func viewDidLoad() {
        super.viewDidLoad()

        filteredResults = allResults
        
        //SearchController Creation
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Looking for something?"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.searchTextField.textColor = .white
        navigationItem.hidesSearchBarWhenScrolling = false
        
        //API Query / JSON Parse
        guard let url = URL(string: "https://finnhub.io/api/v1/stock/symbol?exchange=US&token=c2vjl72ad3ifkigbq5o0")
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
                    let stockInfo = try decoder.decode([stockdata].self, from: data)
                    
                    //Create stock items and store into all results
                    for elem in stockInfo{
                        let sym = elem.symbol
                        let desc = elem.description
                        let newStock = Stock(newName: sym, newDescript: desc)
                        
                        self.allResults.append(newStock)
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
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
    }

    //When seguing to the DetailedInformationScreen, set variables for API query to currently selected item
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "searchSegue"{
            let destination = segue.destination as! DetailedInformationViewController
            
            if let cell = sender as? UITableViewCell,
               let indexPath = tableView.indexPath(for: cell){
                destination.navigationItem.title = filteredResults[indexPath.row].descript
                destination.symbol = filteredResults[indexPath.row].name
                destination.type = "Stock"
            }
        }
    }
  
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_SEARCH:
            return filteredResults.count
        default:
            return 0
        }
    }

    //Cell created using filteredResults item
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let searchCell = tableView.dequeueReusableCell(withIdentifier: CELL_SEARCH, for: indexPath)
            let search = filteredResults[indexPath.row]
            searchCell.textLabel?.text = search.name
            searchCell.detailTextLabel?.text =  String(search.descript)
            return searchCell
      
    }
}
