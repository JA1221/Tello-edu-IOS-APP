import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sendData: UITextField!
    @IBOutlet weak var receiveData: UILabel!
    
    let serverIP = "192.168"
    let serverPort = 8787
    //設定 IP Port , 指定UDP連線
    let host = "192.168.43.103"
    let port = 8889
    var client: UDPClient?
    var server: UDPServer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client = UDPClient(address: host, port: Int32(port),myAddresss: serverIP, myPort: Int32(serverPort))//建立 UDP 連線
        server = UDPServer(address: "0.0.0.0", port: 8890)
        
        readData()
    }

    @IBAction func onClick(_ sender: Any) {
        guard let client = client else { return }
        
        if let text = sendData.text{
            send( text)//傳送 textView文字指令
            sendData.text = ""//清空
            let s = client.recv(10)
            print(s.0)
            print(s.1)
            print(s.2)
        }
    }
    @IBAction func takeoff(_ sender: Any) {
        send("command")
        send("takeoff")
    }
    
    @IBAction func land(_ sender: Any) {
        send("land")
    }
    
    @IBAction func flipF(_ sender: Any) {
        send("flip f");
    }
    
    func send(_ s: String){
        guard let client = client else {return}
        _ = client.send(string: s)
    }
    
    func readData(){
        let queue = DispatchQueue(label: "com.nkust.JA1221")
        
        queue.async {
            while true
            {
                guard let client = self.client else { return }
                
                print("test")
                self.receiveData.text = self.receiveData.text ?? "0" + "1"
                let s = client.recv(10)
                print(s.0)
                print(s.1)
                print(s.2)
            }
        }
    }
}

