//  This file was automatically generated and should not be edited.

import AWSAppSync

public struct CreateAlbumInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, username: String, name: String, accesstype: String) {
    graphQLMap = ["id": id, "username": username, "name": name, "accesstype": accesstype]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var username: String {
    get {
      return graphQLMap["username"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var accesstype: String {
    get {
      return graphQLMap["accesstype"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "accesstype")
    }
  }
}

public struct UpdateAlbumInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, username: String? = nil, name: String? = nil, accesstype: String? = nil) {
    graphQLMap = ["id": id, "username": username, "name": name, "accesstype": accesstype]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var username: String? {
    get {
      return graphQLMap["username"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }

  public var name: String? {
    get {
      return graphQLMap["name"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var accesstype: String? {
    get {
      return graphQLMap["accesstype"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "accesstype")
    }
  }
}

public struct DeleteAlbumInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct CreatePhotoInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil, name: String, bucket: String, key: String, photoAlbumId: GraphQLID? = nil) {
    graphQLMap = ["id": id, "name": name, "bucket": bucket, "key": key, "photoAlbumId": photoAlbumId]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var bucket: String {
    get {
      return graphQLMap["bucket"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bucket")
    }
  }

  public var key: String {
    get {
      return graphQLMap["key"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "key")
    }
  }

  public var photoAlbumId: GraphQLID? {
    get {
      return graphQLMap["photoAlbumId"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "photoAlbumId")
    }
  }
}

public struct UpdatePhotoInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID, name: String? = nil, bucket: String? = nil, key: String? = nil, photoAlbumId: GraphQLID? = nil) {
    graphQLMap = ["id": id, "name": name, "bucket": bucket, "key": key, "photoAlbumId": photoAlbumId]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: String? {
    get {
      return graphQLMap["name"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var bucket: String? {
    get {
      return graphQLMap["bucket"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bucket")
    }
  }

  public var key: String? {
    get {
      return graphQLMap["key"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "key")
    }
  }

  public var photoAlbumId: GraphQLID? {
    get {
      return graphQLMap["photoAlbumId"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "photoAlbumId")
    }
  }
}

public struct DeletePhotoInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID? = nil) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID? {
    get {
      return graphQLMap["id"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct ModelAlbumFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDFilterInput? = nil, username: ModelStringFilterInput? = nil, name: ModelStringFilterInput? = nil, accesstype: ModelStringFilterInput? = nil, and: [ModelAlbumFilterInput?]? = nil, or: [ModelAlbumFilterInput?]? = nil, not: ModelAlbumFilterInput? = nil) {
    graphQLMap = ["id": id, "username": username, "name": name, "accesstype": accesstype, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDFilterInput? {
    get {
      return graphQLMap["id"] as! ModelIDFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var username: ModelStringFilterInput? {
    get {
      return graphQLMap["username"] as! ModelStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }

  public var name: ModelStringFilterInput? {
    get {
      return graphQLMap["name"] as! ModelStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var accesstype: ModelStringFilterInput? {
    get {
      return graphQLMap["accesstype"] as! ModelStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "accesstype")
    }
  }

  public var and: [ModelAlbumFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelAlbumFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelAlbumFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelAlbumFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelAlbumFilterInput? {
    get {
      return graphQLMap["not"] as! ModelAlbumFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public struct ModelIDFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: GraphQLID? = nil, eq: GraphQLID? = nil, le: GraphQLID? = nil, lt: GraphQLID? = nil, ge: GraphQLID? = nil, gt: GraphQLID? = nil, contains: GraphQLID? = nil, notContains: GraphQLID? = nil, between: [GraphQLID?]? = nil, beginsWith: GraphQLID? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith]
  }

  public var ne: GraphQLID? {
    get {
      return graphQLMap["ne"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: GraphQLID? {
    get {
      return graphQLMap["eq"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: GraphQLID? {
    get {
      return graphQLMap["le"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: GraphQLID? {
    get {
      return graphQLMap["lt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: GraphQLID? {
    get {
      return graphQLMap["ge"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: GraphQLID? {
    get {
      return graphQLMap["gt"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: GraphQLID? {
    get {
      return graphQLMap["contains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: GraphQLID? {
    get {
      return graphQLMap["notContains"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [GraphQLID?]? {
    get {
      return graphQLMap["between"] as! [GraphQLID?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: GraphQLID? {
    get {
      return graphQLMap["beginsWith"] as! GraphQLID?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }
}

public struct ModelStringFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ne: String? = nil, eq: String? = nil, le: String? = nil, lt: String? = nil, ge: String? = nil, gt: String? = nil, contains: String? = nil, notContains: String? = nil, between: [String?]? = nil, beginsWith: String? = nil) {
    graphQLMap = ["ne": ne, "eq": eq, "le": le, "lt": lt, "ge": ge, "gt": gt, "contains": contains, "notContains": notContains, "between": between, "beginsWith": beginsWith]
  }

  public var ne: String? {
    get {
      return graphQLMap["ne"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ne")
    }
  }

  public var eq: String? {
    get {
      return graphQLMap["eq"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "eq")
    }
  }

  public var le: String? {
    get {
      return graphQLMap["le"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "le")
    }
  }

  public var lt: String? {
    get {
      return graphQLMap["lt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lt")
    }
  }

  public var ge: String? {
    get {
      return graphQLMap["ge"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ge")
    }
  }

  public var gt: String? {
    get {
      return graphQLMap["gt"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "gt")
    }
  }

  public var contains: String? {
    get {
      return graphQLMap["contains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contains")
    }
  }

  public var notContains: String? {
    get {
      return graphQLMap["notContains"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notContains")
    }
  }

  public var between: [String?]? {
    get {
      return graphQLMap["between"] as! [String?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "between")
    }
  }

  public var beginsWith: String? {
    get {
      return graphQLMap["beginsWith"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "beginsWith")
    }
  }
}

public struct ModelPhotoFilterInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: ModelIDFilterInput? = nil, name: ModelStringFilterInput? = nil, bucket: ModelStringFilterInput? = nil, key: ModelStringFilterInput? = nil, and: [ModelPhotoFilterInput?]? = nil, or: [ModelPhotoFilterInput?]? = nil, not: ModelPhotoFilterInput? = nil) {
    graphQLMap = ["id": id, "name": name, "bucket": bucket, "key": key, "and": and, "or": or, "not": not]
  }

  public var id: ModelIDFilterInput? {
    get {
      return graphQLMap["id"] as! ModelIDFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var name: ModelStringFilterInput? {
    get {
      return graphQLMap["name"] as! ModelStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var bucket: ModelStringFilterInput? {
    get {
      return graphQLMap["bucket"] as! ModelStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bucket")
    }
  }

  public var key: ModelStringFilterInput? {
    get {
      return graphQLMap["key"] as! ModelStringFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "key")
    }
  }

  public var and: [ModelPhotoFilterInput?]? {
    get {
      return graphQLMap["and"] as! [ModelPhotoFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "and")
    }
  }

  public var or: [ModelPhotoFilterInput?]? {
    get {
      return graphQLMap["or"] as! [ModelPhotoFilterInput?]?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "or")
    }
  }

  public var not: ModelPhotoFilterInput? {
    get {
      return graphQLMap["not"] as! ModelPhotoFilterInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "not")
    }
  }
}

public final class CreateAlbumMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreateAlbum($input: CreateAlbumInput!) {\n  createAlbum(input: $input) {\n    __typename\n    id\n    username\n    name\n    accesstype\n    photos {\n      __typename\n      items {\n        __typename\n        id\n        name\n        bucket\n        key\n      }\n      nextToken\n    }\n  }\n}"

  public var input: CreateAlbumInput

  public init(input: CreateAlbumInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createAlbum", arguments: ["input": GraphQLVariable("input")], type: .object(CreateAlbum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createAlbum: CreateAlbum? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createAlbum": createAlbum.flatMap { $0.snapshot }])
    }

    public var createAlbum: CreateAlbum? {
      get {
        return (snapshot["createAlbum"] as? Snapshot).flatMap { CreateAlbum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createAlbum")
      }
    }

    public struct CreateAlbum: GraphQLSelectionSet {
      public static let possibleTypes = ["Album"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
        GraphQLField("photos", type: .object(Photo.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
        self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var accesstype: String {
        get {
          return snapshot["accesstype"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "accesstype")
        }
      }

      public var photos: Photo? {
        get {
          return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "photos")
        }
      }

      public struct Photo: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelPhotoConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("items", type: .list(.object(Item.selections))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(items: [Item?]? = nil, nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelPhotoConnection", "items": items.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var items: [Item?]? {
          get {
            return (snapshot["items"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Item(snapshot: $0) } } }
          }
          set {
            snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "items")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }

        public struct Item: GraphQLSelectionSet {
          public static let possibleTypes = ["Photo"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
            GraphQLField("key", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(id: GraphQLID, name: String, bucket: String, key: String) {
            self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return snapshot["id"]! as! GraphQLID
            }
            set {
              snapshot.updateValue(newValue, forKey: "id")
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var bucket: String {
            get {
              return snapshot["bucket"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "bucket")
            }
          }

          public var key: String {
            get {
              return snapshot["key"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "key")
            }
          }
        }
      }
    }
  }
}

public final class UpdateAlbumMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateAlbum($input: UpdateAlbumInput!) {\n  updateAlbum(input: $input) {\n    __typename\n    id\n    username\n    name\n    accesstype\n    photos {\n      __typename\n      items {\n        __typename\n        id\n        name\n        bucket\n        key\n      }\n      nextToken\n    }\n  }\n}"

  public var input: UpdateAlbumInput

  public init(input: UpdateAlbumInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateAlbum", arguments: ["input": GraphQLVariable("input")], type: .object(UpdateAlbum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateAlbum: UpdateAlbum? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateAlbum": updateAlbum.flatMap { $0.snapshot }])
    }

    public var updateAlbum: UpdateAlbum? {
      get {
        return (snapshot["updateAlbum"] as? Snapshot).flatMap { UpdateAlbum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updateAlbum")
      }
    }

    public struct UpdateAlbum: GraphQLSelectionSet {
      public static let possibleTypes = ["Album"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
        GraphQLField("photos", type: .object(Photo.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
        self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var accesstype: String {
        get {
          return snapshot["accesstype"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "accesstype")
        }
      }

      public var photos: Photo? {
        get {
          return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "photos")
        }
      }

      public struct Photo: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelPhotoConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("items", type: .list(.object(Item.selections))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(items: [Item?]? = nil, nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelPhotoConnection", "items": items.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var items: [Item?]? {
          get {
            return (snapshot["items"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Item(snapshot: $0) } } }
          }
          set {
            snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "items")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }

        public struct Item: GraphQLSelectionSet {
          public static let possibleTypes = ["Photo"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
            GraphQLField("key", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(id: GraphQLID, name: String, bucket: String, key: String) {
            self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return snapshot["id"]! as! GraphQLID
            }
            set {
              snapshot.updateValue(newValue, forKey: "id")
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var bucket: String {
            get {
              return snapshot["bucket"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "bucket")
            }
          }

          public var key: String {
            get {
              return snapshot["key"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "key")
            }
          }
        }
      }
    }
  }
}

public final class DeleteAlbumMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteAlbum($input: DeleteAlbumInput!) {\n  deleteAlbum(input: $input) {\n    __typename\n    id\n    username\n    name\n    accesstype\n    photos {\n      __typename\n      items {\n        __typename\n        id\n        name\n        bucket\n        key\n      }\n      nextToken\n    }\n  }\n}"

  public var input: DeleteAlbumInput

  public init(input: DeleteAlbumInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteAlbum", arguments: ["input": GraphQLVariable("input")], type: .object(DeleteAlbum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteAlbum: DeleteAlbum? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteAlbum": deleteAlbum.flatMap { $0.snapshot }])
    }

    public var deleteAlbum: DeleteAlbum? {
      get {
        return (snapshot["deleteAlbum"] as? Snapshot).flatMap { DeleteAlbum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteAlbum")
      }
    }

    public struct DeleteAlbum: GraphQLSelectionSet {
      public static let possibleTypes = ["Album"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
        GraphQLField("photos", type: .object(Photo.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
        self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var accesstype: String {
        get {
          return snapshot["accesstype"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "accesstype")
        }
      }

      public var photos: Photo? {
        get {
          return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "photos")
        }
      }

      public struct Photo: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelPhotoConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("items", type: .list(.object(Item.selections))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(items: [Item?]? = nil, nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelPhotoConnection", "items": items.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var items: [Item?]? {
          get {
            return (snapshot["items"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Item(snapshot: $0) } } }
          }
          set {
            snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "items")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }

        public struct Item: GraphQLSelectionSet {
          public static let possibleTypes = ["Photo"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
            GraphQLField("key", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(id: GraphQLID, name: String, bucket: String, key: String) {
            self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return snapshot["id"]! as! GraphQLID
            }
            set {
              snapshot.updateValue(newValue, forKey: "id")
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var bucket: String {
            get {
              return snapshot["bucket"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "bucket")
            }
          }

          public var key: String {
            get {
              return snapshot["key"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "key")
            }
          }
        }
      }
    }
  }
}

public final class CreatePhotoMutation: GraphQLMutation {
  public static let operationString =
    "mutation CreatePhoto($input: CreatePhotoInput!) {\n  createPhoto(input: $input) {\n    __typename\n    id\n    name\n    bucket\n    key\n    album {\n      __typename\n      id\n      username\n      name\n      accesstype\n      photos {\n        __typename\n        nextToken\n      }\n    }\n  }\n}"

  public var input: CreatePhotoInput

  public init(input: CreatePhotoInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createPhoto", arguments: ["input": GraphQLVariable("input")], type: .object(CreatePhoto.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(createPhoto: CreatePhoto? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "createPhoto": createPhoto.flatMap { $0.snapshot }])
    }

    public var createPhoto: CreatePhoto? {
      get {
        return (snapshot["createPhoto"] as? Snapshot).flatMap { CreatePhoto(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "createPhoto")
      }
    }

    public struct CreatePhoto: GraphQLSelectionSet {
      public static let possibleTypes = ["Photo"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(String.self))),
        GraphQLField("album", type: .object(Album.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, bucket: String, key: String, album: Album? = nil) {
        self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key, "album": album.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var bucket: String {
        get {
          return snapshot["bucket"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bucket")
        }
      }

      public var key: String {
        get {
          return snapshot["key"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var album: Album? {
        get {
          return (snapshot["album"] as? Snapshot).flatMap { Album(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "album")
        }
      }

      public struct Album: GraphQLSelectionSet {
        public static let possibleTypes = ["Album"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
          GraphQLField("photos", type: .object(Photo.selections)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
          self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var accesstype: String {
          get {
            return snapshot["accesstype"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "accesstype")
          }
        }

        public var photos: Photo? {
          get {
            return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "photos")
          }
        }

        public struct Photo: GraphQLSelectionSet {
          public static let possibleTypes = ["ModelPhotoConnection"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("nextToken", type: .scalar(String.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(nextToken: String? = nil) {
            self.init(snapshot: ["__typename": "ModelPhotoConnection", "nextToken": nextToken])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var nextToken: String? {
            get {
              return snapshot["nextToken"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "nextToken")
            }
          }
        }
      }
    }
  }
}

public final class UpdatePhotoMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdatePhoto($input: UpdatePhotoInput!) {\n  updatePhoto(input: $input) {\n    __typename\n    id\n    name\n    bucket\n    key\n    album {\n      __typename\n      id\n      username\n      name\n      accesstype\n      photos {\n        __typename\n        nextToken\n      }\n    }\n  }\n}"

  public var input: UpdatePhotoInput

  public init(input: UpdatePhotoInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updatePhoto", arguments: ["input": GraphQLVariable("input")], type: .object(UpdatePhoto.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updatePhoto: UpdatePhoto? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updatePhoto": updatePhoto.flatMap { $0.snapshot }])
    }

    public var updatePhoto: UpdatePhoto? {
      get {
        return (snapshot["updatePhoto"] as? Snapshot).flatMap { UpdatePhoto(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "updatePhoto")
      }
    }

    public struct UpdatePhoto: GraphQLSelectionSet {
      public static let possibleTypes = ["Photo"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(String.self))),
        GraphQLField("album", type: .object(Album.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, bucket: String, key: String, album: Album? = nil) {
        self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key, "album": album.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var bucket: String {
        get {
          return snapshot["bucket"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bucket")
        }
      }

      public var key: String {
        get {
          return snapshot["key"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var album: Album? {
        get {
          return (snapshot["album"] as? Snapshot).flatMap { Album(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "album")
        }
      }

      public struct Album: GraphQLSelectionSet {
        public static let possibleTypes = ["Album"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
          GraphQLField("photos", type: .object(Photo.selections)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
          self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var accesstype: String {
          get {
            return snapshot["accesstype"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "accesstype")
          }
        }

        public var photos: Photo? {
          get {
            return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "photos")
          }
        }

        public struct Photo: GraphQLSelectionSet {
          public static let possibleTypes = ["ModelPhotoConnection"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("nextToken", type: .scalar(String.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(nextToken: String? = nil) {
            self.init(snapshot: ["__typename": "ModelPhotoConnection", "nextToken": nextToken])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var nextToken: String? {
            get {
              return snapshot["nextToken"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "nextToken")
            }
          }
        }
      }
    }
  }
}

public final class DeletePhotoMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeletePhoto($input: DeletePhotoInput!) {\n  deletePhoto(input: $input) {\n    __typename\n    id\n    name\n    bucket\n    key\n    album {\n      __typename\n      id\n      username\n      name\n      accesstype\n      photos {\n        __typename\n        nextToken\n      }\n    }\n  }\n}"

  public var input: DeletePhotoInput

  public init(input: DeletePhotoInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deletePhoto", arguments: ["input": GraphQLVariable("input")], type: .object(DeletePhoto.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deletePhoto: DeletePhoto? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deletePhoto": deletePhoto.flatMap { $0.snapshot }])
    }

    public var deletePhoto: DeletePhoto? {
      get {
        return (snapshot["deletePhoto"] as? Snapshot).flatMap { DeletePhoto(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deletePhoto")
      }
    }

    public struct DeletePhoto: GraphQLSelectionSet {
      public static let possibleTypes = ["Photo"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(String.self))),
        GraphQLField("album", type: .object(Album.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, bucket: String, key: String, album: Album? = nil) {
        self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key, "album": album.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var bucket: String {
        get {
          return snapshot["bucket"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bucket")
        }
      }

      public var key: String {
        get {
          return snapshot["key"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var album: Album? {
        get {
          return (snapshot["album"] as? Snapshot).flatMap { Album(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "album")
        }
      }

      public struct Album: GraphQLSelectionSet {
        public static let possibleTypes = ["Album"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
          GraphQLField("photos", type: .object(Photo.selections)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
          self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var accesstype: String {
          get {
            return snapshot["accesstype"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "accesstype")
          }
        }

        public var photos: Photo? {
          get {
            return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "photos")
          }
        }

        public struct Photo: GraphQLSelectionSet {
          public static let possibleTypes = ["ModelPhotoConnection"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("nextToken", type: .scalar(String.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(nextToken: String? = nil) {
            self.init(snapshot: ["__typename": "ModelPhotoConnection", "nextToken": nextToken])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var nextToken: String? {
            get {
              return snapshot["nextToken"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "nextToken")
            }
          }
        }
      }
    }
  }
}

public final class GetAlbumQuery: GraphQLQuery {
  public static let operationString =
    "query GetAlbum($id: ID!) {\n  getAlbum(id: $id) {\n    __typename\n    id\n    username\n    name\n    accesstype\n    photos {\n      __typename\n      items {\n        __typename\n        id\n        name\n        bucket\n        key\n      }\n      nextToken\n    }\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getAlbum", arguments: ["id": GraphQLVariable("id")], type: .object(GetAlbum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getAlbum: GetAlbum? = nil) {
      self.init(snapshot: ["__typename": "Query", "getAlbum": getAlbum.flatMap { $0.snapshot }])
    }

    public var getAlbum: GetAlbum? {
      get {
        return (snapshot["getAlbum"] as? Snapshot).flatMap { GetAlbum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getAlbum")
      }
    }

    public struct GetAlbum: GraphQLSelectionSet {
      public static let possibleTypes = ["Album"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
        GraphQLField("photos", type: .object(Photo.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
        self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var accesstype: String {
        get {
          return snapshot["accesstype"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "accesstype")
        }
      }

      public var photos: Photo? {
        get {
          return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "photos")
        }
      }

      public struct Photo: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelPhotoConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("items", type: .list(.object(Item.selections))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(items: [Item?]? = nil, nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelPhotoConnection", "items": items.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var items: [Item?]? {
          get {
            return (snapshot["items"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Item(snapshot: $0) } } }
          }
          set {
            snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "items")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }

        public struct Item: GraphQLSelectionSet {
          public static let possibleTypes = ["Photo"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
            GraphQLField("key", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(id: GraphQLID, name: String, bucket: String, key: String) {
            self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return snapshot["id"]! as! GraphQLID
            }
            set {
              snapshot.updateValue(newValue, forKey: "id")
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var bucket: String {
            get {
              return snapshot["bucket"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "bucket")
            }
          }

          public var key: String {
            get {
              return snapshot["key"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "key")
            }
          }
        }
      }
    }
  }
}

public final class ListAlbumsQuery: GraphQLQuery {
  public static let operationString =
    "query ListAlbums($filter: ModelAlbumFilterInput, $limit: Int, $nextToken: String) {\n  listAlbums(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      username\n      name\n      accesstype\n      photos {\n        __typename\n        nextToken\n      }\n    }\n    nextToken\n  }\n}"

  public var filter: ModelAlbumFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelAlbumFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listAlbums", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListAlbum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listAlbums: ListAlbum? = nil) {
      self.init(snapshot: ["__typename": "Query", "listAlbums": listAlbums.flatMap { $0.snapshot }])
    }

    public var listAlbums: ListAlbum? {
      get {
        return (snapshot["listAlbums"] as? Snapshot).flatMap { ListAlbum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listAlbums")
      }
    }

    public struct ListAlbum: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelAlbumConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .list(.object(Item.selections))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?]? = nil, nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelAlbumConnection", "items": items.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?]? {
        get {
          return (snapshot["items"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Item(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["Album"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
          GraphQLField("photos", type: .object(Photo.selections)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
          self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var accesstype: String {
          get {
            return snapshot["accesstype"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "accesstype")
          }
        }

        public var photos: Photo? {
          get {
            return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "photos")
          }
        }

        public struct Photo: GraphQLSelectionSet {
          public static let possibleTypes = ["ModelPhotoConnection"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("nextToken", type: .scalar(String.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(nextToken: String? = nil) {
            self.init(snapshot: ["__typename": "ModelPhotoConnection", "nextToken": nextToken])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var nextToken: String? {
            get {
              return snapshot["nextToken"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "nextToken")
            }
          }
        }
      }
    }
  }
}

public final class GetPhotoQuery: GraphQLQuery {
  public static let operationString =
    "query GetPhoto($id: ID!) {\n  getPhoto(id: $id) {\n    __typename\n    id\n    name\n    bucket\n    key\n    album {\n      __typename\n      id\n      username\n      name\n      accesstype\n      photos {\n        __typename\n        nextToken\n      }\n    }\n  }\n}"

  public var id: GraphQLID

  public init(id: GraphQLID) {
    self.id = id
  }

  public var variables: GraphQLMap? {
    return ["id": id]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getPhoto", arguments: ["id": GraphQLVariable("id")], type: .object(GetPhoto.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getPhoto: GetPhoto? = nil) {
      self.init(snapshot: ["__typename": "Query", "getPhoto": getPhoto.flatMap { $0.snapshot }])
    }

    public var getPhoto: GetPhoto? {
      get {
        return (snapshot["getPhoto"] as? Snapshot).flatMap { GetPhoto(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getPhoto")
      }
    }

    public struct GetPhoto: GraphQLSelectionSet {
      public static let possibleTypes = ["Photo"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(String.self))),
        GraphQLField("album", type: .object(Album.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, bucket: String, key: String, album: Album? = nil) {
        self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key, "album": album.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var bucket: String {
        get {
          return snapshot["bucket"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bucket")
        }
      }

      public var key: String {
        get {
          return snapshot["key"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var album: Album? {
        get {
          return (snapshot["album"] as? Snapshot).flatMap { Album(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "album")
        }
      }

      public struct Album: GraphQLSelectionSet {
        public static let possibleTypes = ["Album"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
          GraphQLField("photos", type: .object(Photo.selections)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
          self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var accesstype: String {
          get {
            return snapshot["accesstype"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "accesstype")
          }
        }

        public var photos: Photo? {
          get {
            return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "photos")
          }
        }

        public struct Photo: GraphQLSelectionSet {
          public static let possibleTypes = ["ModelPhotoConnection"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("nextToken", type: .scalar(String.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(nextToken: String? = nil) {
            self.init(snapshot: ["__typename": "ModelPhotoConnection", "nextToken": nextToken])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var nextToken: String? {
            get {
              return snapshot["nextToken"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "nextToken")
            }
          }
        }
      }
    }
  }
}

public final class ListPhotosQuery: GraphQLQuery {
  public static let operationString =
    "query ListPhotos($filter: ModelPhotoFilterInput, $limit: Int, $nextToken: String) {\n  listPhotos(filter: $filter, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      name\n      bucket\n      key\n      album {\n        __typename\n        id\n        username\n        name\n        accesstype\n      }\n    }\n    nextToken\n  }\n}"

  public var filter: ModelPhotoFilterInput?
  public var limit: Int?
  public var nextToken: String?

  public init(filter: ModelPhotoFilterInput? = nil, limit: Int? = nil, nextToken: String? = nil) {
    self.filter = filter
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["filter": filter, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listPhotos", arguments: ["filter": GraphQLVariable("filter"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListPhoto.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listPhotos: ListPhoto? = nil) {
      self.init(snapshot: ["__typename": "Query", "listPhotos": listPhotos.flatMap { $0.snapshot }])
    }

    public var listPhotos: ListPhoto? {
      get {
        return (snapshot["listPhotos"] as? Snapshot).flatMap { ListPhoto(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listPhotos")
      }
    }

    public struct ListPhoto: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelPhotoConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .list(.object(Item.selections))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?]? = nil, nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelPhotoConnection", "items": items.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?]? {
        get {
          return (snapshot["items"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Item(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["Photo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
          GraphQLField("key", type: .nonNull(.scalar(String.self))),
          GraphQLField("album", type: .object(Album.selections)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, name: String, bucket: String, key: String, album: Album? = nil) {
          self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key, "album": album.flatMap { $0.snapshot }])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var bucket: String {
          get {
            return snapshot["bucket"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bucket")
          }
        }

        public var key: String {
          get {
            return snapshot["key"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "key")
          }
        }

        public var album: Album? {
          get {
            return (snapshot["album"] as? Snapshot).flatMap { Album(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "album")
          }
        }

        public struct Album: GraphQLSelectionSet {
          public static let possibleTypes = ["Album"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("username", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(id: GraphQLID, username: String, name: String, accesstype: String) {
            self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return snapshot["id"]! as! GraphQLID
            }
            set {
              snapshot.updateValue(newValue, forKey: "id")
            }
          }

          public var username: String {
            get {
              return snapshot["username"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "username")
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var accesstype: String {
            get {
              return snapshot["accesstype"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "accesstype")
            }
          }
        }
      }
    }
  }
}

public final class OnCreateAlbumSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreateAlbum {\n  onCreateAlbum {\n    __typename\n    id\n    username\n    name\n    accesstype\n    photos {\n      __typename\n      items {\n        __typename\n        id\n        name\n        bucket\n        key\n      }\n      nextToken\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreateAlbum", type: .object(OnCreateAlbum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreateAlbum: OnCreateAlbum? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreateAlbum": onCreateAlbum.flatMap { $0.snapshot }])
    }

    public var onCreateAlbum: OnCreateAlbum? {
      get {
        return (snapshot["onCreateAlbum"] as? Snapshot).flatMap { OnCreateAlbum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreateAlbum")
      }
    }

    public struct OnCreateAlbum: GraphQLSelectionSet {
      public static let possibleTypes = ["Album"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
        GraphQLField("photos", type: .object(Photo.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
        self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var accesstype: String {
        get {
          return snapshot["accesstype"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "accesstype")
        }
      }

      public var photos: Photo? {
        get {
          return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "photos")
        }
      }

      public struct Photo: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelPhotoConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("items", type: .list(.object(Item.selections))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(items: [Item?]? = nil, nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelPhotoConnection", "items": items.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var items: [Item?]? {
          get {
            return (snapshot["items"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Item(snapshot: $0) } } }
          }
          set {
            snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "items")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }

        public struct Item: GraphQLSelectionSet {
          public static let possibleTypes = ["Photo"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
            GraphQLField("key", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(id: GraphQLID, name: String, bucket: String, key: String) {
            self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return snapshot["id"]! as! GraphQLID
            }
            set {
              snapshot.updateValue(newValue, forKey: "id")
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var bucket: String {
            get {
              return snapshot["bucket"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "bucket")
            }
          }

          public var key: String {
            get {
              return snapshot["key"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "key")
            }
          }
        }
      }
    }
  }
}

public final class OnUpdateAlbumSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdateAlbum {\n  onUpdateAlbum {\n    __typename\n    id\n    username\n    name\n    accesstype\n    photos {\n      __typename\n      items {\n        __typename\n        id\n        name\n        bucket\n        key\n      }\n      nextToken\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdateAlbum", type: .object(OnUpdateAlbum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdateAlbum: OnUpdateAlbum? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdateAlbum": onUpdateAlbum.flatMap { $0.snapshot }])
    }

    public var onUpdateAlbum: OnUpdateAlbum? {
      get {
        return (snapshot["onUpdateAlbum"] as? Snapshot).flatMap { OnUpdateAlbum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdateAlbum")
      }
    }

    public struct OnUpdateAlbum: GraphQLSelectionSet {
      public static let possibleTypes = ["Album"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
        GraphQLField("photos", type: .object(Photo.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
        self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var accesstype: String {
        get {
          return snapshot["accesstype"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "accesstype")
        }
      }

      public var photos: Photo? {
        get {
          return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "photos")
        }
      }

      public struct Photo: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelPhotoConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("items", type: .list(.object(Item.selections))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(items: [Item?]? = nil, nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelPhotoConnection", "items": items.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var items: [Item?]? {
          get {
            return (snapshot["items"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Item(snapshot: $0) } } }
          }
          set {
            snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "items")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }

        public struct Item: GraphQLSelectionSet {
          public static let possibleTypes = ["Photo"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
            GraphQLField("key", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(id: GraphQLID, name: String, bucket: String, key: String) {
            self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return snapshot["id"]! as! GraphQLID
            }
            set {
              snapshot.updateValue(newValue, forKey: "id")
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var bucket: String {
            get {
              return snapshot["bucket"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "bucket")
            }
          }

          public var key: String {
            get {
              return snapshot["key"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "key")
            }
          }
        }
      }
    }
  }
}

public final class OnDeleteAlbumSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeleteAlbum {\n  onDeleteAlbum {\n    __typename\n    id\n    username\n    name\n    accesstype\n    photos {\n      __typename\n      items {\n        __typename\n        id\n        name\n        bucket\n        key\n      }\n      nextToken\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeleteAlbum", type: .object(OnDeleteAlbum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeleteAlbum: OnDeleteAlbum? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeleteAlbum": onDeleteAlbum.flatMap { $0.snapshot }])
    }

    public var onDeleteAlbum: OnDeleteAlbum? {
      get {
        return (snapshot["onDeleteAlbum"] as? Snapshot).flatMap { OnDeleteAlbum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeleteAlbum")
      }
    }

    public struct OnDeleteAlbum: GraphQLSelectionSet {
      public static let possibleTypes = ["Album"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
        GraphQLField("photos", type: .object(Photo.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
        self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var accesstype: String {
        get {
          return snapshot["accesstype"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "accesstype")
        }
      }

      public var photos: Photo? {
        get {
          return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "photos")
        }
      }

      public struct Photo: GraphQLSelectionSet {
        public static let possibleTypes = ["ModelPhotoConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("items", type: .list(.object(Item.selections))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(items: [Item?]? = nil, nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "ModelPhotoConnection", "items": items.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var items: [Item?]? {
          get {
            return (snapshot["items"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Item(snapshot: $0) } } }
          }
          set {
            snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "items")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }

        public struct Item: GraphQLSelectionSet {
          public static let possibleTypes = ["Photo"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
            GraphQLField("key", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(id: GraphQLID, name: String, bucket: String, key: String) {
            self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return snapshot["id"]! as! GraphQLID
            }
            set {
              snapshot.updateValue(newValue, forKey: "id")
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var bucket: String {
            get {
              return snapshot["bucket"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "bucket")
            }
          }

          public var key: String {
            get {
              return snapshot["key"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "key")
            }
          }
        }
      }
    }
  }
}

public final class OnCreatePhotoSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnCreatePhoto {\n  onCreatePhoto {\n    __typename\n    id\n    name\n    bucket\n    key\n    album {\n      __typename\n      id\n      username\n      name\n      accesstype\n      photos {\n        __typename\n        nextToken\n      }\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onCreatePhoto", type: .object(OnCreatePhoto.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onCreatePhoto: OnCreatePhoto? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onCreatePhoto": onCreatePhoto.flatMap { $0.snapshot }])
    }

    public var onCreatePhoto: OnCreatePhoto? {
      get {
        return (snapshot["onCreatePhoto"] as? Snapshot).flatMap { OnCreatePhoto(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onCreatePhoto")
      }
    }

    public struct OnCreatePhoto: GraphQLSelectionSet {
      public static let possibleTypes = ["Photo"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(String.self))),
        GraphQLField("album", type: .object(Album.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, bucket: String, key: String, album: Album? = nil) {
        self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key, "album": album.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var bucket: String {
        get {
          return snapshot["bucket"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bucket")
        }
      }

      public var key: String {
        get {
          return snapshot["key"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var album: Album? {
        get {
          return (snapshot["album"] as? Snapshot).flatMap { Album(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "album")
        }
      }

      public struct Album: GraphQLSelectionSet {
        public static let possibleTypes = ["Album"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
          GraphQLField("photos", type: .object(Photo.selections)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
          self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var accesstype: String {
          get {
            return snapshot["accesstype"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "accesstype")
          }
        }

        public var photos: Photo? {
          get {
            return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "photos")
          }
        }

        public struct Photo: GraphQLSelectionSet {
          public static let possibleTypes = ["ModelPhotoConnection"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("nextToken", type: .scalar(String.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(nextToken: String? = nil) {
            self.init(snapshot: ["__typename": "ModelPhotoConnection", "nextToken": nextToken])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var nextToken: String? {
            get {
              return snapshot["nextToken"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "nextToken")
            }
          }
        }
      }
    }
  }
}

public final class OnUpdatePhotoSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnUpdatePhoto {\n  onUpdatePhoto {\n    __typename\n    id\n    name\n    bucket\n    key\n    album {\n      __typename\n      id\n      username\n      name\n      accesstype\n      photos {\n        __typename\n        nextToken\n      }\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onUpdatePhoto", type: .object(OnUpdatePhoto.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onUpdatePhoto: OnUpdatePhoto? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onUpdatePhoto": onUpdatePhoto.flatMap { $0.snapshot }])
    }

    public var onUpdatePhoto: OnUpdatePhoto? {
      get {
        return (snapshot["onUpdatePhoto"] as? Snapshot).flatMap { OnUpdatePhoto(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onUpdatePhoto")
      }
    }

    public struct OnUpdatePhoto: GraphQLSelectionSet {
      public static let possibleTypes = ["Photo"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(String.self))),
        GraphQLField("album", type: .object(Album.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, bucket: String, key: String, album: Album? = nil) {
        self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key, "album": album.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var bucket: String {
        get {
          return snapshot["bucket"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bucket")
        }
      }

      public var key: String {
        get {
          return snapshot["key"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var album: Album? {
        get {
          return (snapshot["album"] as? Snapshot).flatMap { Album(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "album")
        }
      }

      public struct Album: GraphQLSelectionSet {
        public static let possibleTypes = ["Album"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
          GraphQLField("photos", type: .object(Photo.selections)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
          self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var accesstype: String {
          get {
            return snapshot["accesstype"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "accesstype")
          }
        }

        public var photos: Photo? {
          get {
            return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "photos")
          }
        }

        public struct Photo: GraphQLSelectionSet {
          public static let possibleTypes = ["ModelPhotoConnection"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("nextToken", type: .scalar(String.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(nextToken: String? = nil) {
            self.init(snapshot: ["__typename": "ModelPhotoConnection", "nextToken": nextToken])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var nextToken: String? {
            get {
              return snapshot["nextToken"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "nextToken")
            }
          }
        }
      }
    }
  }
}

public final class OnDeletePhotoSubscription: GraphQLSubscription {
  public static let operationString =
    "subscription OnDeletePhoto {\n  onDeletePhoto {\n    __typename\n    id\n    name\n    bucket\n    key\n    album {\n      __typename\n      id\n      username\n      name\n      accesstype\n      photos {\n        __typename\n        nextToken\n      }\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Subscription"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("onDeletePhoto", type: .object(OnDeletePhoto.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(onDeletePhoto: OnDeletePhoto? = nil) {
      self.init(snapshot: ["__typename": "Subscription", "onDeletePhoto": onDeletePhoto.flatMap { $0.snapshot }])
    }

    public var onDeletePhoto: OnDeletePhoto? {
      get {
        return (snapshot["onDeletePhoto"] as? Snapshot).flatMap { OnDeletePhoto(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "onDeletePhoto")
      }
    }

    public struct OnDeletePhoto: GraphQLSelectionSet {
      public static let possibleTypes = ["Photo"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("bucket", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(String.self))),
        GraphQLField("album", type: .object(Album.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, name: String, bucket: String, key: String, album: Album? = nil) {
        self.init(snapshot: ["__typename": "Photo", "id": id, "name": name, "bucket": bucket, "key": key, "album": album.flatMap { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var bucket: String {
        get {
          return snapshot["bucket"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "bucket")
        }
      }

      public var key: String {
        get {
          return snapshot["key"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var album: Album? {
        get {
          return (snapshot["album"] as? Snapshot).flatMap { Album(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "album")
        }
      }

      public struct Album: GraphQLSelectionSet {
        public static let possibleTypes = ["Album"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("accesstype", type: .nonNull(.scalar(String.self))),
          GraphQLField("photos", type: .object(Photo.selections)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, username: String, name: String, accesstype: String, photos: Photo? = nil) {
          self.init(snapshot: ["__typename": "Album", "id": id, "username": username, "name": name, "accesstype": accesstype, "photos": photos.flatMap { $0.snapshot }])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var accesstype: String {
          get {
            return snapshot["accesstype"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "accesstype")
          }
        }

        public var photos: Photo? {
          get {
            return (snapshot["photos"] as? Snapshot).flatMap { Photo(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "photos")
          }
        }

        public struct Photo: GraphQLSelectionSet {
          public static let possibleTypes = ["ModelPhotoConnection"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("nextToken", type: .scalar(String.self)),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(nextToken: String? = nil) {
            self.init(snapshot: ["__typename": "ModelPhotoConnection", "nextToken": nextToken])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var nextToken: String? {
            get {
              return snapshot["nextToken"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "nextToken")
            }
          }
        }
      }
    }
  }
}