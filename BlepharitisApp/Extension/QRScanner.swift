import SwiftUI
import AVFoundation

struct QRReader: UIViewControllerRepresentable {
    @Binding var text: String
    @Binding var isScanning: Bool
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<QRReader>) -> UIViewController {
        let controller = UIViewController()
        let captureSession = AVCaptureSession()
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return controller }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return controller }
        captureSession.addInput(input)
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: .main)
        captureMetadataOutput.metadataObjectTypes = [.qr, .ean13] // add ean13 to scan barcode
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = controller.view.frame
        controller.view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<QRReader>) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRReader

        init(_ parent: QRReader) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first,
               let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
               let stringValue = readableObject.stringValue {
                parent.text = stringValue
                parent.isScanning = false
//                UIApplication.shared.windows.first?.rootViewController?.presentedViewController?.dismiss(animated: true, completion: nil)

            }
        }
    }
}
