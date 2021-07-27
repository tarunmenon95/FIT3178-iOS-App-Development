//  NewsTableViewController.swift
//  bazaar


import UIKit

//Codable struct to parse newsData
struct newsData: Codable{
    var totalResults: Int
    var articles: [articleData]
}

//Codable struct to parse articleData
struct articleData: Codable{
    var title: String
    var description: String?
    var url: String
    var urlToImage: String?
}

//The NewsTableViewController handles all relevant actions/information for retrieving and viewing different financial articles
//retrieved from an API request

class NewsTableViewController: UITableViewController {
    
    //Class Variables
    let SECTION_NEWS = 0
    let CELL_NEWS = "newsCell"
    var news : [NewsArticle] = []

    //When the view loads, complete API request and parse JSON response, store results into news array which contains all relevant articles
    //Use array to populate table
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //API Request / JSON Parse
        guard let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=c794584e2ed1460297400cb7fc389935")
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
                    let articleInfo = try decoder.decode(newsData.self, from: data)
                  
                    //Create news item for each article, store into news array
                    for elem in articleInfo.articles{
                        let title = elem.title
                        let descript = elem.description
                        let imageUrl = elem.urlToImage
                        let url = elem.url
                        let newNews = NewsArticle(newTitle: title, newDescript: descript, newImageUrl: imageUrl, newUrl: url)
                        self.news.append(newNews)
                        
                    }
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_NEWS:
            return news.count
        default:
            return 0
        }
    }

    //Create newsCell using customCell "newsCell" which uses title, description and an image
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsCell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! newsTableViewCell
        _ = news[indexPath.row]
        let newsItem = news[indexPath.row]
        
        newsCell.titleLabel.text = newsItem.title
        newsCell.descriptLabel.text = newsItem.descript
        newsCell.newsImageView.load(urlString: newsItem.imageUrl ?? "")
        newsCell.newsImageView.layer.cornerRadius = 5.0
        return newsCell
        
        
    }
    
    //Open link for selected article
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: String(news[indexPath.row].url)){
            UIApplication.shared.open(url)
        }
    }

}
