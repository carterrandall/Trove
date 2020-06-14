//
//  ViewController.swift
//  Trove
//
//  Created by Carter Randall on 2020-05-31.
//  Copyright © 2020 Carter Randall. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import FirebaseStorage
import Firebase
import Geofirestore
import MapKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, CLLocationManagerDelegate, CollectionViewDelegate, EditSendNoteViewDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var collectionView: CollectionView!
    var editSendView: EditSendNoteView!
    var sessionInfoView: SessionInfoView!
    
    var editSendBottomAnchor: NSLayoutConstraint!
    var locationManager: CLLocationManager!
    
    var isRelocalizingMap = false
    var isCreatingNote: Bool = false

    override var shouldAutorotate: Bool {
        return false
    }
    
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        return configuration
    }
    
    var virtualObjectAnchor: ARAnchor?
    let virtualObjectAnchorName = "virtualObject"

    var virtualObject: SCNNode?
    
    
    let newNoteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(named: "add"), for: .normal)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sessionInfoView = SessionInfoView()
        view.addSubview(sessionInfoView)
        sessionInfoView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 250, height: 100)
        sessionInfoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.sessionInfoView.isHidden = true
        
        collectionView = CollectionView()
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -20, paddingRight: 0, width: 0, height: 200 * (4/3))
        
        view.addSubview(newNoteButton)
        newNoteButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 16, width: 40, height: 40)
        newNoteButton.addTarget(self, action: #selector(handleNewNote), for: .touchUpInside)
        
        
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            print("no location enabled, request location")
        }
        
        fetchNotesNearby()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sceneView.session.delegate = self
        sceneView.delegate = self
        sceneView.session.run(defaultConfiguration)
        sceneView.debugOptions = [.showFeaturePoints]
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
    @objc fileprivate func handleNewNote() {
        print("worldmaps stores", maps.count)
    
        if isCreatingNote {
            leaveNewNote()
            collectionView.callDelegate(index: collectionView.selectedIndex)
        } else {
            newNoteButton.setImage(UIImage(named: "close"), for: .normal)
//          sceneView.session.run(defaultConfiguration)
           
            resetTracking(nil)
            isCreatingNote = true
            collectionView.isHidden = true
            self.sessionInfoView.isHidden = false
            self.sessionInfoView.label.text = "Look around and tap where you want to place a note."
            if editSendView != nil {
                
            } else {
                editSendView = EditSendNoteView()
                editSendView.delegate = self
                view.addSubview(editSendView)
                editSendView.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 60)
                editSendBottomAnchor = editSendView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
                editSendBottomAnchor.isActive = true

                
            }
            editSendView.noteField.becomeFirstResponder()
            editSendView.isHidden = false
            editSendView.saveNoteButton.isEnabled = false

        }
        
    }
    
    func leaveNewNote() {
        editSendView.isHidden = true
        collectionView.isHidden = false
        isCreatingNote = false
        self.sessionInfoView.isHidden = true
        editSendView.saveNoteButton.setTitle("Save", for: [])
        editSendView.saveNoteButton.isEnabled = true
        editSendView.noteField.isUserInteractionEnabled = true
        newNoteButton.setImage(UIImage(named: "add"), for: .normal)
        editSendView.noteField.resignFirstResponder()
    }
    //delegate method
    func saveNote() {
        handleSaveNote()
    }
    
    @objc fileprivate func handleSaveNote() {
        
        editSendView.saveNoteButton.isEnabled = false
        
        locationManager.requestLocation()
        
        sceneView.session.getCurrentWorldMap { (worldMap, err) in
            guard let map = worldMap else {
                print("show alert. Failed to get world map", err!.localizedDescription)
                self.editSendView.saveNoteButton.isEnabled = true
                return 
            }
            
            guard let note = self.editSendView.text else { return }
            
            guard let snapshotAnchor = SnapshotAnchor(capturing: self.sceneView)
                else {
                    print("failed to get snapshot, please try again")
                    self.editSendView.saveNoteButton.isEnabled = true
                    return }
            map.anchors.append(snapshotAnchor)
            
            do { //fetch here
                let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                
                let storage = Storage.storage()
                let uuid = UUID().uuidString
                let storageRef = storage.reference().child("maps/" + uuid)
                let _ = storageRef.putData(data, metadata: nil) { (meta, err) in
                    if let err = err {
                        print(err, "Failed to upload to storage")
                        self.editSendView.saveNoteButton.isEnabled = true
                        return
                    }
                    if let metadata = meta {
                        print ("Successfully uploaded map with size:", metadata.size)
                    }
                    
                    storageRef.downloadURL { (url, err) in
                        
                        guard let dlurl = url?.absoluteString else { print("failed to get dl url"); return }
                        guard let location = self.locationManager.location?.coordinate else {print("failed to get current location"); return }
                        
                        let db = Firestore.firestore()
//                        let settings = db.settings
//                        settings.areTimestampsInSnapshotsEnabled = true
//                        db.settings = settings
                        
                        var ref: DocumentReference? = nil
                        let d = ["url": dlurl, "time": Date().timeIntervalSince1970, "note": note] as [String : Any]
                        ref = db.collection("maps").addDocument(data: d, completion: { (err) in
                            if let err = err {
                                print(err, "Error adding document")
                                self.editSendView.saveNoteButton.isEnabled = true
                                return
                            } else {
                                print("added document with id: \(ref?.documentID ?? "no id")")
                            }
                            
                            guard let id = ref?.documentID else {print("no document ID returnd"); return}
                            
                            let geoFirestoreRef = Firestore.firestore().collection("maps")
                            let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
//                            geoFirestore.setL
                            geoFirestore.setLocation(location: CLLocation(latitude: location.latitude, longitude: location.longitude), forDocumentWithID: id) { (err) in
                                if let err = err {
                                    print("Failed to set location on document!", err)
                                    
                                    return
                                } else {
                                    print("Successfully set location on document with id \(id)")
                                }
                                self.leaveNewNote()
                            }
                        })
                        
                        
                    }
                }
                       
            } catch {
                self.editSendView.saveNoteButton.isEnabled = true
                print("Can't save map: \(error.localizedDescription)")
                return
               
            }
        }
        
    }
    
    
    var maps = [Map]()
    func fetchNotesNearby() {
        print("fetching notes nearby...")
        locationManager.requestLocation()
        guard let location = locationManager.location?.coordinate else {print("Failed to get location"); return }
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001) //about 100m span
        let region = MKCoordinateRegion(center: location, span: span)
        let geoFirestoreRef = Firestore.firestore().collection("maps")
        let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        let ref = Firestore.firestore()
        let regionQuery = geoFirestore.query(inRegion: region)
        
            regionQuery.observe(.documentEntered) { (key ,location) in
                print(key as Any, location as Any, "FIND STUFF!")
                guard let key = key else { return }
                
                ref.collection("maps").document(key).getDocument { (document, err) in
    
                    if let err = err {
                        print("Failed to get data", err)
                        return
                    }
                    
                    if let document = document, document.exists {
                        if let data = document.data() {
                            
                            var mapDict = [String: Any]()
                     
                            mapDict["note"] = data["note"] ?? "No note!"
                            mapDict["date"] = data["time"] ?? 0
                            guard let url = data["url"] as? String else { print("Failed to cast as Url"); return }
                            
                            let request = URLRequest(url: URL(string: url)!)
    
    
                            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                                if let response = data {
                                    DispatchQueue.main.async {
                                        do {
                                            
                                            guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: response) else {print("failed to save world map"); return}
                                             
                                            print("Got world map")
                                            
                                            
                                            if let snapshotData = worldMap.snapshotAnchor?.imageData,
                                                let snapshot = UIImage(data: snapshotData) {
                                                mapDict["snapshot"] = snapshot
                                            } else {
                                                print("No snapshot image in world map")
                                                return
                                            }
                                            
                                            worldMap.anchors.removeAll(where: { $0 is SnapshotAnchor })//remove snapshot anchor from world map
                                            mapDict["worldMap"] = worldMap //then append it
                                            
                                            self.maps.append(Map(dictionary: mapDict))
                                            DispatchQueue.main.async {
                                                self.collectionView.maps = self.maps
                                            }
                                            
      
                                        } catch {
                                            print("didint work! fetch location")
                                        }
                                    }} else {
                                    print("failed to getch data")
                                }
                            }).resume()
    
                        }
                    }
    
                }
        
        }
    }
    
    func didSelectMap(map: ARWorldMap) {
        print("DID SELECT MAP")
        //load map
        let configuration = self.defaultConfiguration // this app's standard world tracking settings
        configuration.initialWorldMap = map
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        self.isRelocalizingMap = true
        self.virtualObjectAnchor = nil
        self.sessionInfoView.label.text = "Point the camera at the pictured area to reveal the hidden message."
        self.sessionInfoView.isHidden = false
        
        print("display to user: Note loaded! Look around to find the message")
        
    }
    
    
    @IBAction func handleScreenTap(_ sender: UITapGestureRecognizer) {
        
        if !isCreatingNote { return }
        if !(self.editSendView.text != nil) {
            self.sessionInfoView.label.text = "Enter text for a note first"
            print("no note entered! ")
            return
        }
        
        if !(self.editSendView.text!.count > 0) {
            self.sessionInfoView.label.text = "Enter text for a note first"
            print("text length 0")
            return
        }
        
        editSendView.noteField.resignFirstResponder()
        
        if (isRelocalizingMap && virtualObjectAnchor == nil) {
            print("object nil or relocalizing", isRelocalizingMap)
            return
            
        }
        
        guard let hitTestResult = sceneView.hitTest(sender.location(in: sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane]).first else {print("Failed hit test"); return }
          
          if let existingAnchor = virtualObjectAnchor {
              print("2 removing existing anchor")
              sceneView.session.remove(anchor: existingAnchor)
          }
          
          virtualObjectAnchor = ARAnchor(name: virtualObjectAnchorName, transform: hitTestResult.worldTransform)
        
          sceneView.session.add(anchor: virtualObjectAnchor!)
         
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
       
        guard anchor.name == virtualObjectAnchorName
            else {print("anchor name not a match"); return }

        // save the reference to the virtual object anchor when the anchor is added from relocalizing
        if virtualObjectAnchor == nil {
            virtualObjectAnchor = anchor
        }
        
//      guard let note = self.editSendView.text else { return }
        var note: String!
        if isCreatingNote {
            note = self.editSendView.text ?? "cmv"
        } else if self.maps.count > 0 {
            note = maps[self.collectionView.selectedIndex].note
            DispatchQueue.main.async {
                self.sessionInfoView.isHidden = true
                self.sessionInfoView.label.text = ""
            }
            
        } else {
            note = "basic"
        }
        
        print("DID ADD NODE", note)
        let text = SCNText(string: note, extrusionDepth: 2)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.mainGold()
        text.materials = [material]
        self.virtualObject = SCNNode()
        self.virtualObject!.scale = SCNVector3(0.01, 0.01, 0.01)
        self.virtualObject!.geometry = text
        
        
        node.addChildNode(self.virtualObject!)
        
    }
    
    //MARK: LOCATION MANAGER
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager failed to get a location:", error)
    }
    
    //MARK: KEYBOARD NOTIFICATIONS
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.editSendBottomAnchor.constant == 0 {
                self.editSendBottomAnchor.constant -= keyboardSize.height
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.2) {
                        self.view.layoutIfNeeded()
                    }
                   
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.editSendBottomAnchor.constant != 0 {
            self.editSendBottomAnchor.constant = 0
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: SESSION INFO
  private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
    if !isCreatingNote { return }
    if self.editSendView != nil && isCreatingNote {
        if let txt = self.editSendView.text {
            if txt.count == 0 { return }
            
        } else {
            return
        }
    }
        
        let message: String
    
        switch (trackingState, frame.worldMappingStatus) {
        case (.normal, .mapped),
             (.normal, .extending):
            if frame.anchors.contains(where: { $0.name == virtualObjectAnchorName }) {
                // User has placed an object in scene and the session is mapped, prompt them to save the experience
                message = "Tap 'Save Experience' to save the current map."
            } else {
                message = "Tap on the screen to place an object."
            }
            
//        case (.normal, _) where mapDataFromFile != nil && !isRelocalizingMap:
//            message = "Move around to map the environment or tap 'Load Experience' to load a saved experience."
//
//        case (.normal, _) where mapDataFromFile == nil:
//            message = "Move around to map the environment."
//
        case (.limited(.relocalizing), _) where isRelocalizingMap:
            message = "Move your device to the location shown in the image."
            
            
        default:
            message = trackingState.localizedFeedback
        }
        
        sessionInfoView.label.text = message
        sessionInfoView.label.isHidden = message.isEmpty
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    

    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoView.label.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoView.label.text = "Session interruption ended"
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        sessionInfoView.label.text = "Session failed: \(error.localizedDescription)"
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.resetTracking(nil)
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
           if isCreatingNote {
               switch frame.worldMappingStatus {
               case .extending, .mapped:
                   editSendView.saveNoteButton.isEnabled = virtualObjectAnchor != nil && frame.anchors.contains(virtualObjectAnchor!)
                   if editSendView.saveNoteButton.isEnabled {
                    self.sessionInfoView.label.text = "Sufficient map! Ready to save note!"
                   } else {
                    self.sessionInfoView.label.text = "Move around to map the environment."
                }
               default:
                   editSendView.saveNoteButton.isEnabled = false
                   self.sessionInfoView.label.text = "Move around to map the environment."
               }
           }
       }
       
       func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
           return true
       }
    
    func resetTracking(_ sender: UIButton?) {
        sceneView.session.run(defaultConfiguration, options: [.resetTracking, .removeExistingAnchors])
        isRelocalizingMap = false
        virtualObjectAnchor = nil
    }

}

