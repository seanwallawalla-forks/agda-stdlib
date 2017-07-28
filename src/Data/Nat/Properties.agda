------------------------------------------------------------------------
-- The Agda standard library
--
-- A bunch of properties about natural number operations
------------------------------------------------------------------------

-- See README.Nat for some examples showing how this module can be
-- used.

module Data.Nat.Properties where

open import Data.Nat as Nat
open import Relation.Binary
open import Function
open import Algebra
open import Algebra.Structures
open import Relation.Nullary
open import Relation.Nullary.Negation using (contradiction)
open import Relation.Binary.PropositionalEquality
open import Algebra.FunctionProperties (_≡_ {A = ℕ})
open import Algebra.FunctionProperties.Consequences (setoid ℕ)
open import Data.Product
open import Data.Sum
open ≡-Reasoning

------------------------------------------------------------------------
-- Properties of _≡_

suc-injective : ∀ {m n} → suc m ≡ suc n → m ≡ n
suc-injective refl = refl

≡-isDecEquivalence : IsDecEquivalence (_≡_ {A = ℕ})
≡-isDecEquivalence = record
  { isEquivalence = isEquivalence
  ; _≟_           = _≟_
  }

≡-decSetoid : DecSetoid _ _
≡-decSetoid = record
  { Carrier          = ℕ
  ; _≈_              = _≡_
  ; isDecEquivalence = ≡-isDecEquivalence
  }

------------------------------------------------------------------------
-- Properties of _≤_

-- Relation-theoretic properties of _≤_
≤-reflexive : _≡_ ⇒ _≤_
≤-reflexive {zero}  refl = z≤n
≤-reflexive {suc m} refl = s≤s (≤-reflexive refl)

≤-refl : Reflexive _≤_
≤-refl = ≤-reflexive refl

≤-antisym : Antisymmetric _≡_ _≤_
≤-antisym z≤n       z≤n       = refl
≤-antisym (s≤s m≤n) (s≤s n≤m) with ≤-antisym m≤n n≤m
... | refl = refl

≤-trans : Transitive _≤_
≤-trans z≤n       _         = z≤n
≤-trans (s≤s m≤n) (s≤s n≤o) = s≤s (≤-trans m≤n n≤o)

≤-total : Total _≤_
≤-total zero    _       = inj₁ z≤n
≤-total _       zero    = inj₂ z≤n
≤-total (suc m) (suc n) with ≤-total m n
... | inj₁ m≤n = inj₁ (s≤s m≤n)
... | inj₂ n≤m = inj₂ (s≤s n≤m)

≤-isPreorder : IsPreorder _≡_ _≤_
≤-isPreorder = record
  { isEquivalence = isEquivalence
  ; reflexive     = ≤-reflexive
  ; trans         = ≤-trans
  }

≤-isPartialOrder : IsPartialOrder _≡_ _≤_
≤-isPartialOrder = record
  { isPreorder = ≤-isPreorder
  ; antisym  = ≤-antisym
  }

≤-isTotalOrder : IsTotalOrder _≡_ _≤_
≤-isTotalOrder = record
  { isPartialOrder = ≤-isPartialOrder
  ; total = ≤-total
  }

≤-isDecTotalOrder : IsDecTotalOrder _≡_ _≤_
≤-isDecTotalOrder = record
  { isTotalOrder = ≤-isTotalOrder
  ; _≟_          = _≟_
  ; _≤?_         = _≤?_
  }

≤-decTotalOrder : DecTotalOrder _ _ _
≤-decTotalOrder = record
  { Carrier         = ℕ
  ; _≈_             = _≡_
  ; _≤_             = _≤_
  ; isDecTotalOrder = ≤-isDecTotalOrder
  }

-- Other properties of _≤_
≤-step : ∀ {m n} → m ≤ n → m ≤ 1 + n
≤-step z≤n       = z≤n
≤-step (s≤s m≤n) = s≤s (≤-step m≤n)

n≤1+n : ∀ n → n ≤ 1 + n
n≤1+n _ = ≤-step ≤-refl

1+n≰n : ∀ {n} → ¬ 1 + n ≤ n
1+n≰n (s≤s le) = 1+n≰n le

pred-mono : pred Preserves _≤_ ⟶ _≤_
pred-mono z≤n      = z≤n
pred-mono (s≤s le) = le

≤pred⇒≤ : ∀ {m n} → m ≤ pred n → m ≤ n
≤pred⇒≤ {m} {zero}  le = le
≤pred⇒≤ {m} {suc n} le = ≤-step le

≤⇒pred≤ : ∀ {m n} → m ≤ n → pred m ≤ n
≤⇒pred≤ {zero}  le = le
≤⇒pred≤ {suc m} le = ≤-trans (n≤1+n m) le

-- A module for reasoning about the _≤_ relation
module ≤-Reasoning where
  open import Relation.Binary.PartialOrderReasoning
    (DecTotalOrder.poset ≤-decTotalOrder) public
    renaming (_≈⟨_⟩_ to _≡⟨_⟩_)

  infixr 2 _<⟨_⟩_

  _<⟨_⟩_ : ∀ x {y z} → x < y → y IsRelatedTo z → suc x IsRelatedTo z
  x <⟨ x<y ⟩ y≤z = suc x ≤⟨ x<y ⟩ y≤z

------------------------------------------------------------------------
-- Properties of _<_

-- Relation theoretic properties of _<_
_<?_ : Decidable _<_
x <? y = suc x ≤? y

<-irrefl : Irreflexive _≡_ _<_
<-irrefl refl (s≤s n<n) = <-irrefl refl n<n

<-asym : Asymmetric _<_
<-asym (s≤s n<m) (s≤s m<n) = <-asym n<m m<n

<-trans : Transitive _<_
<-trans (s≤s i≤j) (s≤s j<k) = s≤s (≤-trans i≤j (≤⇒pred≤ j<k))

