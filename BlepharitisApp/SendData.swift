//
//  SendData.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/04/18.
//


//★動画のプレビュー表示を実現。課題は以下の通り。
//動画か静止画どちらかのみ表示するようにする →動画アドレスがないときにゼロでエラーが出ることへの対策
//
//動画のfilemanagerへの保存→NSError[0]が出る


import SwiftUI
import CoreData
import CryptoKit
import AVKit

struct SendData: View {
    @ObservedObject var user: User
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showingAlert: Bool = false
    
    //private let player = AVPlayer(url: URL(string:ResultHolder.GetInstance().GetMovieUrls())!)
    
    var body: some View {
        
        VStack{
                GeometryReader { bodyView in
                    VStack{
                        ScrollView{
                            Text("内容を確認してください").padding().foregroundColor(Color.black)
                                .font(Font.title)
                            
                            
                            ZStack{
                                if ResultHolder.GetInstance().GetMovieUrls() == "" {
                                    GetImageStack(images: ResultHolder.GetInstance().GetUIImages(), shorterSide: GetShorterSide(screenSize: bodyView.size))
                                }else{
                                    let player = AVPlayer(url: URL(string:ResultHolder.GetInstance().GetMovieUrls())!)
                                    VideoPlayer(player: player).frame(width: bodyView.size.width, height:bodyView.size.width)
                                }
                                
                            }
                            
                            HStack{
                                Text("撮影日時:")
                                Text(self.user.date, style: .date)
                            }
                            Text("ID: \(self.user.id)")
                            Text("施設: \(self.user.hospitals[user.selected_hospital])")
                            Text("診断名: \(user.disease[user.selected_disease])")
                            Text("自由記載: \(self.user.free_disease)")
                        }
                    }
                }

                Spacer()

            
            //送信するとボタンの色が変わる演出
            if self.user.isSendData {
                Button(action: {}) {
                    HStack{
                        Image(systemName: "square.and.arrow.up")
                        Text("送信済み")
                    }
                        .foregroundColor(Color.white)
                        .font(Font.largeTitle)
                }
                    .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                    .background(Color.blue)
                    .padding()
            } else if (self.user.id.isEmpty ||  self.user.hospitals[user.selected_hospital].isEmpty || self.user.disease[user.selected_disease].isEmpty){
                Button(action: {
                    showingAlert = true //空欄があるとエラー
                }) {
                    HStack{
                        Image(systemName: "square.and.arrow.up")
                        Text("送信")
                    }
                        .foregroundColor(Color.white)
                        .font(Font.largeTitle)
                }
                    .alert(isPresented: $showingAlert){Alert(title: Text("項目に空欄があります"))}
                    .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                    .background(Color.black)
                    .padding()
            } else{
                Button(action: {
                    showingAlert = false
                    GenerateHashID()
                    SaveToResultHolder()
                    SaveToDoc()
                    self.user.isSendData = true
                    self.user.imageNum += 1 //画像番号を増やす
                    self.presentationMode.wrappedValue.dismiss()
               })
                {
                    HStack{
                        Image(systemName: "square.and.arrow.up")
                        Text("送信")
                    }
                        .foregroundColor(Color.white)
                        .font(Font.largeTitle)
                }
                .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                .background(Color.black)
                .padding()
            }
        }
    }
            
    //HASH化 id+hospitalcode
    public func GenerateHashID(){
        let id = self.user.id
        let hospitalcode = self.user.hospitalcode[user.selected_hospital]
        let newid = id + hospitalcode
        let dateid = Data(newid.utf8)
        let hashid = SHA256.hash(data: dateid)
        user.hashid = hashid.compactMap { String(format: "%02x", $0) }.joined()

        print("Generated hashid: \(user.hashid)")
    }
    
    //ResultHolderにテキストデータを格納
    public func SaveToResultHolder(){
        //var imagenum: String = String(user.imageNum)
        ResultHolder.GetInstance().SetAnswer(q1: stringDate(), q2: user.hashid, q3: user.id, q4: self.numToString(num: self.user.imageNum), q5: self.user.hospitals[user.selected_hospital], q6: self.user.disease[user.selected_disease], q7: self.user.free_disease)
    }
    
    public func stringDate()->String{
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        let stringDate = df.string(from: user.date)
        return stringDate
    }
    
    public func numToString(num:Int)->String{
        let string: String = String(num)
        return string
    }

    

