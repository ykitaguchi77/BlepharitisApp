
//
//  Informations.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/04/18.
//
import SwiftUI

//変数を定義
struct Informations: View {
    @ObservedObject var user: User
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isSaved = false
    @State private var goTakePhoto: Bool = false  //撮影ボタン
    @State private var temp = "" //スキャン結果格納用の変数
    @State private var isScanning = false

    
    var body: some View {
        NavigationView{
                Form{
                    HStack{
                        Text("入力日時")
                        Text(self.user.date, style: .date)
                    }
                    
                    
                    Picker(selection: $user.selected_hospital,
                               label: Text("施設")) {
                        ForEach(0..<user.hospitals.count) {
                            Text(self.user.hospitals[$0])
                                 }
                        }
                       .onChange(of: user.selected_hospital) {_ in
                           self.user.isSendData = false
                           UserDefaults.standard.set(user.selected_hospital, forKey:"hospitaldefault")
                       }
                    
                    //DatePicker("入力日時", selection: $user.date)
                    
                    HStack{
                        Text("I D ")
                        TextField("idを入力してください", text: $user.id)
                            .keyboardType(.numbersAndPunctuation)
                            .onChange(of: user.id) { _ in
                                self.user.isSendData = false
                            }
                    }
                    
                    HStack{
                        ScanButton(text: $user.id)
                            .frame(width: 100, height: 30, alignment: .leading)
                        
                        Button(action: {
                            self.isScanning = true
                        }) {
                            HStack
                            {
                                Image(systemName: "qrcode.viewfinder")
                                Text("QRcode").font(.callout)
                            }
                        }
                        .sheet(isPresented: self.$isScanning) {
                            QRReader(text: $user.id, isScanning: $isScanning)
                        }
                    }
                        

                        
                    
                    
                    HStack{
                        Text("State")
                        Picker(selection: $user.selected_disease,
                                   label: Text("")) {
                            ForEach(0..<user.disease.count) {
                                Text(self.user.disease[$0])
                                    }
                            }
                            .onChange(of: user.selected_disease) {_ in
                                self.user.isSendData = false
                                UserDefaults.standard.set(user.selected_disease, forKey:"diseasedefault")
                                }
                            .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    HStack{
                        Text("Side")
                        Picker(selection: $user.selected_side,
                                   label: Text("")) {
                            ForEach(0..<user.side.count) {
                                Text(self.user.side[$0])
                                    }
                            }
                            .onChange(of: user.selected_side) {_ in
                                self.user.isSendData = false
                                UserDefaults.standard.set(user.selected_side, forKey:"sidedefault")
                                }
                            .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    HStack{
                        Text("自由記載欄")
                        TextField("", text: $user.free_disease)
                            .keyboardType(.default)
                    }.layoutPriority(1)
                    .onChange(of: user.free_disease) { _ in
                    self.user.isSendData = false
                    }
                }.navigationTitle("患者情報入力")
                .onAppear(){
                 }
            }
                
            
            Spacer()
        
//            Button(action: {
//                self.user.sourceType = UIImagePickerController.SourceType.camera
//                self.user.equipmentVideo = true
//                self.goTakePhoto = true /*またはself.show.toggle() */
//                self.user.isSendData = false //撮影済みを解除
//                ResultHolder.GetInstance().SetMovieUrls(Url: "")  //動画の保存先をクリア
//            }) {
//                HStack{
//                    Image(systemName: "video")
//                    Text("撮影")
//                }
//                    .foregroundColor(Color.white)
//                    .font(Font.largeTitle)
//            }
//                .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
//                .background(Color.black)
//                .padding()
//            .sheet(isPresented: self.$goTakePhoto) {
//                CameraPage(user: user)
//            }
        
        
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
               }
                
            ) {
                Text("保存")
                    .foregroundColor(Color.white)
                    .font(Font.largeTitle)
            }
                .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                .background(Color.black)
                .padding()
                .sheet(isPresented: self.$goTakePhoto) {
                    CameraPage(user: user)
                }
        
    }
}
