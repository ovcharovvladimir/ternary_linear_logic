open Index
open Aliases

type nonrec 'a path = [`Ternary of 'a] path

type _ t +=
  | MCNJ :
      { clock08: [> ] t
      ; clock12: [> ] t
      ; clock04: [> ] t }
      -> [`Cons of [`MCNJ] path] t

type _ t +=
  | MDSJ :
      { clock08: [> ] t
      ; clock12: [> ] t
      ; clock04: [> ] t }
      -> [`Cons of [`MDSJ] path] t