<-transʳ : Trans _≤_ _<_ _<_
<-transʳ m≤n (s≤s n≤o) = s≤s (≤-trans m≤n n≤o)

<-transˡ : Trans _<_ _≤_ _<_
<-transˡ (s≤s m≤n) (s≤s n≤o) = s≤s (≤-trans m≤n n≤o)

<-cmp : Trichotomous _≡_ _<_
<-cmp zero    zero    = tri≈ (λ())     refl  (λ())
<-cmp zero    (suc n) = tri< (s≤s z≤n) (λ()) (λ())
<-cmp (suc m) zero    = tri> (λ())     (λ()) (s≤s z≤n)
<-cmp (suc m) (suc n) with <-cmp m n
... | tri< ≤ ≢ ≱ = tri< (s≤s ≤)      (≢ ∘ suc-injective) (≱ ∘ ≤-pred)
... | tri≈ ≰ ≡ ≱ = tri≈ (≰ ∘ ≤-pred) (cong suc ≡)        (≱ ∘ ≤-pred)
... | tri> ≰ ≢ ≥ = tri> (≰ ∘ ≤-pred) (≢ ∘ suc-injective) (s≤s ≥)

<-isStrictTotalOrder : IsStrictTotalOrder _≡_ _<_
<-isStrictTotalOrder = record
  { isEquivalence = isEquivalence
  ; trans         = <-trans
  ; compare       = <-cmp
  }

strictTotalOrder : StrictTotalOrder _ _ _
strictTotalOrder = record
  { Carrier            = ℕ
  ; _≈_                = _≡_
  ; _<_                = _<_
  ; isStrictTotalOrder = <-isStrictTotalOrder
  }

-- Other properties of _<_
<⇒≤pred : ∀ {m n} → m < n → m ≤ pred n
<⇒≤pred (s≤s le) = le

<⇒≤ : _<_ ⇒ _≤_
<⇒≤ (s≤s m≤n) = ≤-trans m≤n (≤-step ≤-refl)

<⇒≢ : _<_ ⇒ _≢_
<⇒≢ m<n refl = 1+n≰n m<n

<⇒≱ : _<_ ⇒ _≱_
<⇒≱ (s≤s m+1≤n) (s≤s n≤m) = <⇒≱ m+1≤n n≤m

<⇒≯ : _<_ ⇒ _≯_
<⇒≯ (s≤s m<n) (s≤s n<m) = <⇒≯ m<n n<m

≰⇒≮ : _≰_ ⇒ _≮_
≰⇒≮ m≰n 1+m≤n = m≰n (<⇒≤ 1+m≤n)

≰⇒> : _≰_ ⇒ _>_
≰⇒> {zero}          z≰n = contradiction z≤n z≰n
≰⇒> {suc m} {zero}  _   = s≤s z≤n
≰⇒> {suc m} {suc n} m≰n = s≤s (≰⇒> (m≰n ∘ s≤s))

≰⇒≥ : _≰_ ⇒ _≥_
≰⇒≥ = <⇒≤ ∘ ≰⇒>

≮⇒≥ : _≮_ ⇒ _≥_
≮⇒≥ {_}     {zero}  _       = z≤n
≮⇒≥ {zero}  {suc j} 1≮j+1   = contradiction (s≤s z≤n) 1≮j+1
≮⇒≥ {suc i} {suc j} i+1≮j+1 = s≤s (≮⇒≥ (i+1≮j+1 ∘ s≤s))

≤+≢⇒< : ∀ {m n} → m ≤ n → m ≢ n → m < n
≤+≢⇒< {_} {zero}  z≤n       m≢n     = contradiction refl m≢n
≤+≢⇒< {_} {suc n} z≤n       m≢n     = s≤s z≤n
≤+≢⇒< {_} {suc n} (s≤s m≤n) 1+m≢1+n =
  s≤s (≤+≢⇒< m≤n (1+m≢1+n ∘ cong suc))

------------------------------------------------------------------------
-- Properties of _≤′_

z≤′n : ∀ {n} → zero ≤′ n
z≤′n {zero}  = ≤′-refl
z≤′n {suc n} = ≤′-step z≤′n

s≤′s : ∀ {m n} → m ≤′ n → suc m ≤′ suc n
s≤′s ≤′-refl        = ≤′-refl
s≤′s (≤′-step m≤′n) = ≤′-step (s≤′s m≤′n)

≤′⇒≤ : _≤′_ ⇒ _≤_
≤′⇒≤ ≤′-refl        = ≤-refl
≤′⇒≤ (≤′-step m≤′n) = ≤-step (≤′⇒≤ m≤′n)

≤⇒≤′ : _≤_ ⇒ _≤′_
≤⇒≤′ z≤n       = z≤′n
≤⇒≤′ (s≤s m≤n) = s≤′s (≤⇒≤′ m≤n)

------------------------------------------------------------------------
-- Properties of _≤″_

≤″⇒≤ : _≤″_ ⇒ _≤_
≤″⇒≤ {zero}  (less-than-or-equal refl) = z≤n
≤″⇒≤ {suc m} (less-than-or-equal refl) =
  s≤s (≤″⇒≤ (less-than-or-equal refl))

≤⇒≤″ : _≤_ ⇒ _≤″_
≤⇒≤″ m≤n = less-than-or-equal (proof m≤n)
  where
  k : ∀ m n → m ≤ n → ℕ
  k zero    n       _   = n
  k (suc m) zero    ()
  k (suc m) (suc n) m≤n = k m n (≤-pred m≤n)

  proof : ∀ {m n} (m≤n : m ≤ n) → m + k m n m≤n ≡ n
  proof z≤n       = refl
  proof (s≤s m≤n) = cong suc (proof m≤n)

------------------------------------------------------------------------
-- Properties of _+_

-- Algebraic properties of _+_
+-suc : ∀ m n → m + suc n ≡ suc (m + n)
+-suc zero    n = refl
+-suc (suc m) n = cong suc (+-suc m n)

