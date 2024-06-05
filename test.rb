require_relative("config/environment.rb")

class Node
  attr_reader :model_klass
  attr_accessor :edges
  def initialize(model_klass)
    @model_klass = model_klass
  end

  def associations
    @model_klass.reflect_on_all_associations
  end

  def decorate
    NodeDecorator.new(self)
  end
end

class NodeDecorator
  attr_reader :node
  def initialize(node)
    @node = node
  end

  def to_entity
    columns_strs = node.model_klass.columns.map do |column|
      "#{column.type} #{column.name}"
    end
    <<~ENTITY
      #{node.model_klass.name.upcase} {
      \t#{columns_strs.join("\n\t")}
      }
    ENTITY
  end
end

class Edge
  attr_reader :from, :to, :ltr_type
  attr_accessor :rtl_type
  def initialize(from, to, ltr_type:, rtl_type: nil)
    @from = from
    @to = to
    @ltr_type = ltr_type
    @rtl_type = rtl_type
  end

  def decorate
    EdgeDecorator.new(self)
  end
end

class EdgeDecorator
  attr_reader :edge
  def initialize(edge)
    @edge = edge
  end

  def to_relation
    from_entity_name = edge.from.model_klass.name.upcase
    to_entity_name = edge.to.model_klass.name.upcase
    rtl_indicator = mermaid_relation_for(edge.rtl_type, side: :left)
    ltr_indicator = mermaid_relation_for(edge.ltr_type, side: :right) || "||"
    <<~RELATION
      #{from_entity_name} #{rtl_indicator}--#{ltr_indicator} #{to_entity_name} : \"\"
    RELATION
  end

  def mermaid_relation_for(type, side:)
    case type
    when :belongs_to
      "||"
    when :has_one
      "||"
    when :has_many
      side == :left ? "}o" : "o{"
    else
      raise "Unknown association type: #{type}"
    end
  end
end

Rails.application.eager_load!

edges = []
model_klasses = ApplicationRecord.descendants
nodes = model_klasses.map { |model_klass| Node.new(model_klass) }
nodes.each do |node|
  node.associations.each do |association|
    # TODO: Handle polymorphic associations
    # Perhaps giving users a way to specify what classes can be associated
    # and warning them if they are not specified.
    next if association.polymorphic?

    associated_node = nodes.detect { |n| n.model_klass.name == association.klass.name }
    raise "Node not found for #{association.klass.name}" unless associated_node

    inverse_edge = edges.detect { |edge| edge.from == associated_node && edge.to == node }
    if inverse_edge
      puts "Found inverse edge: #{node.model_klass.name} -> #{associated_node.model_klass.name}: #{association.macro}"
      inverse_edge.rtl_type = association.macro
    else
      puts "Creating edge: #{node.model_klass.name} -> #{associated_node.model_klass.name}: #{association.macro}"
      edges << Edge.new(node, associated_node, ltr_type: association.macro)
    end
  end
end

File.open("test.md", "w") do |f|
  f.write("```mermaid\n")
  f.write("erDiagram\n")
  nodes.each do |node|
    f.write(node.decorate.to_entity)
    f.write("\n")
  end

  edges.each do |edge|
    f.write(edge.decorate.to_relation)
  end
end

