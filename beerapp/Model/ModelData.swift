//
//  ModelData.swift
//  beerapp
//
//  Created by Maciek  Surowiec on 09/06/2022.
//

import Foundation
import SwiftUI
import UIKit
import Network


extension String {
    var urlEncoded: String? {
        let allowedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "~-_."))
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
    }
}


extension Data {

    var mimeType: String? {
        var values = [UInt8](repeating: 0, count: 1)
        copyBytes(to: &values, count: 1)

        switch values[0] {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x49, 0x4D:
            return "image/tiff"
        default:
            return nil
        }
    }
}


final class ModelData: ObservableObject {
    struct Content: Decodable {
        let content: String
    }
    
    struct Beer: Decodable {
        let beerId: String
        let name: String
        let abv: String
        let ibu: String
        let brewery: String
        let style: String
        let review: Int?
        let tags: [String]
        let mainPhotoUrl: String
    }
    
    struct Statistics: Decodable {
        let numberOfReviews: Int
        let numberOfPhotos: Int
        let lastThreeReviews: [Beer]
    }
    
    struct StatContent: Decodable {
        let content: Statistics
    }
    
    struct BeerContent: Decodable {
        let content: [Beer]
    }
    
    struct TagsContent: Decodable {
        let content: [String]
    }
    
    struct StringContent: Decodable {
        let content: String
    }
    
    class BeerS: Identifiable, Equatable {
        static func == (lhs: ModelData.BeerS, rhs: ModelData.BeerS) -> Bool {
            return lhs.beerId == rhs.beerId
        }
        
        var beerId: String
        var name: String
        var abv: String
        var ibu: String
        var brewery: String
        var style: String
        var review: Int
        var tags: [String]
        var mainPhotoUrl: String
        init(){
            beerId = ""
            name = "nazwa"
            abv = "N/A"
            ibu = "N/A"
            brewery = "browar"
            style = "styl"
            review = 0
            tags = []
            mainPhotoUrl = ""
        }
        
        init(beer: Beer){
            beerId = beer.beerId
            name = beer.name
            abv = beer.abv
            ibu = beer.ibu
            brewery = beer.brewery
            style = beer.style
            review = beer.review ?? 0
            tags = beer.tags
            mainPhotoUrl = beer.mainPhotoUrl
        }
        
        func Set(_ beer: Beer) {
            beerId = beer.beerId
            name = beer.name
            abv = beer.abv
            ibu = beer.ibu
            brewery = beer.brewery
            style = beer.style
            review = beer.review ?? 0
            mainPhotoUrl = beer.mainPhotoUrl
            beer.tags.forEach{ tag in
                tags.append(tag)
            }
        }
    }
    
    class Stats: ObservableObject {
        @Published var numberOfReviews: Int
        @Published var numberOfPhotos: Int
        @Published var lastThreeReviews: [BeerS]
        
        init(){
            numberOfReviews = 0
            numberOfPhotos = 0
            lastThreeReviews = []
        }
        
        func Set(_ statistics: Statistics){
            numberOfReviews = statistics.numberOfReviews
            numberOfPhotos = statistics.numberOfPhotos
            
            lastThreeReviews.removeAll()
            statistics.lastThreeReviews.forEach{ beer in
                let beerS: BeerS = BeerS()
                beerS.Set(beer)
                lastThreeReviews.append(beerS)
            }
        }
    }
    
    var userLogin: String = ""
    
    enum UnloggPages: Int {
        case login
        case register
        case about
        case start
    }
    
    
    @Published var logged: Bool = false
    
    @Published var statsDownloaded: Bool = false
    @Published var stats: Stats = Stats()
    
    @Published var listDownloaded: Bool = false
    @Published var listLoading: Bool = false
    @Published var beerList: [BeerS] = []
    @Published var unloggedPage: UnloggPages = .start
    
    @Published var tagsDownloaded = false
    @Published var tags: [String] = []
    @Published var isGettingPassword = false
    @Published var isRegistrationGoing = false
    @Published var queryPhrase: String = ""
    
    @Published var noInternet = false
    
    var start: Int = 0
    let limit: Int = 10
    let number: Int = 0
    
    
    let networkMonitor = NWPathMonitor()
    
    let boundary = "example.boundary.\(ProcessInfo.processInfo.globallyUniqueString)"
    let fieldName = "upload_image"
    var parameters: Parameters? {
        return [
            "number": number
        ]
    }
    