+-assoc : Associative _+_
+-assoc zero    _ _ = refl
+-assoc (suc m) n o = cong suc (+-assoc m n o)

+-left-identity : LeftIdentity 0 _+_
+-left-identity _ = refl

+-right-identity : RightIdentity 0 _+_
+-right-identity zero    = refl
+-right-identity (suc n) = cong suc (+-right-identity n)

+-identity : Identity 0 _+_
+-identity = +-left-identity , +-right-identity

+-comm : Commutative _+_
+-comm zero    n = sym (+-right-identity n)
+-comm (suc m) n = begin
  suc m + n   ≡⟨⟩
  suc (m + n) ≡⟨ cong suc (+-comm m n) ⟩
  suc (n + m) ≡⟨ sym (+-suc n m) ⟩
  n + suc m   ∎

+-isSemigroup : IsSemigroup _≡_ _+_
+-isSemigroup = record
  { isEquivalence = isEquivalence
  ; assoc         = +-assoc
  ; ∙-cong        = cong₂ _+_
  }

+-0-isCommutativeMonoid : IsCommutativeMonoid _≡_ _+_ 0
+-0-isCommutativeMonoid = record
  { isSemigroup = +-isSemigroup
  ; identityˡ    = +-left-identity
  ; comm        = +-comm
  }

-- Other properties of _+_

cancel-+-left : LeftCancellative _+_
cancel-+-left zero    eq = eq
cancel-+-left (suc i) eq = cancel-+-left i (cong pred eq)

cancel-+-right : RightCancellative _+_
cancel-+-right {x} y z eq =
  cancel-+-left x (trans (trans (+-comm x y) eq) (+-comm z x))

+-cancellative : Cancellative _+_
+-cancellative = cancel-+-left , cancel-+-right

cancel-+-left-≤ : ∀ i {j k} → i + j ≤ i + k → j ≤ k
cancel-+-left-≤ zero    le       = le
cancel-+-left-≤ (suc i) (s≤s le) = cancel-+-left-≤ i le

≤-steps : ∀ {m n} k → m ≤ n → m ≤ k + n
≤-steps zero    m≤n = m≤n
≤-steps (suc k) m≤n = ≤-step (≤-steps k m≤n)

m≤m+n : ∀ m n → m ≤ m + n
m≤m+n zero    n = z≤n
m≤m+n (suc m) n = s≤s (m≤m+n m n)

m≤′m+n : ∀ m n → m ≤′ m + n
m≤′m+n m n = ≤⇒≤′ (m≤m+n m n)

n≤′m+n : ∀ m n → n ≤′ m + n
n≤′m+n zero    n = ≤′-refl
n≤′m+n (suc m) n = ≤′-step (n≤′m+n m n)

n≤m+n : ∀ m n → n ≤ m + n
n≤m+n m n = ≤′⇒≤ (n≤′m+n m n)

+-mono-≤ : _+_ Preserves₂ _≤_ ⟶ _≤_ ⟶ _≤_
+-mono-≤ {_} {m} z≤n       o≤p = ≤-trans o≤p (n≤m+n m _)
+-mono-≤ {_} {_} (s≤s m≤n) o≤p = s≤s (+-mono-≤ m≤n o≤p)

-- DEPRECATED - please use +-mono-≤ instead
_+-mono_ : _+_ Preserves₂ _≤_ ⟶ _≤_ ⟶ _≤_
_+-mono_ = +-mono-≤

+-monoˡ-< : _+_ Preserves₂ _<_ ⟶ _≤_ ⟶ _<_
+-monoˡ-< {_} {suc y} (s≤s z≤n)       u≤v = s≤s (≤-steps y u≤v)
+-monoˡ-< {_} {_}     (s≤s (s≤s x<y)) u≤v = s≤s (+-monoˡ-< (s≤s x<y) u≤v)

+-monoʳ-< : _+_ Preserves₂ _≤_ ⟶ _<_ ⟶ _<_
+-monoʳ-< {_} {y} z≤n       u<v = ≤-trans u<v (n≤m+n y _)
+-monoʳ-< {_} {_} (s≤s x≤y) u<v = s≤s (+-monoʳ-< x≤y u<v)

+-mono-< : _+_ Preserves₂ _<_ ⟶ _<_ ⟶ _<_
+-mono-< x≤y = +-monoʳ-< (<⇒≤ x≤y)

¬i+1+j≤i : ∀ i {j} → i + suc j ≰ i
¬i+1+j≤i zero    ()
¬i+1+j≤i (suc i) le = ¬i+1+j≤i i (≤-pred le)

m≢1+m+n : ∀ m {n} → m ≢ suc (m + n)
m≢1+m+n zero    ()
m≢1+m+n (suc m) eq = m≢1+m+n m (cong pred eq)

i+1+j≢i : ∀ i {j} → i + suc j ≢ i
i+1+j≢i zero    ()
i+1+j≢i (suc i) = (i+1+j≢i i) ∘ suc-injective

i+j≡0⇒i≡0 : ∀ i {j} → i + j ≡ 0 → i ≡ 0
i+j≡0⇒i≡0 zero    eq = refl
i+j≡0⇒i≡0 (suc i) ()

i+j≡0⇒j≡0 : ∀ i {j} → i + j ≡ 0 → j ≡ 0
i+j≡0⇒j≡0 i {j} i+j≡0 = i+j≡0⇒i≡0 j (trans (+-comm j i) (i+j≡0))

------------------------------------------------------------------------
-- Properties of _*_

+-*-suc : ∀ m n → m * suc n ≡ m + m * n
+-*-suc zero    n = refl
+-*-suc (suc m) n = begin
  suc m * suc n         ≡⟨⟩
  suc n + m * suc n     ≡⟨ cong (suc n +_) (+-*-suc m n) ⟩
  suc n + (m + m * n)   ≡⟨⟩
  suc (n + (m + m * n)) ≡⟨ cong suc (sym (+-assoc n m (m * n))) ⟩
  suc (n + m + m * n)   ≡⟨ cong (λ x → suc (x + m * n)) (+-comm n m) ⟩
  suc (m + n + m * n)   ≡⟨ cong suc (+-assoc m n (m * n)) ⟩
  suc (m + (n + m * n)) ≡⟨⟩
  suc m + suc m * n     ∎

