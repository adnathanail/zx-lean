import ZxLean

def twoSpiders : ZXDiagram :=
  { nodes := #[.input 0, .spider .Z ⟨1, 1⟩, .spider .Z ⟨2, 1⟩, .output 0]
    edges := #[⟨0, 1⟩, ⟨1, 2⟩, ⟨2, 3⟩] }

#eval twoSpiders

def main : IO Unit :=
  IO.println s!"Hello!"
