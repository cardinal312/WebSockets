//
//  ViewController.swift
//  WebSockets
//
//  Created by Macbook on 8/9/24.
//

import UIKit

final class ViewController: UIViewController, URLSessionWebSocketDelegate {
    
    private var webSocket: URLSessionWebSocketTask?

    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = "Web Socket Test"
        view.backgroundColor = .yellow
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        guard let url = URL(string: "wss://echo.websocket.org") else { return }
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        
    }
    
    private func ping() {
        webSocket?.sendPing { error in
            if let error = error {
                print("DEBUG: - PING ERROR --> \(error)")
            }
        }
    }
    
    private func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
    
    private func send() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.send()
            self?.webSocket?.send(.string("Send new message - \(Int.random(in: 0..<999))"), completionHandler: { error in
                if let error = error {
                    print("Send error - \(error)")
                }
            })
        }
    }
    
    private func receive() {
        webSocket?.receive { [weak self] results in
            guard let self else { return }
            switch results {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Data - \(data)")
                case .string(let string):
                    print("Got string - \(string)")
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive error - \(error)")
            }
            receive()
        }
    }

    // MARK: - WEB SOCKET METHODS
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did connect to socket")
        self.ping()
        self.receive()
        self.send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close connection with reason")
    }

}