*-left-identity : LeftIdentity 1 _*_
*-left-identity x = +-right-identity x

*-right-identity : RightIdentity 1 _*_
*-right-identity zero    = refl
*-right-identity (suc x) = cong suc (*-right-identity x)

*-identity : Identity 1 _*_
*-identity = *-left-identity , *-right-identity

*-left-zero : LeftZero 0 _*_
*-left-zero _ = refl

*-right-zero : RightZero 0 _*_
*-right-zero zero    = refl
*-right-zero (suc n) = *-right-zero n

*-zero : Zero 0 _*_
*-zero = *-left-zero , *-right-zero

*-comm : Commutative _*_
*-comm zero    n = sym (*-right-zero n)
*-comm (suc m) n = begin
  suc m * n  ≡⟨⟩
  n + m * n  ≡⟨ cong (n +_) (*-comm m n) ⟩
  n + n * m  ≡⟨ sym (+-*-suc n m) ⟩
  n * suc m  ∎

distribʳ-*-+ : _*_ DistributesOverʳ _+_
distribʳ-*-+ m zero    o = refl
distribʳ-*-+ m (suc n) o = begin
  (suc n + o) * m     ≡⟨⟩
  m + (n + o) * m     ≡⟨ cong (m +_) (distribʳ-*-+ m n o) ⟩
  m + (n * m + o * m) ≡⟨ sym (+-assoc m (n * m) (o * m)) ⟩
  m + n * m + o * m   ≡⟨⟩
  suc n * m + o * m   ∎

distribˡ-*-+ : _*_ DistributesOverˡ _+_
distribˡ-*-+ = comm+distrʳ⇒distrˡ (cong₂ _+_) *-comm distribʳ-*-+

distrib-*-+ : _*_ DistributesOver _+_
distrib-*-+ = distribˡ-*-+ , distribʳ-*-+

*-assoc : Associative _*_
*-assoc zero    n o = refl
*-assoc (suc m) n o = begin
  (suc m * n) * o     ≡⟨⟩
  (n + m * n) * o     ≡⟨ distribʳ-*-+ o n (m * n) ⟩
  n * o + (m * n) * o ≡⟨ cong (n * o +_) (*-assoc m n o) ⟩
  n * o + m * (n * o) ≡⟨⟩
  suc m * (n * o)     ∎

*-isSemigroup : IsSemigroup _≡_ _*_
*-isSemigroup = record
  { isEquivalence = isEquivalence
  ; assoc         = *-assoc
  ; ∙-cong        = cong₂ _*_
  }

*-1-isCommutativeMonoid : IsCommutativeMonoid _≡_ _*_ 1
*-1-isCommutativeMonoid = record
  { isSemigroup = *-isSemigroup
  ; identityˡ    = *-left-identity
  ; comm        = *-comm
  }

isCommutativeSemiring : IsCommutativeSemiring _≡_ _+_ _*_ 0 1
isCommutativeSemiring = record
  { +-isCommutativeMonoid = +-0-isCommutativeMonoid
  ; *-isCommutativeMonoid = *-1-isCommutativeMonoid
  ; distribʳ              = distribʳ-*-+
  ; zeroˡ                 = *-left-zero
  }

commutativeSemiring : CommutativeSemiring _ _
commutativeSemiring = record
  { _+_                   = _+_
  ; _*_                   = _*_
  ; 0#                    = 0
  ; 1#                    = 1
  ; isCommutativeSemiring = isCommutativeSemiring
  }

import Algebra.RingSolver.Simple as Solver
import Algebra.RingSolver.AlmostCommutativeRing as ACR
module SemiringSolver =
  Solver (ACR.fromCommutativeSemiring commutativeSemiring) _≟_

-- Other properties of _*_

cancel-*-right : ∀ i j {k} → i * suc k ≡ j * suc k → i ≡ j
cancel-*-right zero    zero        eq = refl
cancel-*-right zero    (suc j)     ()
cancel-*-right (suc i) zero        ()
cancel-*-right (suc i) (suc j) {k} eq =
  cong suc (cancel-*-right i j (cancel-+-left (suc k) eq))

cancel-*-right-≤ : ∀ i j k → i * suc k ≤ j * suc k → i ≤ j
cancel-*-right-≤ zero    _       _ _  = z≤n
cancel-*-right-≤ (suc i) zero    _ ()
cancel-*-right-≤ (suc i) (suc j) k le =
  s≤s (cancel-*-right-≤ i j k (cancel-+-left-≤ (suc k) le))

*-mono-≤ : _*_ Preserves₂ _≤_ ⟶ _≤_ ⟶ _≤_
*-mono-≤ z≤n       _   = z≤n
*-mono-≤ (s≤s m≤n) u≤v = +-mono-≤ u≤v (*-mono-≤ m≤n u≤v)

-- DEPRECATED - please use *-mono-≤ instead
_*-mono_ : _*_ Preserves₂ _≤_ ⟶ _≤_ ⟶ _≤_
_*-mono_ = *-mono-≤

*-mono-< : _*_ Preserves₂ _<_ ⟶ _<_ ⟶ _<_
*-mono-< (s≤s z≤n)       (s≤s u≤v) = s≤s z≤n
*-mono-< (s≤s (s≤s m≤n)) (s≤s u≤v) =
  +-mono-< (s≤s u≤v) (*-mono-< (s≤s m≤n) (s≤s u≤v))

