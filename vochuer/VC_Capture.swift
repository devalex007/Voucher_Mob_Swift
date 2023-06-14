//
//  VC_Capture.swift
//  vochuer
//
//  Created by Admin on 6/5/23.
//

import UIKit
import Alamofire
import AVFoundation
import VisionKit
import MBProgressHUD

struct SuccessResponse: Codable{
    var success: Int?
}

class VC_Capture: UIViewController{
    
    @IBOutlet weak var txtStore: UITextField!
    @IBOutlet weak var txtReceiptNum: UITextField!
    
    @IBOutlet weak var btnVoucher: UIButton!
    @IBOutlet weak var btnReceipt: UIButton!
    @IBOutlet weak var btnReceipt2: UIButton!
    @IBOutlet weak var btnMisc: UIButton!
    
    @IBOutlet weak var vVoucher: UIView!
    @IBOutlet weak var vReceipt: UIView!
    @IBOutlet weak var vReceipt2: UIView!
    @IBOutlet weak var vMisc: UIView!
    
    @IBOutlet weak var imgVoucher: UIImageView!
    @IBOutlet weak var imgReceipt: UIImageView!
    @IBOutlet weak var imgReceipt2: UIImageView!
    @IBOutlet weak var imgMisc: UIImageView!
    
    @IBOutlet weak var btnScanBarCode: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    
    var selectedScanType: ScanTypes = .voucher
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initComponents()
//        openBarCodeScanner()
    }
    
    func initComponents(){
        btnSubmit.makeCircleView()
        btnScanBarCode.makeCircleView()
        
        vVoucher.makeRoundView()
        vReceipt.makeRoundView()
        vReceipt2.makeRoundView()
        vMisc.makeRoundView()
        
//        setupForTest()
    }
    
    func setupForTest(){
        txtReceiptNum.text = "1637623"
        txtStore.text = "950"

        imgVoucher.image = UIImage(named: "cameraRotate")
        imgReceipt.image = UIImage(named: "cameraRotate")
        imgReceipt2.image = UIImage(named: "cameraRotate")
        imgMisc.image = UIImage(named: "cameraRotate")
    }
    
    @IBAction func opVoucher(_ sender: Any) {
        selectedScanType = .voucher
        openDocScanner()
    }
    
    @IBAction func opReceipt(_ sender: Any) {
        selectedScanType = .receipt
        openDocScanner()
    }
    
    @IBAction func opReceipt2(_ sender: Any) {
        selectedScanType = .receipt2
        openDocScanner()
    }
    
    @IBAction func opMisc(_ sender: Any) {
        selectedScanType = .misc
        openDocScanner()
    }
    
    @IBAction func opScanBarCode(_ sender: Any) {
        txtReceiptNum.text = ""
        txtStore.text = ""
        
        openBarCodeScanner()
    }
    
    func openBarCodeScanner(){
        let vc = BarcodeScannerViewController()
        vc.codeDelegate = self
        vc.errorDelegate = self
        vc.dismissalDelegate = self
        
        present(vc, animated: true)
    }
    
    func openDocScanner(){
        if !VNDocumentCameraViewController.isSupported{
            GlobalDialog.showErrorMessage(message: "Your phone is not supported to use Document Scanner.")
            return
        }
        
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @IBAction func opSubmit(_ sender: Any) {
        let store_receipt_num_str: String = txtReceiptNum.text!
        let store_id_str: String = txtStore.text!
        
        if (store_receipt_num_str.isEmpty || store_id_str.isEmpty){
            GlobalDialog.showErrorMessage(message: "Please scan the valid QR Code to submit")
            return
        }
        
        if (imgVoucher.image == nil && imgReceipt.image == nil && imgReceipt2.image == nil && imgMisc.image == nil){
            GlobalDialog.showErrorMessage(message: "Please scan the document to submit")
            return
        }
        
        if Int(store_receipt_num_str) != nil,
           Int(store_id_str) != nil{
            self.performPostRequest(store_num: store_receipt_num_str, store_id: store_id_str)
        }
    }
    
    @IBAction func opRefresh(_ sender: Any) {
        txtStore.text = ""
        txtReceiptNum.text = ""
        
        imgVoucher.image = nil
        imgReceipt.image = nil
        imgReceipt2.image = nil
        imgMisc.image = nil
    }
}

extension VC_Capture {
    // Example GET request with parameters
    func performGetRequest(store_num: Int, store_id: Int) {
        self.showHUD("Getting Company Name...")
        
        let parameters: Parameters = [
            "store_receipt_num": store_num,
            "store_id": store_id
        ]
        
        AF.request("https://appilocity.a2hosted.com/getCompanyName", parameters: parameters)
            .validate()
            .response { response in
                self.dismissHUD()
                
                switch response.result {
                case .success(let data):
                    if let jsonData = data {
                        var getResultSuccess = false
                        if let jsonResponse = try? JSONSerialization.jsonObject(with: jsonData, options: []){
                            print(jsonResponse)
                            if let dic = jsonResponse as? [String: Any]{
                                if let success = dic["success"] as? Int, success == 1{
                                    getResultSuccess = true
                                    if let name = dic["company"] as? String, !name.isEmpty{
                                        GlobalDialog.showSuccessMessage(message: "Company name is \(name)!")
                                    } else {
                                        GlobalDialog.showSuccessMessage(message: "No company name! Try another bar code!")
                                    }
                                }
                            }
                        }
                        
                        if (!getResultSuccess){
                            GlobalDialog.showErrorMessage(message: "Failed to get the company name! Try again!")
                        }
                    }
                case .failure(let error):
                    GlobalDialog.showErrorMessage(message: error.localizedDescription)
                }
            }
    }
    
