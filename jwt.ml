(*
  jwt.ml

  Copyright (c) 2012 - by Masaki WATANABE <lambda.watanabe@gmail.com>

  Licence: GPL
*)

open Cryptokit
open Json_type
open Json_io

exception Jwt_error of string

let (@@) f g = f g

type key = Key of string

type algorithm =
  | HS256
;;

let string_of_algo = function
  | HS256 -> "HS256"
;;

let algo_of_string = function
  | "HS256" -> HS256
  | _ -> raise @@ Jwt_error "algorithem not supported"
;;

let get_signature algo key str =
  match algo, key with
    | HS256, Key key ->
      let hash = MAC.hmac_sha256 key in
      hash#add_string str;
      hash#result
;;

let base64url_encode str =
  let trans = Base64.encode_compact_pad () in
  trans#put_string str;
  trans#finish;
  Str.global_replace (Str.regexp "=") "" @@ trans#get_string
;;

let base64url_decode str =
  let trans = Base64.decode () in
  trans#put_string str;
  trans#finish;
  trans#get_string
;;

let encode ?(algo=HS256) payload key =
  let header = Build.objekt [
    ("typ", Build.string "JWT");
    ("alg", Build.string (string_of_algo algo));
  ] in
  let segments = [
    base64url_encode @@ string_of_json ~compact:true header;
    base64url_encode @@ string_of_json ~compact:true payload;
  ] in
  let signing_input = String.concat "." segments in
  let signature = get_signature algo key signing_input in
  let segments = segments @ [base64url_encode signature] in
  String.concat "." segments
;;

let algo_of_json_header = function
  | Object alist ->
    (try
       match List.assoc "alg" alist with
	 | String algo_name -> algo_of_string algo_name
	 | _ -> raise @@ Jwt_error "Invalid header: property alg not string"
     with
	 Not_found -> raise @@ Jwt_error "Invalid header: property alg not found")
  | _ -> raise @@ Jwt_error "Invalid header format"
;;

let decode ?(verify=true) jwt key =
  match Str.split (Str.regexp "\\.") jwt with
    | header_segment :: payload_segment :: crypto_segment :: rest ->
      let signing_input = String.concat "." [header_segment; payload_segment] in
      let header = json_of_string @@ base64url_decode header_segment in
      let payload = json_of_string @@ base64url_decode payload_segment in
      let signature = base64url_decode crypto_segment in
      let algo = algo_of_json_header header in
      if verify && get_signature algo key signing_input <> signature then
	raise @@ Jwt_error "Signature verification failed"
      ;
      payload
    | _ -> raise @@ Jwt_error "Not enough segments"
;;

