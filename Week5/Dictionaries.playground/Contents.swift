import UIKit

var str = "Hello, playground"

var namesAndGrades = ["Tim": 4.0, "Anna": 3.0, "Creg": 2.0]

print(namesAndGrades)

//empty dictionary
var someDictionary: [String:Int] = [:]

//you can save on memory and processing power if you knoe size of your dictionary
someDictionary.reserveCapacity(10)

//now let's look at accessing values

//using subscriptions
//unlike arrays, dictionaries support subscribing to acess values
//unlike arrays, you dont acess a value by its index but rather by its key

print(namesAndGrades["Tim"])

var studentStat = ["name": "Anthony", "major": "GIMM", "city": "Boise"]

studentStat.updateValue("ID", forKey: "state")

studentStat.updateValue("Tony", forKey: "name")

studentStat.removeValue(forKey: "state")

for(name, major) in studentStat{
    print("\(name) - \(major)")
}


for name in studentStat.keys{
    print("\name, ", terminator: "")
}

//create whole dictionaries by creating named pairs. tuples

let cohortTotalStudents = [("1st Cohort", 35), ("2ndCohort", 71), ("3rd Cohort", 81)]

let gimmClassNumbers = Dictionary(uniqueKeysWithValues: cohortTotalStudents)

let duplicates = [("FirstCohort", "Beth A"), ("SecondCohort", "Tom B"), ("FirstCohort", "Grace E")]


let cohortsSorted = Dictionary(duplicates.map {($0.0, [$0.1])}, uniquingKeysWith: {(current, new)in return current + new})

print(cohortsSorted)
