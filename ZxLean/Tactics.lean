import ZxLean.Axioms
import ZxLean.Visualize
import ProofWidgets.Component.HtmlDisplay

open Lean Elab Tactic Meta ProofWidgets

namespace ZxLean

-- == ToExpr instances (convert runtime values back to Lean expressions) ==

instance : ToExpr SpiderColor where
  toExpr c := match c with
    | .Z => mkConst ``SpiderColor.Z
    | .X => mkConst ``SpiderColor.X
  toTypeExpr := mkConst ``SpiderColor

instance : ToExpr Phase where
  toExpr p := mkApp2 (mkConst ``Phase.mk) (toExpr p.num) (toExpr p.den)
  toTypeExpr := mkConst ``Phase

instance : ToExpr Node where
  toExpr n := match n with
    | .spider c p => mkApp2 (mkConst ``Node.spider) (toExpr c) (toExpr p)
    | .hadamard => mkConst ``Node.hadamard
    | .input id => mkApp (mkConst ``Node.input) (toExpr id)
    | .output id => mkApp (mkConst ``Node.output) (toExpr id)
  toTypeExpr := mkConst ``Node

instance : ToExpr Edge where
  toExpr e := mkApp2 (mkConst ``Edge.mk) (toExpr e.src) (toExpr e.tgt)
  toTypeExpr := mkConst ``Edge

instance : ToExpr ZXDiagram where
  toExpr d := mkApp2 (mkConst ``ZXDiagram.mk) (toExpr d.nodes) (toExpr d.edges)
  toTypeExpr := mkConst ``ZXDiagram

-- == Evaluation helpers ==

private unsafe def evalOptionZXDiagramImpl (e : Expr) : MetaM (Option ZXDiagram) :=
  Meta.evalExpr (Option ZXDiagram)
    (mkApp (mkConst ``Option [levelZero]) (mkConst ``ZXDiagram)) e

@[implemented_by evalOptionZXDiagramImpl]
private opaque evalOptionZXDiagram : Expr → MetaM (Option ZXDiagram)

private unsafe def evalZXDiagramImpl (e : Expr) : MetaM ZXDiagram :=
  Meta.evalExpr ZXDiagram (mkConst ``ZXDiagram) e

@[implemented_by evalZXDiagramImpl]
private opaque evalZXDiagram : Expr → MetaM ZXDiagram

-- == Goal parsing ==

/-- Extract LHS and RHS from a goal of the form `d ≈z d'` -/
private def parseEquivGoal (goalType : Expr) : TacticM (Expr × Expr) := do
  let some (lhs, rhs) := goalType.app2? ``ZXDiagram.equiv
    | throwError "Goal is not of the form `d ≈z d'`"
  return (lhs, rhs)

-- == Visualization ==

/-- Show a ZXDiagram in the InfoView -/
private def showDiagram (stx : Syntax) (label : String) (d : ZXDiagram) : TacticM Unit := do
  let html := d.toHtml
  let msg ← MessageData.ofHtml html label
  logInfoAt stx msg

-- == Core rewrite tactic ==

/-- Apply a rewrite rule and show the result.
    Evaluates the rewrite using the compiler, then proves correctness with native_decide. -/
private def applyRewrite (stx : Syntax) (label : String)
    (rewriteFn soundAxiom : Name) (args : Array Expr) : TacticM Unit :=
    withMainContext do
  let goal ← getMainGoal
  let goalType ← goal.getType
  let (lhs, rhs) ← parseEquivGoal goalType

  -- Build the rewrite application expression
  let rewriteApp ← mkAppM rewriteFn (#[lhs] ++ args)

  -- Evaluate using compiler to get the actual result
  let some d₁Val ← evalOptionZXDiagram rewriteApp
    | throwError "{label} failed"
  let d₁ := toExpr d₁Val

  -- Create proof obligation: rewriteFn lhs args... = some d₁
  let someDOne ← mkAppOptM ``Option.some #[mkConst ``ZXDiagram, d₁]
  let eqType ← mkEq rewriteApp someDOne
  let eqProof ← mkFreshExprMVar eqType

  -- New goal: d₁ ≈z rhs
  let newGoalType ← mkAppM ``ZXDiagram.equiv #[d₁, rhs]
  let newGoal ← mkFreshExprMVar newGoalType

  -- Prove equality with native_decide
  setGoals [eqProof.mvarId!]
  evalTactic (← `(tactic| native_decide))

  -- Build proof: equiv_trans (soundAxiom lhs args... d₁ eqProof) newGoal
  let soundProof ← mkAppM soundAxiom (#[lhs] ++ args ++ #[d₁, eqProof])
  let transProof ← mkAppM ``ZXDiagram.equiv_trans #[soundProof, newGoal]
  goal.assign transProof

  -- Set remaining goal and show diagram
  setGoals [newGoal.mvarId!]
  showDiagram stx label d₁Val

-- == User-facing tactics ==

/-- Fuse two connected spiders of the same color. Shows the resulting diagram. -/
syntax "zx_spider_fusion" num num : tactic

elab_rules : tactic
  | `(tactic| zx_spider_fusion $a $b) =>
    applyRewrite a "Spider fusion"
      ``ZXDiagram.spiderFusion ``ZXDiagram.spiderFusion_sound
      #[mkNatLit a.getNat, mkNatLit b.getNat]

/-- Remove an identity (phase-0, degree-2) spider. Shows the resulting diagram. -/
syntax "zx_id_removal" num : tactic

elab_rules : tactic
  | `(tactic| zx_id_removal $a) =>
    applyRewrite a "Identity removal"
      ``ZXDiagram.identityRemoval ``ZXDiagram.identityRemoval_sound
      #[mkNatLit a.getNat]

/-- Show the current LHS diagram in the InfoView without modifying the goal. -/
elab tk:"zx_show" : tactic => withMainContext do
  let goal ← getMainGoal
  let goalType ← goal.getType
  let (lhs, _) ← parseEquivGoal goalType
  let d ← evalZXDiagram lhs
  showDiagram tk "Current diagram" d

/-- Close a `d ≈z d` goal by reflexivity. -/
elab "zx_rfl" : tactic => withMainContext do
  let goal ← getMainGoal
  let goalType ← goal.getType
  let (lhs, _) ← parseEquivGoal goalType
  let reflProof ← mkAppM ``ZXDiagram.equiv_refl #[lhs]
  goal.assign reflProof

end ZxLean
