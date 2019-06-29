import UIKit
import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var sendData: UITextField!
    @IBOutlet weak var receiveData: UILabel!
    @IBOutlet weak var tello1_IP: UITextField!
    @IBOutlet weak var sendPort1: UITextField!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var dist: UILabel!
    
    //設定 IP Port , 指定UDP連線
    var serverPort = 9453
    var host = "192.168.43.103"
    var port = 8889
    
    var client: UDPClient?
    var batteryClient: UDPClient?
    var audioPlayer: AVAudioPlayer!
    var data = ""
    
    //飛行速度
    var speedVal = 50
    var distVal = 30
    let defaultValue = 30
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        receiveData.layer.cornerRadius = 10
        
        client = UDPClient(address: host, port: Int32(port),myAddresss: "", myPort: Int32(serverPort))//建立 UDP 連線
        
        readData()
        
        let url = Bundle.main.url(forResource: "2018_Charlie Puth - Marvin Gaye", withExtension: "mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
            audioPlayer.prepareToPlay()
        } catch {
            print("Error:", error.localizedDescription)
        }
        audioPlayer.play()
    }
//====================== button =================
    @IBAction func onClick(_ sender: Any) {//按鈕發送指令
        guard client != nil else { return }
        
        if let text = sendData.text{
            send(text)//傳送 textView文字指令
            sendData.text = ""//清空
        }
    }
    @IBAction func setAdress(_ sender: Any) {//設定tello ip ＆ 本機port
        host = tello1_IP.text ?? "192.168.10.1"
        serverPort = Int(sendPort1.text ?? "9453")!
        
        client?.close()
        client = UDPClient(address: host, port: Int32(port),myAddresss: "", myPort: Int32(serverPort))
        receiveData.text = "set IP:" + host + ", send port:" + String(serverPort)
    }
    //================ bt =====================
    @IBAction func command(_ sender: Any) {//sdk模式
        send("command")
        send("mon")
    }
    @IBAction func takeoff(_ sender: Any) {//起飛
        send("takeoff")
    }
    
    @IBAction func land(_ sender: Any) {//下降
        send("land")
    }
    
    @IBAction func flipF(_ sender: Any) {//前翻
        send("flip f");
    }
    @IBAction func flipL(_ sender: Any) {//左翻
        send("flip l")
    }
    @IBAction func flipB(_ sender: Any) {//後翻
        send("flip b")
    }
    @IBAction func flipR(_ sender: Any) {//右翻
        send("flip r")
    }
    @IBAction func emergency(_ sender: Any) {//關閉引擎
        send("emergency")
    }
    @IBAction func stop(_ sender: Any) {//停止動作
        send("stop")
    }
    @IBAction func battery_Info(_ sender: Any) {//電池資訊
        send("battery?")
    }
    //=============== bt control=============
    @IBAction func forward(_ sender: Any) {
        send("forward " + String(defaultValue))
    }
    @IBAction func back(_ sender: Any) {
        send("back " + String(defaultValue))
    }
    @IBAction func right(_ sender: Any) {
        send("right " + String(defaultValue))
    }
    @IBAction func left(_ sender: Any) {
        send("left " + String(defaultValue))
    }
    
    @IBAction func up(_ sender: Any) {
        send("up " + String(defaultValue))
    }
    @IBAction func down(_ sender: Any) {
        send("down " + String(defaultValue))
    }
    @IBAction func cw(_ sender: Any) {
        send("cw 45")
    }
    @IBAction func ccw(_ sender: Any) {
        send("ccw 45")
    }
    @IBAction func dodo(_ sender: Any) {
        let queue = DispatchQueue(label: "com.nkust.dodo")
        
        queue.async {
            self.send("takeoff")
            self.wait()
            self.send("go 0 0 150 " + String(self.speedVal) + " m3")
            self.wait()
            self.send("go 0 0 150 " + String(self.speedVal) + " m4")
            self.wait()
            self.send("ccw 45")
            self.wait()
            self.send("cw 90")
            self.wait()
            self.send("ccw 45")
            self.wait()
            self.send("flip f")
            self.wait()
            self.send("land")
        }
        
    }
    func wait(){
        data = ""
        while(data == ""){
        }
        showMessage(data)
    }
    //================= mission pad =================
    @IBAction func pad1(_ sender: Any) {
        send("go 0 0 100 " + String(speedVal) + " m1")
    }
    @IBAction func pad2(_ sender: Any) {
        send("go 0 0 100 " + String(speedVal) + " m2")
    }
    @IBAction func pad3(_ sender: Any) {
        send("go 0 0 100 " + String(speedVal) + " m3")
    }
    @IBAction func pad4(_ sender: Any) {
        send("go 0 0 100 " + String(speedVal) + " m4")
    }
    @IBAction func pad5(_ sender: Any) {
        send("go 0 0 100 " + String(speedVal) + " m5")
    }
    @IBAction func pad6(_ sender: Any) {
        send("go 0 0 100 " + String(speedVal) + " m6")
    }
    @IBAction func pad7(_ sender: Any) {
        send("go 0 0 100 " + String(speedVal) + " m7")
    }
    @IBAction func pad8(_ sender: Any) {
        send("go 0 0 100 " + String(speedVal) + " m8")
    }
    
    //================= slider ====================
    @IBAction func speedValue(_ sender: UISlider) {//設定飛行速度
        sender.value.round()
        let speedValue = Int(sender.value)
        speed.text = speedValue.description
        send("speed " + speedValue.description)
    }
    @IBAction func distValue(_ sender: UISlider) {
        sender.value.round()
        let speedValue = Int(sender.value)
        dist.text = speedValue.description
    }
    
    //============================================
    func send(_ s: String){
        guard let client = client else {return}//當client存在時才往下執行
        
        showMessage("wait...")
        _ = client.send(string: s)
        print("i send!")
        readData()
    }
    func readData(){
        let queue = DispatchQueue(label: "com.nkust.JA1221")//宣告 label需要唯一性
        queue.async {
            guard let client = self.client else { return }
            
            print("i wait recv")
            
            
            var s = client.recv(20)//最多接收20
            
            while s.0==nil{
                s = client.recv(20)
            }
            
            self.data = self.get_String_Data(s.0!)//存入data
            print(self.data)
            self.showMessage(self.data)
            print("----------------------")
            print(s.0)//資料
            print(s.1)//來源IP
            print(s.2)//來源Port
            print("----------------------")
        }
    }
    func showMessage(_ s: String){
        DispatchQueue.main.async {
            self.receiveData.text = s//主執行緒設定label text 直接顯示
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField ) -> Bool{
        if let text = sendData.text{
            send( text)//傳送 textView文字指令
            sendData.text = ""//清空
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func get_String_Data(_ data: [Byte]) -> (String){
        let string1 = String(data: Data(data), encoding: .utf8) ?? ""
        return string1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        client?.close()
        audioPlayer.stop()
    }
    
}

