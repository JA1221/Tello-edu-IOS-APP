import UIKit
import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var sendData: UITextField!
    @IBOutlet weak var receiveData: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var tello1_IP: UITextField!
    @IBOutlet weak var sendPort1: UITextField!
    @IBOutlet weak var speed: UILabel!
    @IBOutlet weak var dist: UILabel!
    
    //設定 IP Port , 指定UDP連線
    var myPort = 60000
    var host = "192.168.43.103"
    var port = 8889
    
    var client: UDPClient?
    var stateUDP: UDPServer?
    var audioPlayer: AVAudioPlayer!
    var data = ""
    
    //飛行速度
    var speedVal = 50
    var distVal = 30
    let defaultValue = 30
    
    var stateDate = ""
    var dictionary = [String: String]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        receiveData.layer.cornerRadius = 10
        
        //建立 UDP 連線
        setAdress((Any).self)
//        client = UDPClient(address: host, port: Int32(port),myAddresss: "", myPort: Int32(myPort))
        readData()
        
        //建立 stateUDP
        stateUDP = UDPServer(address: "", port: 8890)
        readState()
        
        //播放音樂
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
        myPort = Int(sendPort1.text ?? "60000")!
        
        client?.close()//一定要先close 不然port會佔用
        client = UDPClient(address: host, port: Int32(port),myAddresss: "", myPort: Int32(myPort))
        receiveData.text = "set IP:" + host + ", send port:" + String(myPort)
    }
    @IBAction func showInfo(_ sender: Any) {
        var s = ""
        for i in stateDate.components(separatedBy: ";"){
            s += i + "\n"
        }
        
        let info = UIAlertController(title: "Tello 資訊", message: s, preferredStyle: .alert)
        info.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(info, animated: true, completion: nil)
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
            self.send("go 0 0 150 " + String(self.speedVal) + " m1")
            self.wait()
            self.send("go 0 0 150 " + String(self.speedVal) + " m2")
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
    //等待回傳才執行下個指令
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
        sender.value.round()//取整數
        let speedValue = Int(sender.value)
        speed.text = speedValue.description
        send("speed " + speedValue.description)
    }
    @IBAction func distValue(_ sender: UISlider) {//設定飛行距離
        sender.value.round()
        let speedValue = Int(sender.value)
        dist.text = speedValue.description
    }
    
//===================== sned & recv =======================
    func send(_ s: String){
        guard let client = client else {return}//當client存在時才往下執行
        
        showMessage("wait...")
        _ = client.send(string: s)
        print("i send!")
    }
    
    //udp回傳值 data的 (byte陣列 轉 string)
    func get_String_Data(_ data: [Byte]) -> (String){
        let string1 = String(data: Data(data), encoding: .utf8) ?? ""
        return string1
    }
    
    func readData(){
        let queue = DispatchQueue(label: "com.nkust.JA1221.readData")//宣告 label需要唯一性
        queue.async {//多執行緒
            while true{
                guard let client = self.client else { return }
                if client.fd == nil{
                    print("socket 設定中")
                    continue
                }
                
                print("i wait recv")
                let s = client.recv(20)//最多接收20
                if s.0 == nil{continue}//處理socket設定時 為空資料時錯誤
                
                //存入data
                self.data = self.get_String_Data(s.0!)
                print(self.data)
                self.showMessage(self.data)
                print("----------------------")
                print(s.0!)//資料 ->[byte]
                print(s.1)//來源IP
                print(s.2)//來源Port
                print("----------------------")
            }
        }
    }
    
    func readState(){
        let queue = DispatchQueue(label: "com.nkust.JA1221.readState")
        queue.async {
            while true{
                guard let stateUDP = self.stateUDP else { return }
                print("waiting recv state")

                let s = stateUDP.recv(1000)
                self.stateDate = self.get_String_Data(s.0!)
                
                let line = self.stateDate.components(separatedBy: ";")
                for i in line{
                    let tmp = i.components(separatedBy: ":")
                    if(tmp.count == 2){
                        self.dictionary[tmp[0]] = tmp[1]
                    }
                }

                print("電量：" + (self.dictionary["bat"] ?? "?"))
                self.showBattery(self.dictionary["bat"] ?? "？")
            }
        }
    }
    
//======================================================================
    
    //顯示資訊 主執行緒
    func showMessage(_ s: String){
        DispatchQueue.main.async {
            self.receiveData.text = s//主執行緒設定label text 直接顯示
        }
    }
    
    func showBattery(_ s: String){
        DispatchQueue.main.async {
            self.batteryLabel.text = "電量：" + s// 設定電量
        }
    }
    
    //輸入指令區 按下enter 送出
    func textFieldShouldReturn(_ textField: UITextField ) -> Bool{
        if let text = sendData.text{
            send( text)//傳送 textView文字指令
            sendData.text = ""//清空
        }
        
        textField.resignFirstResponder()
        return true
    }

    //點鍵盤外 鍵盤收起
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    //離開時 關閉udp ＆ 音樂停止
    override func viewDidDisappear(_ animated: Bool) {
        client?.close()
        audioPlayer.stop()
    }
    
}

