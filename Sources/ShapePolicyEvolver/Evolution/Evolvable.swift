public protocol Evolvable: class {
  associatedtype RandomMutationPolicy

  var fitness: Double { get set }
  var sourceMutation: Mutation<Self>? { get set } 
  
  static func getMutant(from mutation: Mutation<Self>) -> Self
}