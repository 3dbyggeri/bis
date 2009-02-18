# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def t(textile)
    RedCloth.new((textile)).to_html
  end
  
  def build_hierachy_menu
    list = "<ul>"
    BisCode.get_hierachy_root.each do |root_code|
      list += build_hierachy_menu_for(root_code, @bis_code)
    end
    list += "</ul>"
  end
  def build_hierachy_menu_for(current_code, shown_code = nil)
    list = ""
    if shown_code.nil?
      list += content_tag :li do
        result =  content_tag(:p, current_code.full_code, :class => "code")
        result += content_tag(:p, content_tag(:a, current_code.label, {:href => bis_code_url(current_code)}), :class => "label")
      end
      return list
    end
    if shown_code.parents_until_root.include? current_code # expand the tree
      list += content_tag :li do
        result =  content_tag(:p, current_code.full_code, :class => "code")
        result += content_tag(:p, content_tag(:a, current_code.label, {:href => bis_code_url(current_code)}), :class => "label")
      end
      current_code.children.by_full_code.each do |child|
        list += content_tag(:ul, build_hierachy_menu_for(child, shown_code))
      end
    elsif shown_code == current_code
      list += content_tag :li do
        result =  content_tag(:p, current_code.full_code, :class => "code")
        result += content_tag(:p, content_tag(:strong, current_code.label), :class => "label")
      end
      current_code.children.by_full_code.each do |child|
        list += content_tag(:ul, build_hierachy_menu_for(child, shown_code))
      end
    else
      list += content_tag :li do
        result =  content_tag(:p, current_code.full_code, :class => "code")
        result += content_tag(:p, content_tag(:a, current_code.label, {:href => bis_code_url(current_code)}), :class => "label")
      end
    end
    list
  end
end
