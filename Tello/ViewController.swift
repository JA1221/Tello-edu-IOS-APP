import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sendData: UITextField!
    @IBOutlet weak var receiveData: UILabel!
    
    //設定 IP Port , 指定UDP連線
    let host1 = "192.168.43.249"
    let host2 = "192.168.10.1"
    let port = 8889
    var client1: UDPClient?
    var client2: UDPClient?
    var server: UDPServer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client2 = UDPClient(address: host2, port: Int32(port))//建立 UDP 連線
        server = UDPServer(address: "127.0.0.1", port: 8890)
        
        readData()
    }

    @IBAction func onClick(_ sender: Any) {
        guard let client = client2 else { return }
        
        if let text = sendData.text{
            //client1 = UDPClient(address: host1, port: Int32(port))//建立 UDP 連線
            
//            sendall( text)//傳送 textView文字指令
            send2(text)
//            let s = client.recv(100)
//            print(s.0)
//            print(s.1)
//            print(s.2)
        }
    }
    @IBAction func takeoff(_ sender: Any) {
        sendall("command")
        sendall("takeoff")
    }
    
    @IBAction func land(_ sender: Any) {
        sendall("land")
    }
    
    @IBAction func flipF(_ sender: Any) {
        sendall("flip b")
    }
    
    @IBAction func cycle(_ sender: Any) {
        send1("go 0 0 150 50 m2")
        send2("go 0 0 100 100 m3")
    }
    
    @IBAction func pos(_ sender: Any) {
        send1("go 0 0 150 50 m1")
        send2("go 0 0 100 50 m2")
    }
    
    func send1(_ s: String){
        guard let client1 = client1 else {return}
        _ = client1.send(string: s)
    }
    
    func send2(_ s: String){
        guard let client2 = client2 else {return}
        _ = client2.send(string: s)
    }
    
    func sendall(_ s: String){
        guard let client1 = client1 else {return}
        _ = client1.send(string: s)
        guard let client2 = client2 else {return}
        _ = client2.send(string: s)
    }
    
    func readData(){
        let queue = DispatchQueue(label: "com.nkust.JA1221")
        
        queue.async {
            while true
            {
                print("test")
                self.receiveData.text = self.receiveData.text ?? "0" + "1"
                let s = self.client2?.recv(100)
                print(s?.0)
                print(s?.1)
                print(s?.2)
            }
        }
    }
    
    @IBAction func cs(_ sender: Any) {
        client2?.close()
    }
    /*func recv(){
        return client?.recv(2)
    }*/
}

