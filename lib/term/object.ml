open LinearLogic
open Index
open Aliases

type nonrec 'a path = [`Object of 'a] path

open Atom.Aliases

type _ t += Sense : _ atom * [< `Space] Atom.t -> [`Cons of [`Sense] path] t
