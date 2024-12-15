(* This is a file to generate feeds.yaml from existing articles *)

type metadata =
  { title: string;
    issued: string;
    abstract: string;
    file_path: string;
  }

let posts_dir = "posts/"

let rec take_while p = function
  | [] -> []
  | hd :: tl when p hd -> hd :: take_while p tl
  | _ :: _ -> []

let rec drop_while p = function
  | [] -> []
  | hd :: tl when p hd -> drop_while p tl
  | l -> l

let metadata_lines lines =
  lines
  |> drop_while (String.starts_with ~prefix:"---")
  |> take_while (fun s -> not (String.starts_with ~prefix:"---" s))

let strip_prefix ~prefix s =
  let prefix_len = String.length prefix in
  let s_len = String.length s in
  String.sub s prefix_len (s_len - prefix_len)

let get_file_metada file_path =
  let path = posts_dir ^ file_path in
  let contents = In_channel.with_open_bin path In_channel.input_all in
  let lines =
    contents
    |> String.split_on_char '\n'
    |> metadata_lines
  in

  let title =
    lines
    |> List.find (String.starts_with ~prefix:"title: ")
    |> strip_prefix ~prefix:"title: "
  in
  let abstract =
    lines
    |> List.find (String.starts_with ~prefix:"description: ")
    |> strip_prefix ~prefix:"description: "
  in
  let issued = String.sub path 0 10 in

  { title; issued; abstract; file_path }

let to_metadata_lines { title; issued; abstract; file_path } =
  let path = Filename.remove_extension file_path in
  let url = Printf.sprintf "https://chshersh.com/blog/%s.html" path in
  [
    Printf.sprintf "- title: %s" title;
    Printf.sprintf "  issued: %s" issued;
    Printf.sprintf "  URL: %s" url;
    Printf.sprintf "  abstract: %s" abstract;
  ]

let () =
  Printexc.record_backtrace true;

  let files = Sys.readdir "posts/" in
  Array.sort (Fun.flip String.compare) files;
  let metadata = Array.map get_file_metada files in
  let metadata_lines =
    metadata
    |> Array.to_list
    |> List.concat_map to_metadata_lines
  in
  let lines = "title: chshersh.com" :: "references:" :: metadata_lines in
  let feeds = String.concat "\n" lines in

  Out_channel.with_open_bin
    "feeds.yaml"
    (fun channel -> Out_channel.output_string channel feeds)
