//
//  Spot.swift
//  Snacktacular
//
//  Created by Alice Liang on 3/31/19.
//  Copyright © 2019 Alice Liang. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class Spot {
    var name: String
    var address: String
    var coordinates: CLLocationCoordinate2D
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    
    var longitude: CLLocationDegrees {
        return coordinates.longitude
    }
    var latitude: CLLocationDegrees {
        return coordinates.latitude
    }
    
    var dictionary: [String: Any] {
        return["name":name, "address":address, "longitude": longitude, "latitude": latitude, "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID":postingUserID]
    }
    init(name: String, address: String, coordinates: CLLocationCoordinate2D, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String) {
        self.name = name
        self.address = address
        self.coordinates = coordinates
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(name: "", address: "", coordinates: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    
    func saveData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        //GRAB USER ID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("*** ERROR: could not save data because we don't have a valid postingUserID")
            return completed(false)
        }
        self.postingUserID = postingUserID
        //create dictionary representing the data we want to save
        let dataToSave = self.dictionary
        //if we HAVE saved a record, we'll have a documentID
        if self.documentID != "" {
            let ref = db.collection("spots").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("**** ERROR: updating document \(self.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ Document updated with ref ID \(ref.documentID)")
                    completed(true)
                }
            }
        } else {
            var ref: DocumentReference? = nil //  let firestore create the new documentID
            ref = db.collection("spots").addDocument(data: dataToSave) { error in
                if let error = error {
                    print("**** ERROR: creating new document \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ new document created with ref ID \(ref?.documentID ?? "unknown")")
                    completed(true)
                }
            }
        }
    }
}
