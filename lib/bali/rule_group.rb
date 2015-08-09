class Bali::RuleGroup
  # the target class
  attr_accessor :target

  # the alias name for the target
  attr_accessor :alias_tgt

  # the user to which this rule group is applied
  attr_accessor :subtarget

  # what can be done and what cannot be done
  attr_accessor :cans, :cants

  # if set to true then the subtarget can do anything
  attr_accessor :zeus
  alias :zeus? :zeus

  # allowing "general user" and :general_user to route to the same rule group
  def self.canon_name(subtarget)
    if subtarget.is_a?(String)
      return subtarget.gsub(" ", "_").to_sym
    else
      return subtarget
    end
  end

  def initialize(target, alias_tgt, subtarget)
    self.target = target
    self.alias_tgt = alias_tgt
    self.subtarget = Bali::RuleGroup.canon_name(subtarget)

    self.cans = {}
    self.cants = {}
  end

  def add_rule(rule)
    # operation cannot be defined twice
    operation = rule.operation.to_sym

    raise Bali::DslError, "Rule is defined twice for operation #{operation}" if self.cants[operation] && self.cans[operation]

    if rule.is_discouragement?
      self.cants[rule.operation.to_sym] = rule
    else
      self.cans[rule.operation.to_sym] = rule
    end
  end

  def get_rule(auth_val, operation)
    rule = nil
    case auth_val
    when :can, "can"
      rule = self.cans[operation.to_sym]
    when :cant, "cant"
      rule = self.cants[operation.to_sym]
    else
      raise Bali::DslError, "Undefined operation: #{auth_val}"
    end

    rule
  end

  # all rules
  def rules
    self.cans.values + self.cants.values
  end
end
