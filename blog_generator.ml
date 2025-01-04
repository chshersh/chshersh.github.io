(* This is a file to generate feeds.yaml from existing articles *)

type metadata =
  { title: string;
    created_at: string;
    abstract: string;
    file_path: string;
    is_draft: bool;
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
  let is_draft =
    lines
    |> List.find_opt (String.starts_with ~prefix:"draft: ")
    |> Option.is_some
  in

  let created_at = String.sub file_path 0 10 in

  { title; created_at; abstract; file_path; is_draft }

let to_metadata_lines { title; created_at; abstract; file_path; is_draft } =
  if is_draft then [] else
  let path = Filename.remove_extension file_path in
  let url = Printf.sprintf "https://chshersh.com/blog/%s.html" path in
  [
    Printf.sprintf "- title: %s" title;
    Printf.sprintf "  created_at: %s" created_at;
    Printf.sprintf "  URL: %s" url;
    Printf.sprintf "  abstract: %s" abstract;
  ]

let generate_feeds metadata =
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


let elm_header =
  [
    {elm|module Model.Blog exposing (..)|elm};
    {elm||elm};
    {elm|type alias T =|elm};
    {elm|    { title : String|elm};
    {elm|    , createdAt : String|elm};
    {elm|    , path : String|elm};
    {elm|    }|elm};
    {elm||elm};
    {elm|mkPath : T -> String|elm};
    {elm|mkPath article =|elm};
    {elm|    "/blog/" ++ article.path ++ ".html"|elm};
    {elm||elm};
    {elm|totalArticles : Int|elm};
    {elm|totalArticles = List.length articles|elm};
    {elm||elm};
    {elm|articles : List T|elm};
    {elm|articles =|elm};
  ]

(* Format date like 2024-12-05 as "December 31st, 2024" *)
let fmt_date iso_date =
  Scanf.sscanf iso_date "%4d-%2d-%2d" (fun year month day ->
    let suffix = match day with
      | 1 | 21 | 31 -> "st"
      | 2 | 22 -> "nd"
      | 3 | 23 -> "rd"
      | _ -> "th"
    in
    let month = match month with
      | 1 -> "January"
      | 2 -> "February"
      | 3 -> "March"
      | 4 -> "April"
      | 5 -> "May"
      | 6 -> "June"
      | 7 -> "July"
      | 8 -> "August"
      | 9 -> "September"
      | 10 -> "October"
      | 11 -> "November"
      | 12 -> "December"
      | _ -> "unknown"
    in
    Printf.sprintf "%s %d%s, %d" month day suffix year
  )

let to_elm_lines i { title; created_at; abstract; file_path; is_draft = _ } =
  let separator = if i = 0 then "[" else "," in
  let path = Filename.remove_extension file_path in
  let created_at = fmt_date created_at in
  [
    Printf.sprintf {|    %s { title = %s|} separator title;
    Printf.sprintf {|      , createdAt = "%s"|} created_at;
    Printf.sprintf {|      , path = "%s"|} path;
    "      }";
  ]

let generate_elm metadata =
  let elm_lines =
    metadata
    |> Array.to_list
    |> List.filter (fun {is_draft; _} -> not is_draft)
    |> List.mapi to_elm_lines
    |> List.flatten
  in
  let lines = elm_header @ elm_lines @ ["    ]"] in
  let elm_blog = String.concat "\n" lines in

  Out_channel.with_open_bin
    "src/Model/Blog.elm"
    (fun channel -> Out_channel.output_string channel elm_blog)

let () =
  Printexc.record_backtrace true;

  let files = Sys.readdir "posts/" in
  Array.sort (Fun.flip String.compare) files;
  let metadata = Array.map get_file_metada files in

  generate_feeds metadata;
  generate_elm metadata
