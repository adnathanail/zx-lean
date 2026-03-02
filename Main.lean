import ZxLean

/-- in -→ Z(π) -→ Z(2π) -→ out -/
def twoSpiders : ZXDiagram :=
  { nodes := #[.input 0, .spider .Z ⟨1, 2⟩, .spider .Z ⟨1, 1⟩, .output 0]
    edges := #[⟨0, 1⟩, ⟨1, 2⟩, ⟨2, 3⟩] }

/-- in -→ Z(3π) -→ out -/
-- def fused : ZXDiagram :=
--   { nodes := #[.input 0, .spider .Z ⟨3, 1⟩, .output 0]
--     edges := #[⟨0, 1⟩, ⟨1, 2⟩] }

def empty_graph : ZXDiagram :=
  { nodes := #[.input 0, .output 0]
    edges := #[⟨0, 1⟩] }

-- #eval twoSpiders.spiderFusion 1 2
-- #eval some fused
-- #eval twoSpiders.spiderFusion 1 2 == some fused

#html empty_graph.toHtml
#html twoSpiders.toHtml
#html ((twoSpiders.spiderFusion 1 2).getD empty_graph).toHtml

def threeSpiders : ZXDiagram :=
  { nodes := #[.input 0, .spider .Z ⟨1, 2⟩, .spider .Z ⟨1, 1⟩, .spider .Z ⟨3, 4⟩, .output 0]
    edges := #[⟨0, 1⟩, ⟨1, 2⟩, ⟨2, 3⟩, ⟨3, 4⟩] }

#html threeSpiders.toHtml
#html ((threeSpiders.spiderFusion 2 3).getD empty_graph).toHtml

def zCnotZ : ZXDiagram :=
  { nodes := #[
      .input 0, .spider .Z ⟨1, 1⟩, .spider .Z ⟨0, 1⟩, .spider .Z ⟨1, 1⟩, .output 0,
      .input 1, .spider .X ⟨0, 1⟩, .output 1
    ]
    edges := #[⟨0, 1⟩, ⟨1, 2⟩, ⟨2, 3⟩, ⟨3, 4⟩, ⟨5, 6⟩] }
#html zCnotZ.toHtml

def main : IO Unit :=
  IO.println "Open Main.lean in VS Code to see the ZX diagram in the InfoView."
