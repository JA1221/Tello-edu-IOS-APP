import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var sendData: UITextField!
    @IBOutlet weak var receiveData: UILabel!
    @IBOutlet weak var tello1_IP: UITextField!
    @IBOutlet weak var sendPort1: UITextField!
    @IBOutlet weak var num: UILabel!
    
    //設定 IP Port , 指定UDP連線
    var serverPort = 9453
    var host = "192.168.43.103"
    var port = 8889
    
    var client: UDPClient?
    var batteryClient: UDPClient?
    var data = ""
    
    //飛行速度
    var speedVal = 10
    let defaultValue = 30
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        client = UDPClient(address: host, port: Int32(port),myAddresss: "", myPort: Int32(serverPort))//建立 UDP 連線
        
        readData()
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
    
    @IBAction func speedValue(_ sender: UISlider) {//設定飛行速度
        sender.value.round()
        let speedValue = Int(sender.value)
        num.text = speedValue.description
        send("speed " + speedValue.description)
    }
    //================ bt =====================
    @IBAction func command(_ sender: Any) {//sdk模式
        send("command")
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
    
    @IBAction func emergency(_ sender: Any) {//關閉引擎
        send("emergency")
    }
    @IBAction func flipL(_ sender: Any) {//右翻
        send("flip l")
    }
    @IBAction func stop(_ sender: Any) {//停止動作
        send("stop")
    }
    @IBAction func flipR(_ sender: Any) {//右翻
        send("flip r")
    }
    @IBAction func battery_Info(_ sender: Any) {//資持資訊
        send("battery?")
    }
    @IBAction func flipB(_ sender: Any) {//後翻
        send("flip b")
    }
    //=============== bt control=============＄
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
        
        send("go 0 0 150 10 m3")
        wait()
        send("go 0 0 150 10 m4")
        wait()
        send("ccw 45")
        wait()
        send("cw 90")
        wait()
        send("ccw 45")
        wait()
        send("flip f")
        wait()
        send("land")
    }
    func wait(){
        receiveData.text = data
        data = ""
        while(data == ""){
            
        }
    }
    //============================================
    func send(_ s: String){
        guard let client = client else {return}//當client存在時才往下執行
        
        _ = client.send(string: s)
        print("i send!")
    }
    func readData(){
        let queue = DispatchQueue(label: "com.nkust.JA1221")//宣告 label需要唯一性
        
        queue.async {
            while true
            {
                guard let client = self.client else { return }
                
                print("i wait recv")
                let s = client.recv(20)//最多接收20
                
                if s.0==nil {continue}
                
                self.data = self.get_String_Data(s.0!)
                print(self.data)
                DispatchQueue.main.async {
                    self.receiveData.text = self.data//主執行緒設定label text 直接顯示
                }
                print(s.0)//資料
                print(s.1)//來源IP
                print(s.2)//來源Port
            }
            
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
    }
    
}

