//
//  MediaVC.swift
//  Alarm
//
//  Created by pinali gabani on 17/12/23.
//

import UIKit
import MediaPlayer
import AVFoundation
import FittedSheets

protocol MediaDelegate : NSObjectProtocol{
    func media(sound : String)
}

class MediaVC: UIViewController {
    
    @IBOutlet weak var categoryCollection: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recorderView: UIView!
    @IBOutlet weak var recordingsTable: UITableView!
    
    var categoryArr = [String]()
    var ringtoneArr = ringToneArr
    var selectedCellIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var mediaItem: MPMediaItem?
    var mediaLabel: String!
    var mediaID: String!
    var player: AVAudioPlayer?
    var recordings = [URL]()
    var delegate : MediaDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sound"
        categoryArr = ["Default","Recorded"]
        categoryArr.sort()
        listRecordings()
    }

    override func viewDidAppear(_ animated: Bool) {
        select(row: 0)
    }
    
    func play(_ url: URL) {
        print("playing \(url)")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)

            guard let player = player else { return }
            
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }

    @IBAction func recordNewBtnClicked(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "RecorderVC") as! RecorderVC
        let options = SheetOptions(
            useFullScreenMode: false
        )
        let sheetController = SheetViewController(controller: controller,sizes: [.fixed(300)],options: options)
        sheetController.minimumSpaceAbovePullBar = 44
        sheetController.didDismiss = { _ in
            self.listRecordings()
        }
        self.present(sheetController, animated: true, completion: nil)
    }
}
extension MediaVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryCell
        cell.categoryName.text = categoryArr[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        let width = (collectionView.frame.width - 20) / 2
        return CGSize(width: width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        select(row: indexPath.row)
        if indexPath.row == 0{
            tableView.isHidden = false
            recorderView.isHidden = true
        }
        else
        {
            tableView.isHidden = true
            recorderView.isHidden = false
        }
    }
    
    public func select(
        row: Int,
        in section: Int = 0,
        animated: Bool = true
    ) {
        // Ensures selected row isnt more then data count
        guard row < categoryArr.count else { return }
        
        // removes any selected items
        cleanupSelection()
        
        // set new selected item
        let indexPath = IndexPath(row: row, section: section)
        selectedCellIndexPath = indexPath
        
        // Update selected cell
        let cell = categoryCollection.cellForItem(at: indexPath) as? CategoryCell
        cell?.configure(
            with: categoryArr[indexPath.row],
            isSelected: true
        )
        
        categoryCollection.selectItem(
            at: indexPath,
            animated: animated,
            scrollPosition: [])
    }
    
    private func cleanupSelection() {
        let indexPath = selectedCellIndexPath
        let cell = categoryCollection.cellForItem(at: indexPath) as? CategoryCell
        cell?.configure(with: categoryArr[indexPath.row])
        selectedCellIndexPath = IndexPath(row: 0, section: 0)
    }
}
extension MediaVC : UITableViewDelegate , UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == recordingsTable{
            return 1
        }
        else
        {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == recordingsTable{
            return recordings.count
        }
        else
        {
            if section == 0{
                return 1
            }
            else
            {
                return ringtoneArr.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == recordingsTable{
            return nil
        }
        else
        {
            if section == 0 {
                return "Songs"
            }
            else {
                return "Ringtones"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == recordingsTable{
            return 0
        }
        else
        {
            return 40.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == recordingsTable{
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordingCell", for: indexPath) as! RecordingsCell
            let fileName = recordings[indexPath.row].deletingPathExtension().lastPathComponent
            cell.audioName.text = fileName
            cell.actionBtn.tag = indexPath.row
            cell.actionBtn.addTarget(self, action: #selector(actionBtnClicked), for: .touchUpInside)
            return cell
        }
        else
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "musicCell")
            if(cell == nil) {
                cell = UITableViewCell(
                    style: UITableViewCell.CellStyle.default, reuseIdentifier: "musicCell")
            }
            
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    cell!.textLabel!.text = "Pick a song"
                    cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                }
            }
            else{
                cell?.textLabel?.text = ringtoneArr[indexPath.row]
                if cell!.textLabel!.text == mediaLabel {
                    cell!.accessoryType = UITableViewCell.AccessoryType.checkmark
                }
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == recordingsTable{
            play(recordings[indexPath.row])
            mediaLabel = recordings[indexPath.row].deletingPathExtension().lastPathComponent
            delegate?.media(sound: mediaLabel)
        }
        else
        {
            let mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.anyAudio)
            mediaPicker.delegate = self
            mediaPicker.prompt = "Select any song!"
            mediaPicker.allowsPickingMultipleItems = false
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    self.present(mediaPicker, animated: true, completion: nil)
                }
            }
            else
            {
                let cell = tableView.cellForRow(at: indexPath)!
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                mediaLabel = cell.textLabel?.text!
                delegate?.media(sound: mediaLabel)
                cell.setSelected(true, animated: true)
                cell.setSelected(false, animated: true)
                let cells = tableView.visibleCells
                for c in cells {
                    let section = tableView.indexPath(for: c)?.section
                    if (section == indexPath.section && c != cell) {
                        c.accessoryType = UITableViewCell.AccessoryType.none
                    }
                }
                
                playSound(sound: self.ringtoneArr[indexPath.row])
            }
        }
    }
    
    @objc func actionBtnClicked(_ sender : UIButton){
        let recording = self.recordings[sender.tag]
        let actionSheet = UIAlertController(title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Rename", style: .default, handler: {_ in
            
            let alert = UIAlertController(title: "Rename filename",
                message: nil,
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: {
                [unowned alert] _ in
                
                if let textFields = alert.textFields {
                    let tfa = textFields as [UITextField]
                    let text = tfa[0].text
                    let url = URL(fileURLWithPath: text!).deletingPathExtension().appendingPathExtension("m4a")
                    self.renameRecording(recording, to: url)
                    
                    DispatchQueue.main.async {
                        self.listRecordings()
                        self.recordingsTable.reloadData()
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {_ in
            }))
            alert.addTextField(configurationHandler: {textfield in
                textfield.placeholder = "filename"
                textfield.text = "\(recording.lastPathComponent)"
            })
            self.present(alert, animated: true, completion: nil)
    
        }))
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
            self.askToDelete(sender.tag)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func playSound(sound : String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let player = player else { return }
            
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}
extension MediaVC : MPMediaPickerControllerDelegate{
   
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems  mediaItemCollection:MPMediaItemCollection) -> Void {
        if !mediaItemCollection.items.isEmpty {
            let aMediaItem = mediaItemCollection.items[0]
        
            self.mediaItem = aMediaItem
            mediaID = (self.mediaItem?.value(forProperty: MPMediaItemPropertyPersistentID)) as? String
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension MediaVC{
    func listRecordings() {
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectory,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            self.recordings = urls.filter({ (name: URL) -> Bool in
                return name.pathExtension == "m4a"
            })
            
            recordingsTable.reloadData()
            
        } catch {
            print(error.localizedDescription)
            print("something went wrong listing recordings")
        }
    }
    
    func renameRecording(_ from: URL, to: URL) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let toURL = documentsDirectory.appendingPathComponent(to.lastPathComponent)
        
        print("renaming file \(from.absoluteString) to \(to) url \(toURL)")
        let fileManager = FileManager.default
        fileManager.delegate = self
        do {
            try FileManager.default.moveItem(at: from, to: toURL)
        } catch {
            print(error.localizedDescription)
            print("error renaming recording")
        }
    }
    
    func askToDelete(_ row: Int) {
        let alert = UIAlertController(title: "Delete",
            message: "Delete Recording \(recordings[row].lastPathComponent)?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            print("yes was tapped \(self.recordings[row])")
            self.deleteRecording(self.recordings[row])
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in
            print("no was tapped")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteRecording(_ url: URL) {
        
        print("removing file at \(url.absoluteString)")
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print(error.localizedDescription)
            print("error deleting recording")
        }
        
        DispatchQueue.main.async {
            self.listRecordings()
            self.recordingsTable.reloadData()
        }
    }
}
extension MediaVC: FileManagerDelegate {

    func fileManager(_ fileManager: FileManager, shouldMoveItemAt srcURL: URL, to dstURL: URL) -> Bool {

        print("should move \(srcURL) to \(dstURL)")
        return true
    }
}
