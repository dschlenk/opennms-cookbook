module XmlHelpers
  def xml_to_hash(node)
    {
      name: node.name,
      attributes: node.attribute_nodes
                      .sort_by(&:name)
                      .to_h { |a| [a.name, a.value] },
      text: node.element_children.empty? ? node.text.strip : nil,
      children: node.element_children.map { |c| xml_to_hash(c) },
    }
  end

  module_function :xml_to_hash
end
