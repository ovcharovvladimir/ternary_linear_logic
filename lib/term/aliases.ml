type 'a path = [`TernaryLinearLogic of [`Term of 'a]]

type ('a, 'b, 'c) stc =
  [> `Subterm of [> `Cons of 'a] | `Components of 'b] as 'c

(*

type nonrec 'a path = [`LinearLogic of 'a] path

type _ t +=
  | MCNJ :
      ([< `MCNJ], 'a, _) stc t * ([< `MCNJ], 'a, _) stc t
      -> [ `Components of 'a
         | `Arity of [`Bin]
         | `Commutative of [`Yes]
         | `Associative of [`Yes]
         | `Kind of [`Multiplicative]
         | `Class of [`Conjunction]
         | `Subterm of [> `Cons of [< `MCNJ | `MDSJ]
                       | `Superterm of [> `Cons of [< `MCNJ]] ]
         | `Superterm of [> `Cons of [< `MCNJ ] ]
         | `Name of [> `multiplicative_conjunction_operator | `multiply]
         | `Cons of [`MCNJ] ]
         t

*)
