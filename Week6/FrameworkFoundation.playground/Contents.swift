import Foundation

var str = "Hello, playground"

//data concat
let square = sqrt(4.0);
let power = pow(2.0, 2.0)
let maximum = max(square, power)
print("The max value is \(maximum)")

var randomNumber = arc4random_uniform(10) + 1
print("The number is: \(randomNumber)")

//data concat to string
var myAge = 50;
var myText = String(format: "my age is %d", arguments:[myAge])

//compare string
var citrus = "orange"
var pome = "apple"
var result = citrus.compare(pome)
switch result {
case.orderedSame:
    print("Citrus and Pome are equal")
case.orderedDescending:
    print("Citrus follows Pome")
case.orderedAscending:
    print("Citrus precededs Pome")
}

//case insensitive compare
var citrus1 = "orange"
var citrus2 = "ORANGE"
var result2 = citrus.compare(citrus2,options: .caseInsensitive)

switch result2{
case.orderedSame:
    print("Citrus1 and Citrus2 are equal")
case.orderedDescending:
    print("Citrus1 follows Citrus2")
case.orderedAscending:
    print("Citrus1 precededs Citrus2")
}

//identifying part of string
var gimmPhone = "208-000-0000"
var areaCode = "208"

var start = gimmPhone.startIndex
var end = gimmPhone.index(of: "-")

if let endIndex = end{
    let result3 = gimmPhone.compare(areaCode, options: .caseInsensitive, range: start..<endIndex)
    if result3 == .orderedSame{
        print("gimmPhone and areaCode are equal")
    } else {
        print ("gimmPhone and areaCode are different")
    }
}

//searching/search and replace
var gimmString = "GIMM is Swifty"

var search = "GIMM"

var range = gimmString.range(of: search, options: .caseInsensitive)
if let rangeToReplace = range{
    gimmString.replaceSubrange(rangeToReplace, with: "CID") } else {
    print ("not found")
}


//dates

var currentDate = Date();
var nextDay = Date(timeIntervalSinceNow: 24 * 60 * 60)
var tenDayForecast = Date(timeInterval: 10 * 24 * 3600, since: nextDay)

var days = 7
var today = Date()

var event = Date(timeIntervalSinceNow: Double(days) * 24 * 3600)
if today.compare(event) == .orderedAscending{
    let interval = event.timeIntervalSince(today)
    print("We have to wait until \(interval) seconds")
}




var today2 = Date()
let calendar = Calendar.current
var componets = calendar.dateComponents([.year, .month, .day], from:today2)


let calendar2 = Calendar.current
var componets2 = DateComponents()
componets2.year = 1968
componets2.month = 8
componets2.day = 4

var birthday = calendar.date(from: componets2)
var today3 = Date()
if let oldDate = birthday{
    var components3 = calendar.dateComponents([.day], from: oldDate, to: today3)
}




//Servers and URLs

import UIKit
let config = URLSessionConfiguration.default
let session = URLSession(configuration:config)

let urlString = "https://imgs.xkcd.com/comics/api.png"
let url = URL(string: urlString)!

let request = URLRequest(url:url)


let task = session.dataTask (with: request) { (data, response, error)
    in
    guard let imageData = data
        else {
            return
    }
    
    _ = UIImage(data: imageData)
}

task.resume()
