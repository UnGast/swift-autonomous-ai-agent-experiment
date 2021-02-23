public enum Mutation<E: Evolvable> {
  indirect case random(original: E, policy: E.RandomMutationPolicy)
  indirect case crossOver(originals: [E], weights: [Double])
}