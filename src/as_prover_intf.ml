module type Basic = sig
  type ('a, 'f, 's) t

  type 'f field

  include Monad_let.S3 with type ('a, 'f, 's) t := ('a, 'f field, 's) t

  val run :
    ('a, 'f field, 's) t -> ('f field Cvar.t -> 'f field) -> 's -> 's * 'a

  val get_state : ('s, 'f field, 's) t

  val set_state : 's -> (unit, 'f field, 's) t

  val modify_state : ('s -> 's) -> (unit, 'f field, 's) t

  val map2 :
       ('a, 'f field, 's) t
    -> ('b, 'f field, 's) t
    -> f:('a -> 'b -> 'c)
    -> ('c, 'f field, 's) t

  val read_var : 'f field Cvar.t -> ('f field, 'f field, 's) t

  val read :
       ('var, 'value, 'f field, _) Types.Typ.t
    -> 'var
    -> ('value, 'f field, 'prover_state) t

  module Provider : sig
    type ('a, 'f, 's) t

    val run :
         ('a, 'f field, 's) t
      -> string list
      -> ('f field Cvar.t -> 'f field)
      -> 's
      -> Request.Handler.t
      -> 's * 'a
  end

  module Handle : sig
    val value :
      ('var, 'value) Handle.t -> ('value, 'f field, 's) Types.As_prover.t
  end
end

module type S = sig
  module Types : Types.Types

  include
    Basic
    with type ('a, 'f, 's) t = ('a, 'f, 's) Types.As_prover.t
     and type ('a, 'f, 's) Provider.t = ('a, 'f, 's) Types.Provider.t

  module Ref : sig
    type 'a t

    val create :
         ('a, 'f field, 'prover_state) Types.As_prover.t
      -> ('a t, 'prover_state, 'f field) Types.Checked.t

    val get : 'a t -> ('a, 'f field, _) Types.As_prover.t

    val set : 'a t -> 'a -> (unit, 'f field, _) Types.As_prover.t
  end
end

module type Extended = sig
  type field

  module Types : Types.Types

  include
    S
    with module Types := Types
    with type 'f field := field
     and type ('a, 'f, 's) t := ('a, 'f, 's) Types.As_prover.t

  type ('a, 's) t = ('a, field, 's) Types.As_prover.t
end
