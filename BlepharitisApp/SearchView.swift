
//
//  Informations.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/04/18.
//
//https://capibara1969.com/3447/
//http://harumi.sakura.ne.jp/wordpress/2019/07/30/document%E3%83%95%E3%82%A9%E3%83%AB%E3%83%80%E3%81%AE%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E5%90%8D%E4%B8%80%E8%A6%A7%E3%82%92%E5%8F%96%E5%BE%97%E3%81%99%E3%82%8B%E9%9A%9B%E3%81%AE%E7%BD%A0/

import SwiftUI
import Foundation

//変数を定義
struct Search: View {
    @ObservedObject var user: User
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showingAlert = false
    @State private var orderOfDate = true //trueなら日付順、falseならID順
    @State private var items =  SearchModel.GetInstance().getJson()
    @State private var tapidx: Int = 0

    
    var body: some View {
        
        GeometryReader { bodyView in
            VStack{
    
                HStack(spacing:-10){
                    Button(action: {
                        items.sort(by: {a, b -> Bool in return a.pq3 < b.pq3}) //日付を昇順に並べ替え
                        items.sort(by: {a, b -> Bool in return a.pq1 < b.pq1}) //IDを昇順に並べ替え
                    }) {
                        HStack{
                            Image(systemName: "arrow.up.arrow.down")
                            Text("日付順")
                        }
                            .foregroundColor(Color.white)
                            .font(Font.largeTitle)
                    }
                        .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                        .background(Color.black)
                        .padding()
                    
                    Button(action: {
                        items.sort(by: {a, b -> Bool in return a.pq1 < b.pq1}) //IDを昇順に並べ替え
                        items.sort(by: {a, b -> Bool in return a.pq3 < b.pq3}) //日付を昇順に並べ替え
                    }) {
                        HStack{
                            Image(systemName: "arrow.up.arrow.down")
                            Text("ID順")
                        }
                            .foregroundColor(Color.white)
                            .font(Font.largeTitle)
                    }
                        .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                        .background(Color.black)
                        .padding()
                }
                    
                List{
                    ForEach(0 ..< items.count, id: \.self){idx in
                        HStack{
                            VStack{
                                Text("date: \(items[idx].pq1)").frame(maxWidth: .infinity,alignment: .leading)
                                Text("id: \(items[idx].pq3), num: \(items[idx].pq4)").frame(maxWidth: .infinity,alignment: .leading)
                                Text("disease: \(items[idx].pq6)").frame(maxWidth: .infinity,alignment: .leading)
                            }
                                
                            Spacer()
                            Text("Load")  //Loadボタン
                                .onTapGesture {
                                    self.showingAlert.toggle()
                                    tapidx = idx //タップした番号を記録
                                }
                                .frame(minWidth:0, maxWidth:bodyView.size.width/4, minHeight: 40)
                                .foregroundColor(Color.white)
                                .background(Color.black)
                                .alert(isPresented:$showingAlert){
                                    Alert(title: Text("データをロードしますか？"), primaryButton:.default(Text("はい"),action:{
                                        //形式を直してobservable objectに格納する
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyyMMdd"
                                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
                                        let date = dateFormatter.date(from: items[tapidx].pq1)
                                        user.date = date!
                                        user.hashid = items[tapidx].pq2
                                        user.id = items[tapidx].pq3
                                        user.imageNum = Int(items[tapidx].pq4)!
                                        user.selected_hospital = user.hospitals.firstIndex(where: { $0 == items[tapidx].pq5})!
                                        user.selected_disease = user.disease.firstIndex(where: { $0 == items[tapidx].pq6})!
                                        user.free_disease = items[tapidx].pq7
 
                                        LoadImages(name: imageName()) //imageNameはJOIR準拠の命名。画像をresultHolderに格納。
                                        self.user.isSendData = false //撮影済みを解除
                                        self.presentationMode.wrappedValue.dismiss()
                                    }),
                                          secondaryButton:.destructive(Text("いいえ"), action:{}))
                                    }
                        }
                    }
                    Button(action: {
                                convertJSONToCSV()
                            }) {
                                Text("Convert JSON to CSV")
                            }
                    
                }
            }
        }
    }
    
    //hashIDと同じ名前のImageをロードして、ResultHolderに格納
    public func LoadImages(name: String){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var imagePath = documentsURL.appendingPathComponent(name+".png")
        var moviePath = documentsURL.appendingPathComponent(name+".mp4")
        
        //同名の画像があるかどうか
        let imgExists = FileManager().fileExists(atPath: imagePath.path)
        if imgExists == true{
            //.pathプロパティを引数に画像読み込み
            let image = UIImage(contentsOfFile: imagePath.path)

            let cgImage = image?.cgImage //CGImageに変換
            let cropped = cgImage!.cropToSquare()

            let rawImage = UIImage(cgImage: cropped)
            ResultHolder.GetInstance().SetImage(index: 0, cgImage: rawImage.cgImage!)
            ResultHolder.GetInstance().SetMovieUrls(Url: "")
            print("image loaded")
        }
        
        let movieExists = FileManager().fileExists(atPath: moviePath.path)
        if movieExists == true{
            // get a URL for the selected local file with nil safety

            let tempDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())
            let croppedMovieFileURL: URL = tempDirectory.appendingPathComponent("mytemp2.mov")
            
            MovieCropper.exportSquareMovie(sourceURL: moviePath, destinationURL: croppedMovieFileURL, fileType: .mov, completion: {
                // 正方形にクロッピングされた動画をフォトライブラリに保存
            })
            //ResultHolderに保存
            ResultHolder.GetInstance().SetMovieUrls(Url: croppedMovieFileURL.absoluteString)
            print("movie loaded")
        }
    }
    
    //画像命名（SendDataViewにも同じものがある）
    public func imageName() -> String{
        let id = self.user.hashid
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let examDate = dateFormatter.string(from: self.user.date)
        let imageNum = String(format: "%03d", self.user.imageNum)
        let imageName = id + "_" + examDate + "_" + imageNum
        //print(imageName)
        return imageName
    }
}


//複数のJsonファイルから各項目のリストを作成
class SearchModel: ObservableObject, Identifiable {

    init() {}

    static var instance: SearchModel?
    public static func GetInstance() -> SearchModel{
        if (instance == nil) {
            instance = SearchModel()
        }

        return instance!
    }

    public func getJson() -> [QuestionAnswerData] {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: documentsURL.path) else {
            print("no files")
            return [QuestionAnswerData]() //ファイルが無い場合は空の構造体を返す
        }

        var JsonList = [QuestionAnswerData]()

        for fileName in fileNames {
            let fileURL = documentsURL.appendingPathComponent(fileName)
            let isJSONFile = fileURL.pathExtension == "json"
            
            if isJSONFile, let contents = try? String(contentsOf: fileURL, encoding: .utf8) {
                guard let jsonData = try? JSONDecoder().decode(QuestionAnswerData.self, from: contents.data(using: .utf8)!) else {
                    fatalError("Failed to decode from JSON.")
                }
                JsonList.append(jsonData)
            }
        }

        JsonList.sort(by: {a, b -> Bool in return a.pq3 < b.pq3}) //日付を昇順に並べ替え
        JsonList.sort(by: {a, b -> Bool in return a.pq1 < b.pq1}) //IDを昇順に並べ替え
    return (JsonList)
    }
}

