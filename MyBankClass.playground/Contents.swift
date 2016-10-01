//: Playground - noun: a place where people can play

// 銀行の取引明細からデータをグラフ化するツールを作成
// MyBankクラスによって取引内容を記録する

import UIKit
import Foundation

/*
// 取引日を取得したい

let nowDate = Date()
print(nowDate)

let formatter = DateFormatter()
formatter.dateFormat = "yyyy/MM/dd"

let formattedDate = formatter.string(from: nowDate as Date)
print(formattedDate)

let date = formatter.date(from: "2016/08/26")
print(date)

//let dateFormatter = DateFormatter()
//dateFormatter.dateStyle = .mediumStyle
//dateFormatter.timeStyle = .noStyle
//
//let date = Date(timeIntervalSinceReferenceDate: 118800)
//// Japanese Locale (ja_JP)
formatter.locale = Locale(identifier: "ja_JP")
print(formatter.string(from: date!)) // 2001/01/02
*/

//var ary = [10, 20, 30 , 40, 50]
//for i in ary.reversed() {
//    print(i)
//}



// MARK: - Bankクラス

class Bank {
    // 銀行名
    var bankName:String
    // 初期残高を記録
    let firstBalance: Int
    // 残高
    var balance: Int
    // 入出金データ
    var bankStatement:[(date: Date, banking: Banking, amount: Int)] = []
    
    
    init(name: String, firstBalance: Int) {
        self.bankName = name
        self.firstBalance = firstBalance
        self.balance = firstBalance
    }
    
    // 取引を追加し、入出金データに格納
    func addBanking(date: Date!, banking: Banking, amount: Int) {
        let data:(Date, Banking, Int) = (date, banking, amount)
        self.bankStatement.append(data)
        
         // 日付順にデータを並び替えて格納する -> insertがうまく機能せず…
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        // 配列が空でなければ
        
        if bankStatement.isEmpty == false {
            let count = bankStatement.count
            var i = 1
            
            while (calendar.compare(date, to: bankStatement[count - i].date, toUnitGranularity: .day) == .orderedAscending) || count < i {
                
                i += 1
            }
            
            self.bankStatement.insert((date, banking, amount), at: count - i + 1)
        } else {
            self.bankStatement.append(data)
        }
        
        
        // 残高を求める
        if banking == Banking.Payment {
            self.balance += amount
        } else {
            self.balance -= amount
        }
    }
    
    // 過去全ての取引を計算する
    func getTotalBalance() -> Int {
        var totalBalance: Int = self.firstBalance
        
        for i in bankStatement {
            if i.banking == Banking.Payment {
                totalBalance += i.amount
            } else {
                totalBalance -= i.amount
            }
        }
        return totalBalance
    }
    
    // 指定した期間の取引を計算する
    func getTotalBalance(fromDate: Date!, toDate: Date!) -> Int {
        var totalBalance: Int = 0
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        
        // fromData < toDateでなかった場合は強制終了
        if calendar.compare(fromDate, to: toDate, toUnitGranularity: .day) != .orderedAscending {
            print("期間設定に誤りがあります。")
            exit(0)
        }
        
        for i in bankStatement {
            
            let result1 = calendar.compare(i.date, to: fromDate, toUnitGranularity: .day)
            // i.date > fromDateであれば
            if result1 == .orderedDescending {
                
                let result2 = calendar.compare(i.date, to: toDate, toUnitGranularity: .day)
                // i.data < toDateであれば
                if result2 == .orderedAscending {
                    if i.banking == Banking.Payment {
                        totalBalance += i.amount
                    } else {
                        totalBalance -= i.amount
                    }
                }
            }
        }
        return totalBalance
    }
    
    
    
    // 取引明細を一覧で表示
    func printBankStatement() {
        for i in bankStatement {
            print(i)
        }
    }
    
    // 指定した日にちの取引のみを表示
    func printBankStatement(fromDate: Date!) {
        for i in bankStatement {
            if i.date == fromDate {
                print(i)
            }
        }
    }
    
    // 指定した期間の取引のみを表示
    func printBankStatement(fromDate: Date!, toDate: Date!) {
        
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
        
        // fromData < toDateでなかった場合は強制終了
        if calendar.compare(fromDate, to: toDate, toUnitGranularity: .day) != .orderedAscending {
            print("期間設定に誤りがあります。")
            return;
        }
        
        for i in bankStatement {
            
            let result1 = calendar.compare(i.date, to: fromDate, toUnitGranularity: .day)
            // i.date > fromDateであれば
            if result1 == .orderedDescending {
                
                let result2 = calendar.compare(i.date, to: toDate, toUnitGranularity: .day)
                // i.data < toDateであれば
                if result2 == .orderedAscending {
                    print(i)
                }
            }
        }
    }

}

// 銀行取引の種類
enum Banking {
    // 入金
    case Payment
    // 出金
    case Withdrawal
}


