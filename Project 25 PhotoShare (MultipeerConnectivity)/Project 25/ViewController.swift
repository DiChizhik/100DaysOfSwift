//
//  ViewController.swift
//  Project 25
//
//  Created by Diana Chizhik on 27/06/2022.
//
import MultipeerConnectivity
import UIKit

class ViewController: UICollectionViewController {
    var images = [UIImage]()
    
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCNearbyServiceAdvertiser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = "PhotoShare"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showPrompt))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(pickImage))
        
        let showPeersButton = UIBarButtonItem(image: UIImage(systemName: "person.2.circle"), style: .plain, target: self, action: #selector(showPeersTapped))
        let textPeersButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(writePeersTapped))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbarItems = [showPeersButton, spacer, textPeersButton]
        navigationController?.isToolbarHidden = false
    
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }

    @objc func pickImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    @objc func showPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func showPeersTapped() {
        guard let mcSession = mcSession else { return }
        
        if mcSession.connectedPeers.isEmpty {
            showAlert(title: "Connected users", message: "No connected users", actionTitle: "OK")
        } else {
            let peers = mcSession.connectedPeers.map {$0.displayName}
            var peersString = ""
            peers.forEach{peersString.append($0)}
        
            showAlert(title: "Connected users", message: peersString, actionTitle: "OK")
        }
    }
    
    @objc  func writePeersTapped(_ action: UIAlertAction?) {
        let ac = UIAlertController(title: "Write a message", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Send", style: .default) { [weak self, weak ac] _ in
            if let message = ac?.textFields?[0].text {
                if let mcSession = self?.mcSession {
                    if mcSession.connectedPeers.count > 0 {
                        let fullMessage = (self?.peerID.displayName ?? "Unknown user") + ": " + message
                        let messageData = Data(fullMessage.utf8)
                        do {
                            try mcSession.send(messageData, toPeers: mcSession.connectedPeers, with: .reliable)
                        } catch {
                            self?.showAlert(title: "Send error", message: error.localizedDescription, actionTitle: "OK")
                        }
                    }
                }
            } else {
                return
            }
            
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func showAlert(title: String?, message: String?, actionTitle: String ) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionTitle, style: .default))
        present(ac, animated: true)
    }
}

extension ViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(1) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        
        return cell
    }
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        
        images.insert(image, at: 0)
        collectionView.reloadData()
        
        if let mcSession = mcSession {
            if mcSession.connectedPeers.count > 0 {
                if let imageData = image.pngData() {
                    do {
                        try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                    } catch {
                        showAlert(title: "Send error", message: error.localizedDescription, actionTitle: "OK")
                    }
                }
            }
        }
    }
}

extension ViewController: MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate {
    
    private func startHosting(action: UIAlertAction) {
        mcAdvertiserAssistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "hws-project25")
        mcAdvertiserAssistant?.delegate = self
        mcAdvertiserAssistant?.startAdvertisingPeer()
    }
    
    private func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print ("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
            
            DispatchQueue.main.async {
                self.showAlert(title: nil, message: "\(peerID.displayName) left the network", actionTitle: "OK")
            }
           
        @unknown default:
            print("Unknown state received: \(peerID.displayName)")
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        guard mcSession != nil else { return }
        
        let ac = UIAlertController(title: nil, message: "'\(peerID.displayName)' wants to connect", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak self] _ in
                    invitationHandler(true, self?.mcSession)
        }))
        ac.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: { _ in
                    invitationHandler(false, nil)
        }))
        present(ac, animated: true)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data) {
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
            } else if String(decoding: data, as: UTF8.self) != nil {
                let message = String(decoding: data, as: UTF8.self)
                let ac = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Answer", style: .default, handler: self?.writePeersTapped))
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(ac, animated: true)
            }
        }
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}

