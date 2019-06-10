type 'a t =
  | Code : int -> [< `Point | `Path] t
  | Word : string -> [< `Point | `Path] t
  | Star : [< `Space] t
  | Sort : [< `Space] t * [< `Point] t -> [< `Space | `Sort] t
  | Path : [< `Path] t * [< `Point] t -> [< `Path] t
  | Poly : [< `Point | `Path | `Space | `Sort] t -> [`Poly] t
  | Scope : [< `Point | `Path | `Sort] t -> [`Scope] t
  | Snoc : [`Poly] t * [`Poly] t -> [`Poly] t

module Aliases = struct
  type 'a atom = ([< `Point | `Path] as 'a) t

  type 'a scope = ([< `Point | `Path | `Sort] as 'a) t
end

let rec conv : [`Poly] t -> [`Poly] t = function
  | Poly (Sort (a, b)) -> Snoc (conv (Poly a), conv (Poly b))
  | Poly (Path (a, b)) -> Snoc (conv (Poly a), conv (Poly b))
  | Poly a -> Poly a
  | _ -> failwith "fixme"

let compare : [`Poly] t -> [`Poly] t -> int =
  let ( && ) a b = match (a, b) with 0, a -> a | a, _ -> a in
  let rec f a b =
    match (conv a, conv b) with
    | Poly Star, _ -> 0
    | _, Poly Star -> 0
    | Poly (Code a), Poly (Code b) -> compare a b
    | Poly (Word a), Poly (Word b) -> compare a b
    | Poly (Code _), Poly (Word _) -> -1
    | Poly (Word _), Poly (Code _) -> 1
    | Snoc (a, b), Snoc (c, d) -> f b d && f a c
    | _, Snoc _ -> -1
    | Snoc _, _ -> 1
    | _ -> failwith "fixme"
    (*
    | Poly (Path (a, b)), Poly (Path (c, d)) ->
        f (Poly b) (Poly d) && f (Poly a) (Poly c)
    | Poly (Sort (a, b)), Poly (Sort (c, d)) ->
        f (Poly b) (Poly d) && f (Poly a) (Poly c)
    | Poly (Path (a, b)), Poly (Sort (c, d)) ->
        f (Poly b) (Poly d) && f (Poly a) (Poly c)
    | Poly (Sort (a, b)), Poly (Path (c, d)) ->
        f (Poly b) (Poly d) && f (Poly a) (Poly c)
    | _, Poly (Sort _) -> -1
    | _, Poly (Path _) -> -1
    | Poly (Sort _), _ -> 1
    | Poly (Path _), _ -> 1
*)
  in
  f

module Scope = struct
  type 'a q = 'a t

  type t = [`Scope] q

  let compare (Scope a) (Scope b) = compare (Poly a) (Poly b)
end
