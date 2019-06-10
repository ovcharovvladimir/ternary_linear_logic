open Index
open Aliases

type nonrec 'a path = [`PiCalculus of 'a] path

type _ t +=
  | Send :
      { of_recv: [> ] t
      ; to_send: [> ] t
      ; process: [> ] t }
      -> [`Cons of [`Send] path] t
  | Recv :
      { of_send: [> ] t
      ; to_recv: [> ] t
      ; process: [> ] t }
      -> [`Cons of [`Recv] path] t