    func performPostRequest(store_num: String, store_id: String) {
        self.showHUD("Submitting...")
        let curTime: String = Date().toMillis() ?? ""
        AF.upload(multipartFormData: {(multiFormData) in
            multiFormData.append(Data(store_num.utf8), withName: "storeReceiptNum")
            multiFormData.append(Data(store_id.utf8), withName: "storeId")
            
            if let iVoucherData = self.imgVoucher.image?.pngData(){
                multiFormData.append(iVoucherData, withName: "files", fileName: "voucher_\(curTime)", mimeType: "image/png")
            }
            if let iReceiptData = self.imgReceipt.image?.pngData(){
                multiFormData.append(iReceiptData, withName: "files", fileName: "receipt_\(curTime)", mimeType: "image/png")
            }
            if let iReceiptData2 = self.imgReceipt2.image?.pngData(){
                multiFormData.append(iReceiptData2, withName: "files", fileName: "receipt2_\(curTime)", mimeType: "image/png")
            }
            if let iMiscData = self.imgMisc.image?.pngData(){
                multiFormData.append(iMiscData, withName: "files", fileName: "misc_\(curTime)", mimeType: "image/png")
            }
        }, to: "https://appilocity.a2hosted.com/saveVouchers")
        .response { response in
            self.dismissHUD()
            
            switch response.result {
            case .success(let data):
                if let jsonData = data {
                    var updatedSuccessfully = false
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: jsonData, options: []){
                        print(jsonResponse)
                        if let dic = jsonResponse as? [String: Any]{
                            if let success = dic["success"] as? Int, success == 1{
                                updatedSuccessfully = true
                                GlobalDialog.showSuccessMessage(message: "Submitted successfully!")
                            }
                        }
                    }
                    
                    if (!updatedSuccessfully){
                        GlobalDialog.showErrorMessage(message: "Failed to submit the result! Try again!")
                    }

                    DispatchQueue.main.async {
                        self.imgVoucher.image = nil
                        self.imgReceipt.image = nil
                        self.imgReceipt2.image = nil
                        self.imgMisc.image = nil
                        
                        self.txtStore.text = ""
                        self.txtReceiptNum.text = ""
                    }
                    
                }
            case .failure(let error):
                GlobalDialog.showErrorMessage(message: error.localizedDescription)
            }
        }
    }
}

extension VC_Capture: BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate {
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        print("Dismissed!!")
        controller.dismiss(animated: true)
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print("Error - \(error.localizedDescription)")
        controller.dismiss(animated: true)
    }
    
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        print("code - \(code)")
        print("type - \(type)")
        
        if !code.contains("-"){
            self.txtReceiptNum.text = ""
            self.txtStore.text = ""
            
            GlobalDialog.showErrorMessage(message: "Scanned Bar Code is \(code). But it's not a valid bar code this application can use. Try another bar code!")
            return
        }
        
        let codes = code.split(separator: "-")
        
        let store_receipt_num_str: String = String(codes[0])
        let store_id_str: String = String(codes[1])
        if let store_receipt_num = Int(store_receipt_num_str),
           let store_id = Int(store_id_str) {
            self.txtReceiptNum.text = store_receipt_num_str
            self.txtStore.text = store_id_str
            
            self.performGetRequest(store_num: store_receipt_num, store_id: store_id)
        } else {
            self.txtReceiptNum.text = ""
            self.txtStore.text = ""
        }
        
        controller.dismiss(animated: true)
    }
}

extension VC_Capture: VNDocumentCameraViewControllerDelegate{
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        print("Found \(scan.pageCount)")
        
        if (scan.pageCount > 0){
            let img = scan.imageOfPage(at: 0)
            switch(self.selectedScanType){
            case .voucher:
                imgVoucher.image = img
                break
            case .receipt:
                imgReceipt.image = img
                break
            case .receipt2:
                imgReceipt2.image = img
                break
            case .misc:
                imgMisc.image = img
                break
            }
        } else {
            GlobalDialog.showErrorMessage(message: "No images scanned!")
        }
        
        controller.dismiss(animated: true)
    }
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true)
    }
}

public enum ScanTypes {
    case voucher
    case receipt
    case receipt2
    case misc
}

extension Date{
    func toMillis() -> String!{
        return String(self.timeIntervalSince1970 * 1000)
    }
}

extension UIViewController {
    func showHUD(_ msg : String) {
        DispatchQueue.main.async{
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressHUD.label.text = msg
            
            progressHUD.backgroundView.color = .black
            progressHUD.backgroundView.style = .solidColor
            progressHUD.backgroundView.alpha = 0.3
        }
    }
    
    func dismissHUD() {
        DispatchQueue.main.async{
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }

}
