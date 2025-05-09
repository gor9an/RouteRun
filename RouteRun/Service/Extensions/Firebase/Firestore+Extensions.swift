//
//  Firestore+Extensions.swift
//  RouteRun
//
//  Created by Andrei Gordienko on 09.05.2025.
//

import FirebaseFirestore

extension Firestore {
    func collection<T: Decodable>(_ collection: CollectionReference, as type: T.Type) async throws -> [T] {
        let snapshot = try await collection.getDocuments()

        return try snapshot.documents.map { document in
            try document.data(as: type)
        }
    }
}

extension DocumentReference {
    func setData<T: Encodable>(from value: T) throws {
        let data = try Firestore.Encoder().encode(value)
        setData(data)
    }
}
