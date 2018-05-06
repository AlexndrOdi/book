
import UIKit

let calendar = Calendar.current
let date = Date()

let day = calendar.component(.day, from: date)
var weekday = calendar.component(.weekday, from: date) - 1
var month = calendar.component(.month, from: date) - 1
var year = calendar.component(.year, from: date)

var numbersOfEmptyBox = Int() //количество пустых боксов при старте на текущий месяц
var nextNumberOfEmptyBox = Int() //тоже самое, что и выше, но для след месяца
var previousNumberOfEmptyBox = 0 //тоже самое, что и выше, но для предыдущего месяца
var direction = 0 // =0 если мы на текущем месяца, =1 если мы на будующем месяце, =-1 если мы на прошедшем месяца
var positionIndex = 0 //будем хранить вышеперечисленные параметры пустых боксов

