open Index
open Aliases

type nonrec 'a path = [`LambdaCalculus of 'a] path

type _ t +=
  | Abs : {to_recv: [> ] t; process: [> ] t} -> [`Cons of [`Abs] path] t
  | App : {of_recv: [> ] t; to_send: [> ] t} -> [`Cons of [`App] path] t
