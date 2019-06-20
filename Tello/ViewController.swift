import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sendData: UITextField!
    @IBOutlet weak var receiveData: UILabel!
    
    //設定 IP Port , 指定UDP連線
    let host = "192.168.10.1"
    let port = 8889
    var client: UDPClient?
    var server: UDPServer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client = UDPClient(address: host, port: Int32(port))//建立 UDP 連線
        server = UDPServer(address: "0.0.0.0", port: 8890)
    }

    @IBAction func onClick(_ sender: Any) {
        //guard let client = client else { return }
        
        if let text = sendData.text{
            send( text)//傳送 textView文字指令
            sendData.text = ""//清空
            let s = server?.recv(5)
            print(s!.0)
            print(s!.1)
            print(s!.2)
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
}

