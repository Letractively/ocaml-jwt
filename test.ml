open Json_type
open Json_io

let (@@) f g = f g
let (+>) f g = g f

let () =
  let exp =
    Unix.time () +>
      string_of_float +>
      Str.global_replace (Str.regexp "\\.[0-9]*") "" in
  let payload = Build.objekt [
    ("iss", Build.string "test");
    ("exp", Build.string exp);
    ("claim", Build.string "insanity");
  ] in
  let key = Jwt.Key "secret" in
  let jwt = Jwt.encode payload key in
  print_endline jwt;
  let decoded = Jwt.decode jwt key in
  print_endline @@ string_of_json decoded
;;
