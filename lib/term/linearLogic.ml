module Scope = Set.Make (Atom.Scope)
open Index
open Aliases

type nonrec 'a path = [`LinearLogic of 'a] path

open Atom.Aliases

(* Decoration *)
type _ t += Scope : Scope.t -> [`Cons of [`Scope] path] t

(* Multiplicative *)
type _ t +=
  | Atom : _ atom -> [`Cons of [`Atom] path] t
  | One : [`Cons of [`One] path] t
  | Inv : [> ] t -> [`Cons of [`Inv] path] t
  | Bot : [`Cons of [`Bot] path] t
  | MCNJ : [> ] t * [> ] t -> [`Cons of [`MCNJ] path] t
  | MDSJ : [> ] t * [> ] t -> [`Cons of [`MDSJ] path] t

(* Exponential *)
type _ t +=
  | WNot : [> ] t -> [`Cons of [`WNot] path] t
  | OfCo : [> ] t -> [`Cons of [`OfCo] path] t
  | Zero : [`Cons of [`Zero] path] t
  | Top : [`Cons of [`Top] path] t

(* Additive *)
type _ t +=
  | ADSJ : [> ] t * [> ] t -> [`Cons of [`ADSJ] path] t
  | ACNJ : [> ] t * [> ] t -> [`Cons of [`ACNJ] path] t
