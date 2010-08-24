class Chef
  class Recipe

    def wiki_table_attribs
      style = "style=font-size:12pt; text-align:center;"
      attribs = "columnTypes=S,S,S|"
      attribs << "|columnAttributes='#{style}','#{style}','#{style}'"
      attribs << "|enableHighlighting=true|highlightColor=silver"
      attribs << "|border=2|align=center|cellspacing=1|cellpadding=1"
      attribs << ""
    end

  end
end