*-monoˡ-< : ∀ n → (_* suc n) Preserves _<_ ⟶ _<_
*-monoˡ-< n (s≤s z≤n)       = s≤s z≤n
*-monoˡ-< n (s≤s (s≤s m≤o)) =
  +-monoʳ-< (≤-refl {suc n}) (*-monoˡ-< n (s≤s m≤o))

*-monoʳ-< : ∀ n → (suc n *_) Preserves _<_ ⟶ _<_
*-monoʳ-< zero    (s≤s m≤o) = +-mono-≤ (s≤s m≤o) z≤n
*-monoʳ-< (suc n) (s≤s m≤o) =
  +-mono-≤ (s≤s m≤o) (<⇒≤ (*-monoʳ-< n (s≤s m≤o)))

i*j≡0⇒i≡0∨j≡0 : ∀ i {j} → i * j ≡ 0 → i ≡ 0 ⊎ j ≡ 0
i*j≡0⇒i≡0∨j≡0 zero    {j}     eq = inj₁ refl
i*j≡0⇒i≡0∨j≡0 (suc i) {zero}  eq = inj₂ refl
i*j≡0⇒i≡0∨j≡0 (suc i) {suc j} ()

i*j≡1⇒i≡1 : ∀ i j → i * j ≡ 1 → i ≡ 1
i*j≡1⇒i≡1 (suc zero)    j             _  = refl
i*j≡1⇒i≡1 zero          j             ()
i*j≡1⇒i≡1 (suc (suc i)) (suc (suc j)) ()
i*j≡1⇒i≡1 (suc (suc i)) (suc zero)    ()
i*j≡1⇒i≡1 (suc (suc i)) zero          eq =
  contradiction (trans (*-comm 0 i) eq) λ()

i*j≡1⇒j≡1 : ∀ i j → i * j ≡ 1 → j ≡ 1
i*j≡1⇒j≡1 i j eq = i*j≡1⇒i≡1 j i (trans (*-comm j i) eq)

------------------------------------------------------------------------
-- Properties of _⊔_ and _⊓_

⊔-assoc : Associative _⊔_
⊔-assoc zero    _       _       = refl
⊔-assoc (suc m) zero    o       = refl
⊔-assoc (suc m) (suc n) zero    = refl
⊔-assoc (suc m) (suc n) (suc o) = cong suc $ ⊔-assoc m n o

⊔-left-identity : LeftIdentity 0 _⊔_
⊔-left-identity _ = refl

⊔-right-identity : RightIdentity 0 _⊔_
⊔-right-identity zero    = refl
⊔-right-identity (suc n) = refl

⊔-identity : Identity 0 _⊔_
⊔-identity = ⊔-left-identity , ⊔-right-identity

⊔-comm : Commutative _⊔_
⊔-comm zero    n       = sym $ ⊔-right-identity n
⊔-comm (suc m) zero    = refl
⊔-comm (suc m) (suc n) = cong suc (⊔-comm m n)

-- ∀ x y → (x ⊔ y ≡ x) ⊎ (x ⊔ y ≡ y)
⊔-sel : Selective _⊔_
⊔-sel zero    _    = inj₂ refl
⊔-sel (suc m) zero = inj₁ refl
⊔-sel (suc m) (suc n) with ⊔-sel m n
... | inj₁ m⊔n≡m = inj₁ (cong suc m⊔n≡m)
... | inj₂ m⊔n≡n = inj₂ (cong suc m⊔n≡n)

-- ∀ x → x ⊔ x ≡ x
⊔-idem : Idempotent _⊔_
⊔-idem = sel⇒idem ⊔-sel

⊓-assoc : Associative _⊓_
⊓-assoc zero    _       _       = refl
⊓-assoc (suc m) zero    o       = refl
⊓-assoc (suc m) (suc n) zero    = refl
⊓-assoc (suc m) (suc n) (suc o) = cong suc $ ⊓-assoc m n o

⊓-left-zero : LeftZero 0 _⊓_
⊓-left-zero _ = refl

⊓-right-zero : RightZero 0 _⊓_
⊓-right-zero zero    = refl
⊓-right-zero (suc n) = refl

⊓-zero : Zero 0 _⊓_
⊓-zero = ⊓-left-zero , ⊓-right-zero

⊓-comm : Commutative _⊓_
⊓-comm zero    n       = sym $ ⊓-right-zero n
⊓-comm (suc m) zero    = refl
⊓-comm (suc m) (suc n) = cong suc (⊓-comm m n)

-- ∀ x y → (x ⊓ y ≡ x) ⊎ (x ⊓ y ≡ y)
⊓-sel : Selective _⊓_
⊓-sel zero    _    = inj₁ refl
⊓-sel (suc m) zero = inj₂ refl
⊓-sel (suc m) (suc n) with ⊓-sel m n
... | inj₁ m⊓n≡m = inj₁ (cong suc m⊓n≡m)
... | inj₂ m⊓n≡n = inj₂ (cong suc m⊓n≡n)

-- ∀ x → x ⊓ x ≡ x
⊓-idem : Idempotent _⊓_
⊓-idem = sel⇒idem ⊓-sel

⊓-distribʳ-⊔ : _⊓_ DistributesOverʳ _⊔_
⊓-distribʳ-⊔ (suc m) (suc n) (suc o) = cong suc $ ⊓-distribʳ-⊔ m n o
⊓-distribʳ-⊔ (suc m) (suc n) zero    = cong suc $ refl
⊓-distribʳ-⊔ (suc m) zero    o       = refl
⊓-distribʳ-⊔ zero    n       o       = begin
  (n ⊔ o) ⊓ 0    ≡⟨ ⊓-comm (n ⊔ o) 0 ⟩
  0 ⊓ (n ⊔ o)    ≡⟨ refl ⟩
  0 ⊓ n ⊔ 0 ⊓ o  ≡⟨ ⊓-comm 0 n ⟨ cong₂ _⊔_ ⟩ ⊓-comm 0 o ⟩
  n ⊓ 0 ⊔ o ⊓ 0  ∎

