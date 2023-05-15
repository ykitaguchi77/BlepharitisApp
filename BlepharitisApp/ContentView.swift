//
//  ContentView.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/04/18.
//
//写真Coredata参考サイト：https://tomato-develop.com/swiftui-camera-photo-library-core-data/
//
import SwiftUI
import CoreData

//変数を定義
class User : ObservableObject {
    @Published var date: Date = Date()
    @Published var id: String = ""
    @Published var hashid: String = ""
    @Published var selected_gender: Int = 0
    @Published var selected_side: Int = 0
    @Published var selected_hospital: Int = 0
    @Published var selected_disease: Int = 0
    @Published var free_disease: String = ""
    @Published var gender: [String] = ["", "男", "女"]
    @Published var birthdate: String = ""
    @Published var side: [String] = ["", "右", "左"]
    @Published var hospitals: [String] = ["", "宮田眼科", "いしづち眼科", "杉浦眼科", "服部クリニック", "松本眼科", "いのうえ眼科", "堀切眼科"]
    @Published var hospitalcode: [String] = ["", "0211008", "0528384", "0601849", "4301305", "1711498", "3402978", "2228831"]
    @Published var disease: [String] = ["", "治療前", "治療後"]
    @Published var imageNum: Int = 0 //写真の枚数（何枚目の撮影か）
    @Published var isNewData: Bool = false
    @Published var isSendData: Bool = false
    @Published var sourceType: UIImagePickerController.SourceType = .camera //撮影モードがデフォルト
    @Published var equipmentVideo: Bool = true //video or camera 撮影画面のマージ指標変更のため
    }


struct ContentView: View {
    @ObservedObject var user = User()
    @State private var goTakePhoto: Bool = false  //撮影ボタン
    @State private var isPatientInfo: Bool = false  //患者情報入力ボタン
    @State private var goSendData: Bool = false  //送信ボタン
    @State private var uploadData: Bool = false  //アップロードボタン
    @State private var newPatient: Bool = false  //新規患者ボタン
    @State private var goSearch: Bool = false  //検索ボタン
    
    
    var body: some View {
        VStack(alignment:.center, spacing:0){
            Text("Blepharitis app")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.bottom)
            
            Image("Blepharitis")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
        }
        
        
        
        VStack(alignment:.leading, spacing:-10){
            
            Button(action: {
                //病院番号はアプリを落としても保存されるようにしておく
                self.user.selected_hospital = UserDefaults.standard.integer(forKey: "hospitaldefault")
                self.user.selected_disease = UserDefaults.standard.integer(forKey: "diseasedefault")
                self.isPatientInfo = true /*またはself.show.toggle() */
                
            }) {
                HStack{
                    Image(systemName: "info.circle")
                    Text("患者情報入力")
                }
                    .foregroundColor(Color.white)
                    .font(Font.largeTitle)
            }
                .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                .background(Color.black)
                .padding()
            .sheet(isPresented: self.$isPatientInfo) {
                Informations(user: user)
                //こう書いておかないとmissing as ancestorエラーが時々でる
            }
            
            HStack(spacing:-10){
                Button(action: {
                    self.user.sourceType = UIImagePickerController.SourceType.camera
                    self.user.equipmentVideo = true
                    self.goTakePhoto = true /*またはself.show.toggle() */
                    self.user.isSendData = false //撮影済みを解除
                    ResultHolder.GetInstance().SetMovieUrls(Url: "")  //動画の保存先をクリア
                }) {
                    HStack{
                        Image(systemName: "video")
                        Text("撮影")
                    }
                        .foregroundColor(Color.white)
                        .font(Font.largeTitle)
                }
                    .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                    .background(Color.black)
                    .padding()
                .sheet(isPresented: self.$goTakePhoto) {
                    CameraPage(user: user)
                }
                
                
                
                //送信するとボタンの色が変わる演出
                if self.user.isSendData {
                    Button(action: {self.goSendData = true /*またはself.show.toggle() */}) {
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
                    .sheet(isPresented: self.$goSendData) {
                        SendData(user: user)
                    }
                } else {
                    Button(action: { self.goSendData = true /*またはself.show.toggle() */ }) {
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
                    .sheet(isPresented: self.$goSendData) {
                        SendData(user: user)
                    }
                }
            }

            
            Button(action: { self.newPatient = true /*またはself.show.toggle() */ }) {
                HStack{
                    Image(systemName: "stop.circle")
                    Text("次患者")
                }
                    .foregroundColor(Color.white)
                    .font(Font.largeTitle)
            }
            .alert(isPresented:$newPatient){
                Alert(title: Text("データをクリアしますか？"), primaryButton:.default(Text("はい"),action:{
                    //データの初期化
                    self.user.date = Date()
                    self.user.id = ""
                    self.user.birthdate = ""
                    self.user.imageNum = 0
                    self.user.selected_gender = 0
                    self.user.selected_side = 0
                    self.user.selected_hospital = 0
                    self.user.selected_disease = 0
                    self.user.free_disease = ""
                    self.user.isSendData = false
                }),
                      secondaryButton:.destructive(Text("いいえ"), action:{}))
                }
                .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                .background(Color.black)
                .padding()
            
            
            HStack(spacing:-10){
                Button(action: {self.goSearch = true /*またはself.show.toggle() */}) {
                    HStack{
                        Image(systemName: "applepencil")
                        Text("修正")
                    }
                    .foregroundColor(Color.white)
                    .font(Font.largeTitle)
                }
                .frame(minWidth:0, maxWidth:160, minHeight: 75)
                .background(Color.black)
                .padding()
                .sheet(isPresented: self.$goSearch) {
                    Search(user: user)
                }
                
                Button(action: {
                    self.user.sourceType = UIImagePickerController.SourceType.photoLibrary
                    self.user.isSendData = false //撮影済みを解除
                    self.uploadData = true /*またはself.show.toggle() */
                    
                }) {
                    HStack{
                        Image(systemName: "folder")
                        Text("Up")
                    }
                        .foregroundColor(Color.white)
                        .font(Font.largeTitle)
                }
                    .frame(minWidth:0, maxWidth:200, minHeight: 75)
                    .background(Color.black)
                    .padding()
                .sheet(isPresented: self.$uploadData) {
                    CameraPage(user: user)
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
