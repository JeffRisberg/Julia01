#=
HTMLParse:
- Julia version: 1.6.0
- Author: jeff
- Date: 2021-03-11
=#

using Genie, Genie.Renderer, Gumbo, DataStructures

import Base.replace

function replace(a, b, c)
    replace(a, b => c)
end


const NORMAL_ELEMENTS = [ :html, :head, :body, :title, :style, :address, :article, :aside, :footer,
                          :header, :h1, :h2, :h3, :h4, :h5, :h6, :hgroup, :nav, :section,
                          :dd, :div, :dl, :dt, :figcaption, :figure, :li, :main, :ol, :p, :pre, :ul, :span,
                          :a, :abbr, :b, :bdi, :bdo, :cite, :code, :data, :dfn, :em, :i, :kbd, :mark,
                          :q, :rp, :rt, :rtc, :ruby, :s, :samp, :small, :spam, :strong, :sub, :sup, :time,
                          :u, :var, :wrb, :audio, :map, :void, :embed, :object, :canvas, :noscript, :script,
                          :del, :ins, :caption, :col, :colgroup, :table, :tbody, :td, :tfoot, :th, :thead, :tr,
                          :button, :datalist, :fieldset, :form, :label, :legend, :meter, :optgroup, :option,
                          :output, :progress, :select, :textarea, :details, :dialog, :menu, :menuitem, :summary,
                          :slot, :template, :blockquote, :center]
const VOID_ELEMENTS   = [:base, :link, :meta, :hr, :br, :area, :img, :track, :param, :source, :input]
const BOOL_ATTRIBUTES = [:checked, :disabled, :selected]


const FILE_EXT      = ".flax.jl"
const TEMPLATE_EXT  = ".flax.html"
const JSON_FILE_EXT = ".json.jl"
const MARKDOWN_FILE_EXT = ".md"

const SUPPORTED_HTML_OUTPUT_FILE_FORMATS = [TEMPLATE_EXT, MARKDOWN_FILE_EXT]

const HTMLString = String
const JSONString = String

task_local_storage(:__vars, Dict{Symbol,Any}())


"""
    read_template_file(file_path::String) :: String
Reads `file_path` template from disk.
"""
function read_template_file(file_path::String) :: String
  html = String[]
  open(file_path) do f
    for line in enumerate(eachline(f))
      push!(html, parse_tags(line))
    end
  end

  join(html, "\n")
end


"""
    parse_tags(line::Tuple{Int64,String}, strip_close_tag = false) :: String
Parses special Flax tags.
"""
function parse_tags(line::Tuple{Int64,String}, strip_close_tag = false) :: String
  code = line[2]

  code = replace(code, "<%", """<script type="julia/eval">""")
  code = replace(code, "%>", strip_close_tag ? "" : """</script>""")

  code
end


"""
    parse_template(file_path::String; partial = true) :: String
Parses a HTML file into a `string` of Flax code.
"""
function parse_template(file_path::String; partial = true) :: String
  htmldoc = read_template_file(file_path) |> Gumbo.parsehtml
  parse_tree(htmldoc.root, "", 0, partial = partial)
end


"""
    parse_tree(elem, output, depth; partial = true) :: String
Parses a Gumbo tree structure into a `string` of Flax code.
"""
function parse_tree(elem, output, depth; partial = true) :: String
  if isa(elem, HTMLElement)

    tag_name = lowercase(string(tag(elem)))
    invalid_tag = partial && (tag_name == "html" || tag_name == "head" || tag_name == "body")

    if tag_name == "script" && in("type", collect(keys(attrs(elem))))

      if attrs(elem)["type"] == "julia/eval"
        if ! isempty(children(elem))
          output *= repeat("\t", depth) * string(children(elem)[1].text) * " \n"
        end
      end

    else

      output *= repeat("\t", depth) * ( ! invalid_tag ? "Flax.$(tag_name)(" : "Flax.skip_element(" )

      attributes = String[]
      for (k,v) in attrs(elem)
        x = v

        if startswith(v, "<\$") && endswith(v, "\$>")
          v = (replace(replace(replace(v, "<\$", ""), "\$>", ""), "'", "\"") |> strip)
          x = v
          v = "\$($v)"
        end

        if in(Symbol(lowercase(k)), BOOL_ATTRIBUTES)
          if x == true || x == "true" || x == :true || x == ":true" || x == ""
            push!(attributes, ":$(Symbol(k)) => \"$k\"") # boolean attributes can have the same value as the attribute -- or be empty
          end
        else
          push!(attributes, """Symbol("$k") => "$v" """)
        end
      end

      output *= join(attributes, ", ") * ") "
      # end

      inner = ""
      if ! isempty(children(elem))
        children_count = size(children(elem))[1]

        output *= " do;[ \n"

        idx = 0
        for child in children(elem)
          idx += 1
          inner *= parse_tree(child, "", depth + 1, partial = partial)
          if idx < children_count
            if isa(child, HTMLText) ||
                ( isa(child, HTMLElement) && ( ! in("type", collect(keys(attrs(child)))) || ( in("type", collect(keys(attrs(child)))) && (attrs(child)["type"] != "julia/eval") ) ) )
                ! isempty(inner) && (inner = repeat("\t", depth) * inner * " \n")
            end
          end
        end
        ! isempty(inner) && (output *= inner * "\n " * repeat("\t", depth))

        output *= "]end \n"
      end
    end

  elseif isa(elem, HTMLText)
    content = replace(elem.text, r"<:(.*):>", (x) -> replace(replace(x, "<:", ""), ":>", "") |> strip |> string )
    output *= repeat("\t", depth) * "\"$(content)\""
  end

  # @show output
  output
end


a = read_template_file("simple_page.html")
println(a)

b = parse_template("simple_page.html")
println(b)