⊓-distribˡ-⊔ : _⊓_ DistributesOverˡ _⊔_
⊓-distribˡ-⊔ = comm+distrʳ⇒distrˡ (cong₂ _⊔_) ⊓-comm ⊓-distribʳ-⊔

⊓-distrib-⊔ : _⊓_ DistributesOver _⊔_
⊓-distrib-⊔ = ⊓-distribˡ-⊔ , ⊓-distribʳ-⊔

⊔-abs-⊓ : _⊔_ Absorbs _⊓_
⊔-abs-⊓ zero    n       = refl
⊔-abs-⊓ (suc m) zero    = refl
⊔-abs-⊓ (suc m) (suc n) = cong suc $ ⊔-abs-⊓ m n

⊓-abs-⊔ : _⊓_ Absorbs _⊔_
⊓-abs-⊔ zero    n       = refl
⊓-abs-⊔ (suc m) (suc n) = cong suc $ ⊓-abs-⊔ m n
⊓-abs-⊔ (suc m) zero    = cong suc $ begin
  m ⊓ m       ≡⟨ cong (_⊓_ m) $ sym $ ⊔-right-identity m ⟩
  m ⊓ (m ⊔ 0) ≡⟨ ⊓-abs-⊔ m zero ⟩
  m           ∎

⊓-⊔-absorptive : Absorptive _⊓_ _⊔_
⊓-⊔-absorptive = ⊓-abs-⊔ , ⊔-abs-⊓

⊔-isSemigroup : IsSemigroup _≡_ _⊔_
⊔-isSemigroup = record
  { isEquivalence = isEquivalence
  ; assoc         = ⊔-assoc
  ; ∙-cong        = cong₂ _⊔_
  }

⊔-0-isCommutativeMonoid : IsCommutativeMonoid _≡_ _⊔_ 0
⊔-0-isCommutativeMonoid = record
  { isSemigroup = ⊔-isSemigroup
  ; identityˡ    = ⊔-left-identity
  ; comm        = ⊔-comm
  }

⊓-isSemigroup : IsSemigroup _≡_ _⊓_
⊓-isSemigroup = record
  { isEquivalence = isEquivalence
  ; assoc         = ⊓-assoc
  ; ∙-cong        = cong₂ _⊓_
  }

⊔-⊓-0-isSemiringWithoutOne : IsSemiringWithoutOne _≡_ _⊔_ _⊓_ 0
⊔-⊓-0-isSemiringWithoutOne = record
  { +-isCommutativeMonoid = ⊔-0-isCommutativeMonoid
  ; *-isSemigroup         = ⊓-isSemigroup
  ; distrib               = ⊓-distrib-⊔
  ; zero                  = ⊓-zero
  }

⊔-⊓-0-isCommutativeSemiringWithoutOne
  : IsCommutativeSemiringWithoutOne _≡_ _⊔_ _⊓_ 0
⊔-⊓-0-isCommutativeSemiringWithoutOne = record
  { isSemiringWithoutOne = ⊔-⊓-0-isSemiringWithoutOne
  ; *-comm               = ⊓-comm
  }

⊔-⊓-0-commutativeSemiringWithoutOne : CommutativeSemiringWithoutOne _ _
⊔-⊓-0-commutativeSemiringWithoutOne = record
  { _+_                             = _⊔_
  ; _*_                             = _⊓_
  ; 0#                              = 0
  ; isCommutativeSemiringWithoutOne =
      ⊔-⊓-0-isCommutativeSemiringWithoutOne
  }

⊓-⊔-isLattice : IsLattice _≡_ _⊓_ _⊔_
⊓-⊔-isLattice = record
  { isEquivalence = isEquivalence
  ; ∨-comm        = ⊓-comm
  ; ∨-assoc       = ⊓-assoc
  ; ∨-cong        = cong₂ _⊓_
  ; ∧-comm        = ⊔-comm
  ; ∧-assoc       = ⊔-assoc
  ; ∧-cong        = cong₂ _⊔_
  ; absorptive    = ⊓-⊔-absorptive
  }

isDistributiveLattice : IsDistributiveLattice _≡_ _⊓_ _⊔_
isDistributiveLattice = record
  { isLattice   = ⊓-⊔-isLattice
  ; ∨-∧-distribʳ = ⊓-distribʳ-⊔
  }

distributiveLattice : DistributiveLattice _ _
distributiveLattice = record
  { _∨_                   = _⊓_
  ; _∧_                   = _⊔_
  ; isDistributiveLattice = isDistributiveLattice
  }

-- Ordering properties of _⊔_ and _⊓_
m⊓n≤m : ∀ m n → m ⊓ n ≤ m
m⊓n≤m zero    _       = z≤n
m⊓n≤m (suc m) zero    = z≤n
m⊓n≤m (suc m) (suc n) = s≤s $ m⊓n≤m m n

m⊓n≤n : ∀ m n → m ⊓ n ≤ n
m⊓n≤n m n = subst (_≤ n) (⊓-comm n m) (m⊓n≤m n m)

m≤m⊔n : ∀ m n → m ≤ m ⊔ n
m≤m⊔n zero    _       = z≤n
m≤m⊔n (suc m) zero    = ≤-refl
m≤m⊔n (suc m) (suc n) = s≤s $ m≤m⊔n m n

n≤m⊔n : ∀ m n → n ≤ m ⊔ n
n≤m⊔n m n = subst (n ≤_) (⊔-comm n m) (m≤m⊔n n m)

⊔-mono-≤ : _⊔_ Preserves₂ _≤_ ⟶ _≤_ ⟶ _≤_
⊔-mono-≤ {x} {y} {u} {v} x≤y u≤v with ⊔-sel x u
... | inj₁ x⊔u≡x rewrite x⊔u≡x = ≤-trans x≤y (m≤m⊔n y v)
... | inj₂ x⊔u≡u rewrite x⊔u≡u = ≤-trans u≤v (n≤m⊔n y v)

