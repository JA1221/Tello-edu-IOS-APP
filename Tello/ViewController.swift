import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var sendData: UITextField!
    @IBOutlet weak var receiveData: UILabel!
    @IBOutlet weak var batteryText: UILabel!
    
    let serverIP = ""
    let serverPort = 8787
    //設定 IP Port , 指定UDP連線
    let host = "192.168.43.103"
    let port = 8889
    var client: UDPClient?
    var batteryClient: UDPClient?
    var server: UDPServer?
    var data = ""
    var batteryTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        client = UDPClient(address: host, port: Int32(port),myAddresss: serverIP, myPort: Int32(serverPort))//建立 UDP 連線
        batteryClient = UDPClient(address: host, port: Int32(port),myAddresss: serverIP, myPort: Int32(9487))//建立 UDP 連線
        
//       batteryTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {(_) in
//            self.readBattery()})

    }
//====================== button =================
    @IBAction func onClick(_ sender: Any) {
        guard let client = client else { return }
        
        if let text = sendData.text{
            send( text)//傳送 textView文字指令
            sendData.text = ""//清空
        }
    }
    @IBAction func takeoff(_ sender: Any) {
        send("takeoff")
    }
    
    @IBAction func land(_ sender: Any) {
        send("land")
    }
    
    @IBAction func flipF(_ sender: Any) {
        send("flip f");
    }
    
    
    @IBAction func emergency(_ sender: Any) {
        send("emergency")
    }
    @IBAction func flipL(_ sender: Any) {
        send("flip l")
    }
    @IBAction func stop(_ sender: Any) {
        send("stop")
    }
    @IBAction func flipR(_ sender: Any) {
        send("flip r")
    }
    @IBAction func battery_Info(_ sender: Any) {
        send("battery?")
    }
    @IBAction func flipB(_ sender: Any) {
        send("flip b")
    }
    //============================================
    func send(_ s: String){
        guard let client = client else {return}
        _ = client.send(string: s)
        print("i send!")
    }
    func readData(){
        let queue = DispatchQueue(label: "com.nkust.JA1221")
        
        queue.async {
            while true
            {
                guard let client = self.client else { return }
                
                print("i wait recv")
                let s = client.recv(20)
                self.data = self.get_String_Data(s.0!)
                print(self.data)
                DispatchQueue.main.async {
                    self.receiveData.text = self.data
                }
                print(s.0)
                print(s.1)
                print(s.2)
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
    
//    func readBattery(){
//        guard let client = batteryClient else {return}
//        client.send(string: "battery?")
//        let s = client.recv(10)
//        batteryText.text = get_String_Data(s.0!) + "%"
//    }
}

