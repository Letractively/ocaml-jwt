(**
  jwt.mli

  Copyright (c) 2012 - by Masaki WATANABE <lambda.watanabe@gmail.com>

  Licence: GPL
*)
exception Jwt_error of string

type key = Key of string
(** secret key *)

type algorithm = HS256
(** now supporting hmac_sha256 only *)

val encode : ?algo:algorithm -> Json_type.t -> key -> string
(** [encode algorithm payload_json secret_key] returns a JWT string

    [algorithm]
    default hmac_sha256. Now only hmac_sha256 is suppoted.

    [payload_json]
    json object to encode.

    [key]
    secret key phrase.
*)
  
val decode : ?verify:bool -> string -> key -> Json_type.t
(** [decode verify jwt secret_key] return payload_json object

    [verify]
    If verify is set to true, validates signature of jwt. And raise [Jwt_error] if failed.
    If verify is set to false, skips validation and just returns payload json only.
    default set true.

    [jwt]
    Json Web Token.

    [key]
    secret key phrase.
*)