⊔-mono-< : _⊔_ Preserves₂ _<_ ⟶ _<_ ⟶ _<_
⊔-mono-< = ⊔-mono-≤

⊓-mono-≤ : _⊓_ Preserves₂ _≤_ ⟶ _≤_ ⟶ _≤_
⊓-mono-≤ {x} {y} {u} {v} x≤y u≤v with ⊓-sel y v
... | inj₁ y⊓v≡y rewrite y⊓v≡y = ≤-trans (m⊓n≤m x u) x≤y
... | inj₂ y⊓v≡v rewrite y⊓v≡v = ≤-trans (m⊓n≤n x u) u≤v

⊓-mono-< : _⊓_ Preserves₂ _<_ ⟶ _<_ ⟶ _<_
⊓-mono-< = ⊓-mono-≤

-- Properties of _⊔_ and _⊓_ and _+_
m⊔n≤m+n : ∀ m n → m ⊔ n ≤ m + n
m⊔n≤m+n m n with ⊔-sel m n
... | inj₁ m⊔n≡m rewrite m⊔n≡m = m≤m+n m n
... | inj₂ m⊔n≡n rewrite m⊔n≡n = n≤m+n m n

m⊓n≤m+n : ∀ m n → m ⊓ n ≤ m + n
m⊓n≤m+n m n with ⊓-sel m n
... | inj₁ m⊓n≡m rewrite m⊓n≡m = m≤m+n m n
... | inj₂ m⊓n≡n rewrite m⊓n≡n = n≤m+n m n

+-distribˡ-⊔ : _+_ DistributesOverˡ _⊔_
+-distribˡ-⊔ zero    y z = refl
+-distribˡ-⊔ (suc x) y z = cong suc (+-distribˡ-⊔ x y z)

+-distribʳ-⊔ : _+_ DistributesOverʳ _⊔_
+-distribʳ-⊔ = comm+distrˡ⇒distrʳ (cong₂ _⊔_) +-comm +-distribˡ-⊔

+-distrib-⊔ : _+_ DistributesOver _⊔_
+-distrib-⊔ = +-distribˡ-⊔ , +-distribʳ-⊔

+-distribˡ-⊓ : _+_ DistributesOverˡ _⊓_
+-distribˡ-⊓ zero    y z = refl
+-distribˡ-⊓ (suc x) y z = cong suc (+-distribˡ-⊓ x y z)

+-distribʳ-⊓ : _+_ DistributesOverʳ _⊓_
+-distribʳ-⊓ = comm+distrˡ⇒distrʳ (cong₂ _⊓_) +-comm +-distribˡ-⊓

+-distrib-⊓ : _+_ DistributesOver _⊓_
+-distrib-⊓ = +-distribˡ-⊓ , +-distribʳ-⊓

------------------------------------------------------------------------
-- Properties of _∸_

0∸n≡0 : LeftZero zero _∸_
0∸n≡0 zero    = refl
0∸n≡0 (suc _) = refl

n∸n≡0 : ∀ n → n ∸ n ≡ 0
n∸n≡0 zero    = refl
n∸n≡0 (suc n) = n∸n≡0 n

∸-+-assoc : ∀ m n o → (m ∸ n) ∸ o ≡ m ∸ (n + o)
∸-+-assoc m       n       zero    = cong (_∸_ m) (sym $ +-right-identity n)
∸-+-assoc zero    zero    (suc o) = refl
∸-+-assoc zero    (suc n) (suc o) = refl
∸-+-assoc (suc m) zero    (suc o) = refl
∸-+-assoc (suc m) (suc n) (suc o) = ∸-+-assoc m n (suc o)

+-∸-assoc : ∀ m {n o} → o ≤ n → (m + n) ∸ o ≡ m + (n ∸ o)
+-∸-assoc m (z≤n {n = n})             = begin m + n ∎
+-∸-assoc m (s≤s {m = o} {n = n} o≤n) = begin
  (m + suc n) ∸ suc o  ≡⟨ cong (λ n → n ∸ suc o) (+-suc m n) ⟩
  suc (m + n) ∸ suc o  ≡⟨ refl ⟩
  (m + n) ∸ o          ≡⟨ +-∸-assoc m o≤n ⟩
  m + (n ∸ o)          ∎

n∸m≤n : ∀ m n → n ∸ m ≤ n
n∸m≤n zero    n       = ≤-refl
n∸m≤n (suc m) zero    = ≤-refl
n∸m≤n (suc m) (suc n) = ≤-trans (n∸m≤n m n) (n≤1+n n)

n≤m+n∸m : ∀ m n → n ≤ m + (n ∸ m)
n≤m+n∸m m       zero    = z≤n
n≤m+n∸m zero    (suc n) = ≤-refl
n≤m+n∸m (suc m) (suc n) = s≤s (n≤m+n∸m m n)

m+n∸n≡m : ∀ m n → (m + n) ∸ n ≡ m
m+n∸n≡m m n = begin
  (m + n) ∸ n  ≡⟨ +-∸-assoc m (≤-refl {x = n}) ⟩
  m + (n ∸ n)  ≡⟨ cong (_+_ m) (n∸n≡0 n) ⟩
  m + 0        ≡⟨ +-right-identity m ⟩
  m            ∎

m+n∸m≡n : ∀ {m n} → m ≤ n → m + (n ∸ m) ≡ n
m+n∸m≡n {m} {n} m≤n = begin
  m + (n ∸ m)  ≡⟨ sym $ +-∸-assoc m m≤n ⟩
  (m + n) ∸ m  ≡⟨ cong (λ n → n ∸ m) (+-comm m n) ⟩
  (n + m) ∸ m  ≡⟨ m+n∸n≡m n m ⟩
  n            ∎

m⊓n+n∸m≡n : ∀ m n → (m ⊓ n) + (n ∸ m) ≡ n
m⊓n+n∸m≡n zero    n       = refl
m⊓n+n∸m≡n (suc m) zero    = refl
m⊓n+n∸m≡n (suc m) (suc n) = cong suc $ m⊓n+n∸m≡n m n

