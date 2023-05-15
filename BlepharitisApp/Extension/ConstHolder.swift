
//
//  ConstHolder.swift
//  CorneaApp
//
//  Reused by Yoshiyuki Kitaguchi on 2021/04/19.
//  Created by Kuniaki Ohara on 2021/01/06.
//
import SwiftUI

class ConstHolder{
    static public let QUESTIONFILENAME = "testq.txt"
    static public let EVALIMAGESIZE = CGSize(width: 224, height: 224)
    static public let HWRATIO: CGFloat = 1 //縦横比
    static public let IMAGESCALE: CGFloat = 0.9 //プレビュー画面の大きさ
    static public let FACEMASKNAME1 = "front"

    static public let PROCESSINGMASKNAME = "Processing"
    
    
    static public let EVALURL = "http://20.63.174.246:80/api/v1/service/test/score"
    static public let EVALKEY = "chjl5DCcSgWUdpWgDkPENIZqCZoF8sJa"
    
    static public let IMAGECONTAINERURI = "https://gravdata.blob.core.windows.net/gravimage?sv=2020-04-08&st=2021-05-08T07%3A26%3A51Z&se=2021-07-08T10%3A26%3A00Z&sr=c&sp=rwl&sig=uHtS5UZozmmpBoUenx3CfJ24lg6lTtcKuj9fQZ1QttQ%3D"
    static public let TEXTCONTAINERURI = "https://gravdata.blob.core.windows.net/gravtext?sv=2020-04-08&st=2021-05-08T08%3A09%3A35Z&se=2021-07-09T08%3A09%3A00Z&sr=c&sp=rwl&sig=IWkhBucOj8nixL6PButL%2B9LGQ9cdRUQgozzVybRsRZg%3D"
}