    init() {
        networkMonitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                if self.noInternet {
                    DispatchQueue.main.async {
                        self.noInternet = false
                    }
                }
            } else {
                self.noInternet = true
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        networkMonitor.start(queue: queue)

        if (UserDefaults.standard.string(forKey: "userlogin") != nil) {
            self.logged = true
            self.userLogin = GetUser()
            
            if self.userLogin.isEmpty {
                self.Logout()
            } else {
                self.GetStatistic()
                self.GetTags()
            }
        } else {
            self.logged  = false
        }
    }
    
    
    func Register(login: String, email: String, password: String, callback: @escaping (Int) -> Void) -> Void {
        isRegistrationGoing = true
        let url = URL(string:"https://k4qauqp2v9.execute-api.us-east-1.amazonaws.com/prod/users")
        
        guard let requestUrl = url else {fatalError()}
        
        var request = URLRequest(url: requestUrl)
        
        let data = ["login": login,"email": email,"password": password]
        
        request.httpMethod = "POST"
        request.addValue("aplication/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data)
        } catch let error{
            print(error.localizedDescription)
        }
        
        URLSession.shared.dataTask(with: request){
         (data, response,error) in
            if let error = error {
                print(error)
                return
            }
            
            self.isRegistrationGoing = false
            let response = response as! HTTPURLResponse
            callback(response.statusCode)
            
        }.resume()
    }
    
    
    func GetPassword(login: String, callback: @escaping (String) -> Void) {
        let url = URL(string: "https://k4qauqp2v9.execute-api.us-east-1.amazonaws.com/prod/users/" + login.urlEncoded! + "/login")
        
        guard let requestUrl = url else{fatalError()}
        
        var request = URLRequest(url: requestUrl)
        isGettingPassword = true
        request.httpMethod = "GET"
        request.addValue("aplication/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) {
         (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let data=data else {
                return
            }
            do {
                let response = response as! HTTPURLResponse
                self.isGettingPassword = false
                
                if response.statusCode == 200 {
                    let content = try JSONDecoder().decode(Content.self, from: data)
                    DispatchQueue.main.async {
                        callback(content.content)
                    }
                } else {
                    DispatchQueue.main.async {
                        callback("")
                    }
                }
            } catch let error {
                callback("")
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func OnLogin(_ login: String) {
        UserDefaults.standard.set(login, forKey: "userlogin")
        self.userLogin = login
        logged = true
        self.GetStatistic()
        self.GetTags()
    }
    
    func GetUser() -> String {
        return UserDefaults.standard.string(forKey: "userlogin") ?? ""
    }
    
    func Logout() {
        UserDefaults.standard.removeObject(forKey: "userlogin")
        statsDownloaded = false
        stats = Stats()
        userLogin = ""
        listDownloaded = false
        listLoading = false
        beerList = []
        unloggedPage = .start
        
        tagsDownloaded = false
        logged = false
    }
    
    
    func GetStatistic() -> Void {
        let url = URL(string: "https://k4qauqp2v9.execute-api.us-east-1.amazonaws.com/prod/users/" + userLogin.urlEncoded! + "/statistics")
        
        if stats.lastThreeReviews.count > 0 {
            stats.lastThreeReviews.removeAll()
        }
        guard let requestUrl = url else{ fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.addValue("aplication/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) {
         (data, response, error) in
            if let error = error {
                print(error)
                self.noInternet = true
                return
            }
            guard let data=data else {
                return
            }
            do {
                let content = try JSONDecoder().decode(StatContent.self, from: data)
                
                DispatchQueue.main.async {
                    self.stats.Set(content.content)
                    self.statsDownloaded = true
                }
               
            } catch let error {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func GetSafeQuery() -> String {
        let test = queryPhrase.urlEncoded ?? ""
        return test.replacingOccurrences(of: " ", with: "%20")
    }
    
    func DownloadBeerList() {
        self.listLoading = true
        self.listDownloaded = false
        start = 0
        let url = URL(string: "https://k4qauqp2v9.execute-api.us-east-1.amazonaws.com/prod/beers?limit=" + String(limit) + "&start=" + String(start) + "&queryPhrase=" + GetSafeQuery() + "&login=" + userLogin.urlEncoded!)
        
        guard let requestUrl = url else{ fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.addValue("aplication/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) {
         (data, response, error) in
            if let error = error {
                print(error)// jak nie ma internetu to zrobic jaki specjalny callback powrotny
                return
            }
            guard let data = data else {
                return
            }
            do{
                let content = try JSONDecoder().decode(BeerContent.self, from: data)
                
                DispatchQueue.main.async {
                    self.beerList.removeAll()
                    content.content.forEach{ beer in
                        let beerS = BeerS(beer: beer)
                        self.beerList.append(beerS)
                    }
                    self.listDownloaded = true
                    self.listLoading = false
                }
               
            } catch let error{
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func DownloadMoreList() {
        self.listLoading = true
        start += 10
        let url = URL(string: "https://k4qauqp2v9.execute-api.us-east-1.amazonaws.com/prod/beers?limit=" + String(limit) + "&start=" + String(start) + "&queryPhrase=" + GetSafeQuery() + "&login=" + userLogin.urlEncoded!)
        
        guard let requestUrl = url else{ fatalError() }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.addValue("aplication/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) {
         (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            guard let data = data else{
                return
            }
            do{
                let content = try JSONDecoder().decode(BeerContent.self, from: data)
                
                DispatchQueue.main.async {
                    content.content.forEach{ beer in
                        let beerS = BeerS(beer: beer)
                        self.beerList.append(beerS)
                    }
                    self.listLoading = false
                }
               
            } catch let error{
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func SendReview(review: Int, beer: BeerS, callback: @escaping ()->()) {
        if(beer.review == 0) { //POST
            let url = URL(string: "https://k4qauqp2v9.execute-api.us-east-1.amazonaws.com/prod/reviews")
            guard let requestUrl = url else {fatalError()}
            
            var request = URLRequest(url: requestUrl)
            
            let data = ["login": userLogin, "beer_id": beer.beerId, "stars": review] as [String : Any]
            
            request.httpMethod = "POST"
            request.addValue("aplication/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: data)
            } catch let error{
                print(error.localizedDescription)
            }
            
            URLSession.shared.dataTask(with: request){
             (data, response,error) in
                print(response as Any)
                if let error = error {
                    print(error)
                    return
                }

                let response = response as! HTTPURLResponse
                
                print(response.statusCode)
                self.stats.numberOfReviews += 1

                beer.review = review
                self.UpdateBeer(beer)
                callback()
            }.resume()
            
        } else { // PUT
            let url = URL(string: "https://k4qauqp2v9.execute-api.us-east-1.amazonaws.com/prod/reviews/" + userLogin.urlEncoded! + "/" + beer.beerId)
            guard let requestUrl = url else {fatalError()}
            
            var request = URLRequest(url: requestUrl)

            request.httpMethod = "PUT"
            request.addValue("aplication/json", forHTTPHeaderField: "Content-Type")

            request.httpBody = String(review).data(using: .utf8)
            
            URLSession.shared.dataTask(with: request){
             (data, response,error) in
                print(response as Any)
                if let error = error {
                    print(error)
                    return
                }

                beer.review = review
                self.UpdateBeer(beer)
                callback()
            }.resume()
        }
    }
    
    func GetTags() { //sprawdzic co sie stanie jak nie zwroci tagow
        let url = URL(string: "https://k4qauqp2v9.execute-api.us-east-1.amazonaws.com/prod/beers/tags")
        guard let requestUrl = url else{ fatalError() }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        request.addValue("aplication/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) {
        (data, response, error) in
          if let error = error {
              print(error)
              return
          }
          guard let data = data else{
              return
          }
          do{
              let content = try JSONDecoder().decode(TagsContent.self, from: data)
            
              DispatchQueue.main.async {
                  content.content.forEach{ tag in
                      self.tags.append(tag)
                  }
                  self.tagsDownloaded = true
              }
          } catch let error{
              print(error.localizedDescription)
          }
        }.resume()
    }
    
    func UpdateBeer(_ updatedBeer: BeerS) {
        beerList.forEach { beer in
            if(beer == updatedBeer) {
                beer.review = updatedBeer.review
            }
        }
        
        self.stats.lastThreeReviews.forEach { beer in
            if (beer == updatedBeer) {
                stats.lastThreeReviews.remove(at: stats.lastThreeReviews.firstIndex(of: beer) ?? 0)
            }
        }
        
        if(stats.lastThreeReviews.count >= 3) {
            stats.lastThreeReviews.removeLast()
        }
        
        stats.lastThreeReviews.insert(updatedBeer, at: 0)
    }
    
    func SendTags(tags: [String], beer: BeerS, callback: @escaping ()->()) { //calback zeby wyswietlic ze wyslalo tagi
        let url = URL(string: "https://k4qauqp2v9.execute-api.us-east-1.amazonaws.com/prod/reviews/" + userLogin.urlEncoded! + "/" + beer.beerId + "/tags")
        guard let requestUrl = url else {fatalError()}
        
        var request = URLRequest(url: requestUrl)
        
        request.httpMethod = "PUT"
        request.addValue("aplication/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: tags)
        } catch let error{
            print(error.localizedDescription)
        }
        
        URLSession.shared.dataTask(with: request){
         (data, response,error) in
            print(response as Any)
            if let error = error {
                print(error)
                return
            }
            
            beer.tags = tags
            callback()
        }.resume()
    }
    
    func IncrementPhotoNumber() {
        let url = URL(string: "https://k4qauqp2v9.execute-api.us-east-1.amazonaws.com/prod/users/" + userLogin.urlEncoded! + "/photos")
        guard let requestUrl = url else {fatalError()}
        
        var request = URLRequest(url: requestUrl)
        
        request.httpMethod = "POST"
        request.addValue("aplication/json", forHTTPHeaderField: "Content-Type")
       
        URLSession.shared.dataTask(with: request){
         (data, response,error) in
            print(response as Any)
            if let error = error {
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                self.stats.numberOfPhotos += 1
            }
        }.resume()
    }
    
    
    func StartSendSendingImage(beerId: String, image: UIImage, callback: @escaping ()->()) {
        let url = URL(string: "https://k4qauqp2v9.execute-api.us-east-1.amazonaws.com/prod/beers/" + beerId + "/image")
        guard let requestUrl = url else {fatalError()}
        
        var request = URLRequest(url: requestUrl)
        
        request.httpMethod = "GET"
        request.addValue("aplication/json", forHTTPHeaderField: "Content-Type")
       
        URLSession.shared.dataTask(with: request){
         (data, response,error) in
            print(response as Any)
            if let error = error {
                print(error)
                return
            }
            
            guard let data=data else{
                return
            }
            
            do{
                let content = try JSONDecoder().decode(StringContent.self, from: data)
                
                self.SendImage(url: content.content, image: image, callback: callback)
                
            } catch let error{
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    typealias Parameters = [String: Any]

    func SendImage(url: String, image: UIImage, callback: @escaping ()->()) {
        let url = URL(string: url)
        guard let requestUrl = url else {fatalError()}
        
        var request = URLRequest(url: requestUrl)
        var data = Data()
        
        let imageData = image.jpegData(compressionQuality: 1)!
        
        data.append(imageData)
        request.httpBody = imageData
        request.httpMethod = "PUT"
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.addValue("Accept", forHTTPHeaderField: "application/json")
        
        URLSession.shared.dataTask(with: request){
         (data, response,error) in
            if let error = error {
                print(error)
                return
            }
            guard let data = data else{
                return
            }
            
            callback()
            
            self.IncrementPhotoNumber()
            print(data, String(data: data,encoding: .utf8) ?? "*unknown encoding*")
   
        }.resume()
    }
    
    private func createHttpBody(binaryData: Data, mimeType: String) -> Data {
        var postContent = "--\(boundary)\r\n"
        let fileName = "\(UUID().uuidString).jpeg"
        postContent += "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n"
        postContent += "Content-Type: \(mimeType)\r\n\r\n"

        var data = Data()
        guard let postData = postContent.data(using: .utf8) else { return data }
        data.append(postData)
        data.append(binaryData)

        
        if let parameters = parameters {
            var content = ""
            parameters.forEach {
                content += "\r\n--\(boundary)\r\n"
                content += "Content-Disposition: form-data; name=\"\($0.key)\"\r\n\r\n"
                content += "\($0.value)"
            }
            if let postData = content.data(using: .utf8) { data.append(postData) }
        }

        guard let endData = "\r\n--\(boundary)--\r\n".data(using: .utf8) else { return data }
        data.append(endData)
        return data
    }
    
}