[m∸n]⊓[n∸m]≡0 : ∀ m n → (m ∸ n) ⊓ (n ∸ m) ≡ 0
[m∸n]⊓[n∸m]≡0 zero zero       = refl
[m∸n]⊓[n∸m]≡0 zero (suc n)    = refl
[m∸n]⊓[n∸m]≡0 (suc m) zero    = refl
[m∸n]⊓[n∸m]≡0 (suc m) (suc n) = [m∸n]⊓[n∸m]≡0 m n

[i+j]∸[i+k]≡j∸k : ∀ i j k → (i + j) ∸ (i + k) ≡ j ∸ k
[i+j]∸[i+k]≡j∸k zero    j k = refl
[i+j]∸[i+k]≡j∸k (suc i) j k = [i+j]∸[i+k]≡j∸k i j k

-- TODO: Can this proof be simplified? An automatic solver which can
-- handle ∸ would be nice...
i∸k∸j+j∸k≡i+j∸k : ∀ i j k → i ∸ (k ∸ j) + (j ∸ k) ≡ i + j ∸ k
i∸k∸j+j∸k≡i+j∸k zero j k = begin
  0 ∸ (k ∸ j) + (j ∸ k) ≡⟨ cong (λ x → x + (j ∸ k)) (0∸n≡0 (k ∸ j)) ⟩
  0 + (j ∸ k)           ≡⟨ refl ⟩
  j ∸ k                 ∎
i∸k∸j+j∸k≡i+j∸k (suc i) j zero = begin
  suc i ∸ (0 ∸ j) + j ≡⟨ cong (λ x → suc i ∸ x + j) (0∸n≡0 j) ⟩
  suc i ∸ 0 + j       ≡⟨ refl ⟩
  suc (i + j)         ∎
i∸k∸j+j∸k≡i+j∸k (suc i) zero (suc k) = begin
  i ∸ k + 0  ≡⟨ +-right-identity _ ⟩
  i ∸ k      ≡⟨ cong (λ x → x ∸ k) (sym (+-right-identity _)) ⟩
  i + 0 ∸ k  ∎
i∸k∸j+j∸k≡i+j∸k (suc i) (suc j) (suc k) = begin
  suc i ∸ (k ∸ j) + (j ∸ k) ≡⟨ i∸k∸j+j∸k≡i+j∸k (suc i) j k ⟩
  suc i + j ∸ k             ≡⟨ cong (λ x → x ∸ k) (sym (+-suc i j)) ⟩
  i + suc j ∸ k             ∎

*-distrib-∸ʳ : _*_ DistributesOverʳ _∸_
*-distrib-∸ʳ i zero k = begin
  (0 ∸ k) * i  ≡⟨ cong₂ _*_ (0∸n≡0 k) refl ⟩
  0            ≡⟨ sym $ 0∸n≡0 (k * i) ⟩
  0 ∸ k * i    ∎
*-distrib-∸ʳ i (suc j) zero    = begin i + j * i ∎
*-distrib-∸ʳ i (suc j) (suc k) = begin
  (j ∸ k) * i             ≡⟨ *-distrib-∸ʳ i j k ⟩
  j * i ∸ k * i           ≡⟨ sym $ [i+j]∸[i+k]≡j∸k i _ _ ⟩
  i + j * i ∸ (i + k * i) ∎

im≡jm+n⇒[i∸j]m≡n : ∀ i j m n → i * m ≡ j * m + n → (i ∸ j) * m ≡ n
im≡jm+n⇒[i∸j]m≡n i j m n eq = begin
  (i ∸ j) * m            ≡⟨ *-distrib-∸ʳ m i j ⟩
  (i * m) ∸ (j * m)      ≡⟨ cong₂ _∸_ eq (refl {x = j * m}) ⟩
  (j * m + n) ∸ (j * m)  ≡⟨ cong₂ _∸_ (+-comm (j * m) n) (refl {x = j * m}) ⟩
  (n + j * m) ∸ (j * m)  ≡⟨ m+n∸n≡m n (j * m) ⟩
  n                      ∎

∸-mono : _∸_ Preserves₂ _≤_ ⟶ _≥_ ⟶ _≤_
∸-mono z≤n         (s≤s n₁≥n₂)    = z≤n
∸-mono (s≤s m₁≤m₂) (s≤s n₁≥n₂)    = ∸-mono m₁≤m₂ n₁≥n₂
∸-mono m₁≤m₂       (z≤n {n = n₁}) = ≤-trans (n∸m≤n n₁ _) m₁≤m₂

------------------------------------------------------------------------
-- Properties of ⌊_/2⌋

⌊n/2⌋-mono : ⌊_/2⌋ Preserves _≤_ ⟶ _≤_
⌊n/2⌋-mono z≤n             = z≤n
⌊n/2⌋-mono (s≤s z≤n)       = z≤n
⌊n/2⌋-mono (s≤s (s≤s m≤n)) = s≤s (⌊n/2⌋-mono m≤n)

⌈n/2⌉-mono : ⌈_/2⌉ Preserves _≤_ ⟶ _≤_
⌈n/2⌉-mono m≤n = ⌊n/2⌋-mono (s≤s m≤n)

⌈n/2⌉≤′n : ∀ n → ⌈ n /2⌉ ≤′ n
⌈n/2⌉≤′n zero          = ≤′-refl
⌈n/2⌉≤′n (suc zero)    = ≤′-refl
⌈n/2⌉≤′n (suc (suc n)) = s≤′s (≤′-step (⌈n/2⌉≤′n n))

⌊n/2⌋≤′n : ∀ n → ⌊ n /2⌋ ≤′ n
⌊n/2⌋≤′n zero    = ≤′-refl
⌊n/2⌋≤′n (suc n) = ≤′-step (⌈n/2⌉≤′n n)