// MARK: - Bankクラスをまとめて扱うクラス

class BankManager {
    var bank: [Bank]
    var totalBalance: Int = 0
    
    init(bank: [Bank]) {
        self.bank = bank
        self.totalBalance = getSumTotalBalance()
    }
    
    // 銀行を追加
    func addBank(bank: Bank) {
        self.bank.append(bank)
        self.totalBalance = self.getSumTotalBalance()
    }
    
    // 合計残高を算出
    func getSumTotalBalance() -> Int {
        var total = 0
        
        for i in self.bank {
            total += i.getTotalBalance()
        }
        return total
    }
    
    // 指定期間の収支バランスを求める
    func getSumTotalBalance(fromDate: Date!, toDate: Date!) -> Int {
        var total = 0
        
        for i in self.bank {
            total += i.getTotalBalance(fromDate: fromDate, toDate: toDate)
        }
        return total
    }
    
    
}


// 銀行を追加
let myBank1 = Bank(name: "みずほ銀行", firstBalance: 100000)
let myBank2 = Bank(name: "三菱東京UFJ銀行", firstBalance: 200000)
let myBank3 = Bank(name: "多摩信用金庫", firstBalance: 1200000)

// StringをDateに変換するためのFormatterを用意
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy/MM/dd"

// 取引を追加
myBank1.addBanking(date: dateFormatter.date(from: "2016/08/04"), banking: .Withdrawal, amount: 24000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/08/10"), banking: .Payment, amount: 30000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/08/20"), banking: .Withdrawal, amount: 15000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/08/25"), banking: .Withdrawal, amount: 10000)

myBank1.addBanking(date: dateFormatter.date(from: "2016/09/04"), banking: .Withdrawal, amount: 27000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/09/10"), banking: .Payment, amount: 30000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/09/23"), banking: .Withdrawal, amount: 5000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/09/30"), banking: .Withdrawal, amount: 10000)

myBank2.addBanking(date: dateFormatter.date(from: "2016/08/04"), banking: .Payment, amount: 80000)  // 外部からの収入
myBank2.addBanking(date: dateFormatter.date(from: "2016/08/10"), banking: .Withdrawal, amount: 50000)
myBank2.addBanking(date: dateFormatter.date(from: "2016/08/13"), banking: .Withdrawal, amount: 20000)
myBank2.addBanking(date: dateFormatter.date(from: "2016/08/17"), banking: .Withdrawal, amount: 10000)
myBank2.addBanking(date: dateFormatter.date(from: "2016/08/22"), banking: .Withdrawal, amount: 20000)

myBank2.addBanking(date: dateFormatter.date(from: "2016/09/04"), banking: .Payment, amount: 80000)  // 外部からの収入
myBank2.addBanking(date: dateFormatter.date(from: "2016/09/11"), banking: .Withdrawal, amount: 30000)
myBank2.addBanking(date: dateFormatter.date(from: "2016/09/21"), banking: .Withdrawal, amount: 20000)

//myBank3.addBanking(date: dateFormatter.date(from: "2016/08/05"), banking: .Withdrawal, amount: 10000)

//myBank3.addBanking(date: dateFormatter.date(from: "2016/09/09"), banking: .Withdrawal, amount: 13000)
//myBank3.addBanking(date: dateFormatter.date(from: "2016/09/21"), banking: .Withdrawal, amount: 29000)



// 残高と取引明細を表示
print("残高：\(myBank1.balance)")
myBank1.printBankStatement()
print()
myBank1.printBankStatement(fromDate: dateFormatter.date(from: "2016/09/02"))
print()
myBank1.printBankStatement(fromDate: dateFormatter.date(from: "2016/09/02"), toDate: dateFormatter.date(from: "2016/09/13"))


print()
print("残高：\(myBank1.balance)")
print("残高：\(myBank2.balance)")
print("残高：\(myBank3.balance)")



// 全ての銀行を管理
let superBank = BankManager(bank: [myBank1, myBank2, myBank3])
print("合計残高：\(superBank.totalBalance)")

print()
print(myBank1.getTotalBalance(fromDate: dateFormatter.date(from: "2016/08/01"), toDate: dateFormatter.date(from: "2016/09/01")))
print(myBank2.getTotalBalance(fromDate: dateFormatter.date(from: "2016/08/01"), toDate: dateFormatter.date(from: "2016/09/01")))
print(myBank3.getTotalBalance(fromDate: dateFormatter.date(from: "2016/08/01"), toDate: dateFormatter.date(from: "2016/09/01")))

print()
print("8月の収支：\(superBank.getSumTotalBalance(fromDate: dateFormatter.date(from: "2016/08/01"), toDate: dateFormatter.date(from: "2016/09/01")))")
print("9月の収支：\(superBank.getSumTotalBalance(fromDate: dateFormatter.date(from: "2016/09/01"), toDate: dateFormatter.date(from: "2016/10/01")))")


// 変更





