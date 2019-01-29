import UIKit


//Varibles and strict Data Typing
//dont have to declare type
//No semicolons
var str = "Hello, playground"

print(str)

var str2:String

//let is a constant, use often to save memory
let str3:String = "Professor"

let numberOfProfessors:Int = 5

let numberOfStudents:Int = 200

str2=str3


//if confused with data type being used
type(of:str2)

//no implicit conversion of types
let a=5
let b = 3

let sumAnswer = a+b

//if you change the preceding line this way you get an error
//let sumAnswer:String

//if you need to convert
let sumAnswer2 = String(sumAnswer)

//but not all conversion are equal
let myFloatingValue:Float = 10.5
let myFloatingConversion = Int(myFloatingValue)
print (myFloatingConversion)

//Default Values--in SWIFT default values are not assigned
var gimmCourses:String
var gimmCourseNumbers:Int

//bellow will throw error
//print(gimmCourses)

//optionals-- allow us to define type safe values where there may be no value at all
var myNumber:Int?

//myNumber = hwllo this wont work because typing still applies

myNumber = 5
//myNumber = nil

//myNumber = myNumber + 2 this will generate a error without value

//We need to know if an optional value is either nil or not nil
//this process is call unwrapping an optional

//check for nil
//if myNumber != nil{
    //var unwrappedNumber = myNumber!
  //  unwrappedNumber = unwrappedNumber + 10
//}

if let unwrappedNumber = myNumber{
    print(unwrappedNumber)
}


//creating Collections Array(ordered list)
//Dictionary(collection of key/value pairs) Set (unorded collection)

//Arrays in SWIFT 0 based and type safe declared by var or let

var gimmClasses = ["GIMM100", "GIMM110", "GIMM200"]

let initialClass = gimmClasses[0]

gimmClasses.append("GIMM250")

gimmClasses.removeLast()

//if we dont have initial value
var gimmCapstoneProjects:[String] = []
//gimmCapstoneProjects.append(<#T##newElement: String##String#>)
