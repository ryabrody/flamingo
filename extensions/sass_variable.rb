class SassVariable < Middleman::Extension
  DEFAULT_OPTIONS = {
    style: :compact,
    load_paths: ['assets'],
    syntax: :scss,
    cache: false
  }.freeze

  expose_to_template :sass_variable

  ###
  # sass_variable
  ###

  # Returns variables in ruby which are defined in a specific sass-file.
  # Supported are following Sass Variable Classes:
  # * Literal
  # * MapLiteral
  # * ListLiteral (only two dimensions)
  def sass_variable(file_name, variable_name)
    sass_variables(file_name)[variable_name]
  end

  private

  def sass_file(file_path)
    ::Sass::Engine.for_file("source/stylesheets/#{file_path}.scss", DEFAULT_OPTIONS)
  end

  def sass_variables(file_name)
    {}.tap do |hash|
      sass_file(file_name).to_tree.each do |tree_node|
        next unless tree_node.is_a?(::Sass::Tree::VariableNode)
        hash[tree_node.name] = sass_variable_value(tree_node)
      end
    end
  end

  def sass_variable_value(sass_tree_variable_node)
    if sass_tree_variable_node.expr.is_a?(::Sass::Script::Tree::Literal)
      literal_to_string(sass_tree_variable_node.expr)
    elsif sass_tree_variable_node.expr.is_a?(::Sass::Script::Tree::MapLiteral)
      map_literal_to_open_struct(sass_tree_variable_node.expr)
    elsif sass_tree_variable_node.expr.is_a?(::Sass::Script::Tree::ListLiteral)
      list_literal_to_multi_dimensional_array(sass_tree_variable_node.expr)
    end
  end

  def literal_to_string(literal)
    literal.to_sass.to_s
  end

  def map_literal_to_open_struct(map_literal)
    map_literal.pairs.map do |array|
      OpenStruct.new(
        key: literal_to_string(array[0]),
        value: literal_to_string(array[1])
      )
    end
  end

  def list_literal_to_multi_dimensional_array(list_literal)
    list_literal.elements.map do |element|
      if element.respond_to?(:elements)
        element.elements.map do |literal|
          literal_to_string(literal)
        end
      else
        literal_to_string(element)
      end
    end
  end
end

::Middleman::Extensions.register(:sass_variable, SassVariable)