    //private func saveToDoc (image: UIImage, fileName: String ) -> Bool{
    public func SaveToDoc () -> Bool{
        let images = ResultHolder.GetInstance().GetUIImages()
        let jsonfile = ResultHolder.GetInstance().GetAnswerJson()
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photoURL = documentsURL.appendingPathComponent(imageName()+".png")
        let movieURL = documentsURL.appendingPathComponent(imageName()+".mp4")
                
        //動画が保存されていない場合
        if ResultHolder.GetInstance().GetMovieUrls() == ""{
            //pngを保存
            for i in 0..<images.count{
                let pngImageData = UIImage.pngData(images[i])
                // jpgで保存する場合
                // let jpgImageData = UIImageJPEGRepresentation(image, 1.0)
                do {
                    try pngImageData()!.write(to: photoURL)
                    print("successfully saved PNG to doc")
                } catch {
                    //エラー処理
                    print("image save error")
                    return false
                }
            }
        }else{
            //動画が保存されている場合
            //mp4を保存
            let fileType: AVFileType = AVFileType.mp4
            // 動画をエクスポートする
            exportMovie(sourceURL: URL(string:ResultHolder.GetInstance().GetMovieUrls())!, destinationURL: movieURL, fileType: fileType)
        }
            
        //jsonを保存
        let jsonURL = documentsURL.appendingPathComponent(imageName()+".json")
        do {
            try jsonfile.write(to: jsonURL, atomically: true, encoding: String.Encoding.utf8)
            print("successfully saved json to doc")
        } catch {
            //エラー処理
            print("Jsonを保存できませんでした")
            return false
        }
        return true
    }

    public func GetImageStack(images: [UIImage], shorterSide: CGFloat) -> some View {
            let padding: CGFloat = 10.0
            let imageLength = shorterSide / 3 + padding * 2
            let colCount = Int(shorterSide / imageLength)
            let rowCount = Int(ceil(Float(images.count) / Float(colCount)))
            return VStack(alignment: .leading) {
                ForEach(0..<rowCount){
                    i in
                    HStack{
                        ForEach(0..<colCount){
                            j in
                            if (i * colCount + j < images.count){
                                let image = images[i * colCount + j]
                                Image(uiImage: image).resizable().frame(width: imageLength*2.4, height: imageLength*2.4).padding(padding)
                            }
                        }
                    }
                }
            }
            .border(Color.black)
        }
    
    
    public func GetShorterSide(screenSize: CGSize) -> CGFloat{
        let shorterSide = (screenSize.width < screenSize.height) ? screenSize.width : screenSize.height
        return shorterSide
    }
    

    //JOIRの画像命名
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
    
    
  
    
    func exportMovie(sourceURL: URL, destinationURL: URL, fileType: AVFileType) -> Void {

        let asset = AVAsset(url: sourceURL)

            let mixComposition = AVMutableComposition()

            let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)

            try! videoTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: asset.tracks(withMediaType: .video)[0], at: CMTime.zero)

            let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))

                if let track = asset.tracks(withMediaType: .audio).first {

                    do {
                        try audioTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: track, at: .zero)
                    } catch {
                        print("error")
                    }

                } else {
                    mixComposition.removeTrack(audioTrack!)
                    print("no audio detected, removed the track")
                }

        // エクスポートするためのセッションを作成
        let assetExport = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)

        // エクスポートするファイルの種類を設定
        assetExport?.outputFileType = fileType

        // エクスポート先URLを設定
        assetExport?.outputURL = destinationURL

        // エクスポート先URLに既にファイルが存在していれば、削除する (上書きはできないようなので)
//        if FileManager.default.fileExists(atPath: (assetExport?.outputURL?.path)!) {
//            try! FileManager.default.removeItem(atPath: (assetExport?.outputURL?.path)!)
//        }
        // エクスポートする
        assetExport?.exportAsynchronously(completionHandler: {
            // エクスポート完了後に実行したいコードを記述
            print("successfully exported mp4 to doc")
        })

    }
                                           

    
}











//ビデオ再生ビュー
struct PlayerView: UIViewRepresentable {
    let player: AVPlayer

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }

    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(player: player)
    }

}


class PlayerUIView: UIView {
    private let playerLayer = AVPlayerLayer()

    init(player: AVPlayer) {
        super.init(frame: .zero)
        playerLayer.player = player
        layer.addSublayer(playerLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

}
                                           
                                           
                                           
