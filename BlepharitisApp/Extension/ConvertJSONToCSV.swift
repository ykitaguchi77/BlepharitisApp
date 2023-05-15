//
//  convertJSONToCSV.swift
//  Grav_app_simple
//
//  Created by Yoshiyuki Kitaguchi on 2023/02/24.
//

import SwiftUI

func convertJSONToCSV() {
        // ファイルマネージャーを作成
        let fm = FileManager.default
        
        // ドキュメントディレクトリへのパスを取得
        guard let docsPath = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not access documents directory.")
            return
        }
        
        // ドキュメントディレクトリ内のファイルを取得
        let fileURLs = try! fm.contentsOfDirectory(at: docsPath, includingPropertiesForKeys: nil)

        // ファイル名が".json"で終わるファイルのbasenameを取得
        let jsonFileBasenames = fileURLs.filter { $0.pathExtension == "json" }.map { $0.deletingPathExtension().lastPathComponent + ".json" }

        
//        // 変換するJSONファイル名の配列
//        let jsonFileNames = ["file1.json", "file2.json", "file3.json"]
//
        // CSVファイルに書き込む文字列
        var csvString = ""
        
        // 各JSONファイルを読み込んでCSV文字列に変換する
        for jsonFileName in jsonFileBasenames {
            // JSONファイルのパスを取得
            let jsonFilePath = docsPath.appendingPathComponent(jsonFileName)
            
            // JSONデータを読み込む
            guard let jsonData = try? Data(contentsOf: jsonFilePath) else {
                print("Error: Could not read JSON file at \(jsonFilePath).")
                continue
            }
            
            // JSONデータをデコードする
            guard let jsonArray = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                print("Error: Could not decode JSON data from \(jsonFileName).")
                continue
            }
            
            // dictの順番を手動で並べ替える
            var newArray: [String] = []
            let key = ["pq1", "pq2", "pq3", "pq4", "pq5", "pq6", "pq7"]
            let col_index = ["Date", "HashID", "ID", "Image_num", "Hospital", "Disease", "Free"]
            

            
            for k in key {
                newArray.append(jsonArray[k] as! String)
            }
            
            print(newArray)
                        
            // CSV文字列に変換する
            let csv = newArray.joined(separator: ",")
            
            print(csvString)
            
            // CSV文字列を追加する
            csvString += csv + "\n"
        }
    
        //csvにヘッダーを追加する
        csvString = "Date,HashID,ID,Image_num,Hospital,Disease,Free\n" + csvString
        
        // CSVファイルのパスを作成
        let csvFilePath = docsPath.appendingPathComponent("output.csv")
        
        // CSVファイルに書き込む
        do {
            try csvString.write(to: csvFilePath, atomically: true, encoding: .utf8)
            print("CSV file written to \(csvFilePath)")
        } catch {
            print("Error: Could not write CSV file to \(csvFilePath).")
        }
    }
