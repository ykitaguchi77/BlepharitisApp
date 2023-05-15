//
//  ScanButton.swift
//  OcularTumorApp
//
//  Created by Yoshiyuki Kitaguchi on 2022/01/17.
// https://www.raywenderlich.com/28189776-capturing-text-from-camera-using-swiftui#toc-anchor-008
// https://github.com/chFlorian/ScanTextField
import SwiftUI

struct ScanButton: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UIButton {
        let textFromCamera = UIAction.captureTextFromCamera(
          responder: context.coordinator,
          identifier: nil)
        let button = UIButton(primaryAction: textFromCamera)
        return button
      }

    func updateUIView(_ uiView: UIButton, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
      Coordinator(self)
    }

    class Coordinator: UIResponder, UIKeyInput {
      let parent: ScanButton
      init(_ parent: ScanButton) { self.parent = parent }

      var hasText = false
      func insertText(_ text: String) { parent.text = text}
      func deleteBackward() { }
    }
    

}
