inductive SpiderColor where
  | Z  -- green
  | X  -- red
  deriving Repr

/-- Phase as a rational multiple of π, stored as p/q.
    e.g. phase 1 2 represents π/2 -/
structure Phase where
  num : Int
  den : Nat := 1
  deriving Repr

/-- Internal spider (Z/X) or input or output -/
inductive Node where
  | spider (color : SpiderColor) (phase : Phase)
  | input  (id : Nat)
  | output (id : Nat)
  deriving Repr

/-- Edge between nodes identified by index into the node array -/
structure Edge where
  src : Nat
  tgt : Nat
  deriving Repr

structure ZXDiagram where
  nodes : Array Node
  edges : Array Edge
  deriving Repr
