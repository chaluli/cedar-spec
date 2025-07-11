/-
 Copyright Cedar Contributors

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-/

import Cedar.Thm.Validation.WellTyped.Soundness
import Cedar.Thm.Validation.WellTyped.Typechecking

/-!
This file contains well-typedness theorems of `TypedExpr`
-/

namespace Cedar.Thm

open Cedar.Thm
open Cedar.Validation
open Cedar.Spec

/-- Successful evaluation of a well-typed expression should produce a value
of corresponding type. -/
theorem well_typed_is_sound {ty : TypedExpr} {v : Value} {env : TypeEnv} {request : Request} {entities : Entities} :
  InstanceOfWellFormedEnvironment request entities env →
  TypedExpr.WellTyped env ty →
  evaluate ty.toExpr request entities = .ok v →
  InstanceOfType env v ty.typeOf
:= by
  intro h₁ h₂ h₃
  induction h₂ generalizing v <;> simp only [TypedExpr.toExpr] at h₃
  case lit p ty h₄ =>
    exact well_typed_is_sound_lit h₄ h₃
  case var var ty h₄ =>
    exact well_typed_is_sound_var h₁ h₄ h₃
  case ite x₁ x₂ x₃ _ _ _ h₄ h₅ hᵢ₁ hᵢ₂ hᵢ₃ =>
    exact well_typed_is_sound_ite h₄ h₅ hᵢ₁ hᵢ₂ hᵢ₃ h₃
  case and x₁ x₂ _ _ h₄ h₅ hᵢ₁ hᵢ₂ =>
    exact well_typed_is_sound_and h₄ h₅ hᵢ₁ hᵢ₂ h₃
  case or x₁ x₂ _ _ h₄ h₅ hᵢ₁ hᵢ₂ =>
    exact well_typed_is_sound_or h₄ h₅ hᵢ₁ hᵢ₂ h₃
  case unaryApp op₁ x₁ ty _ h₄ _ =>
    exact well_typed_is_sound_unary_app h₄ h₃
  case binaryApp op₂ x₁ x₂ ty _ _ h₄ hᵢ₁ hᵢ₂ =>
    exact well_typed_is_sound_binary_app h₁ h₄ hᵢ₁ hᵢ₂ h₃
  case hasAttr_entity x₁ _ _ _ _ =>
    exact well_typed_is_sound_has_attr h₃
  case hasAttr_record x₁ _ _ _ _ =>
    exact well_typed_is_sound_has_attr h₃
  case getAttr_entity h₄ h₅ h₆ hᵢ =>
    exact well_typed_is_sound_get_attr_entity h₁ hᵢ h₄ h₅ h₆ h₃
  case getAttr_record h₄ h₅ hᵢ=>
    exact well_typed_is_sound_get_attr_record hᵢ h₄ h₅ h₃
  case set ls ty _ h₄ _ hᵢ =>
    exact well_typed_is_sound_set hᵢ h₄ h₃
  case record rty m hᵢ₁ h₄ hᵢ =>
    exact well_typed_is_sound_record hᵢ h₄ h₃
  case call xfn args ty _ h₄ _ =>
    exact well_typed_is_sound_call h₄ h₃

end Cedar.Thm
