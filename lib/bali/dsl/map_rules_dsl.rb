class Bali::Dsl::MapRulesDsl
  attr_accessor :current_rule_class

  def initialize
    @@lock ||= Mutex.new
  end

  # defining rules
  def rules_for(target_class, options_hash = {}, &block)
    @@lock.synchronize do
      self.current_rule_class = Bali::RuleClass.new(target_class)

      parent_class = options_hash[:inherits] || options_hash["inherits"]
      if parent_class
        # in case there is inherits specification
        parent_is_class = parent_class.class
        raise Bali::DslError, 'inherits must take a class' unless parent_is_class
        rule_class_from_parent = Bali::Integrator::RuleClass.for(parent_class)
        raise Bali::DslError, "not yet defined a rule class for #{parent_class}" if rule_class_from_parent.nil?
        self.current_rule_class = rule_class_from_parent.clone(target_class: target_class)
      end

      Bali::Dsl::RulesForDsl.new(self).instance_eval(&block)

      # done processing the block, now add the rule class
      Bali::Integrator::RuleClass.add(self.current_rule_class)
    end
  end

  # subtarget_class is the subtarget's class definition
  # field_name is the field that will be consulted when instantiated object of this class is passed in can? or cant?
  def roles_for(subtarget_class, field_name)
    Bali::TRANSLATED_SUBTARGET_ROLES[subtarget_class.to_s] = field_name
    nil
  end

  def role(*params)
    raise Bali::DslError, "role block must be within rules_for block"
  end

  def can(*params)
    raise Bali::DslError, "can block must be within role block"
  end

  def cant(*params)
    raise Bali::DslError, "cant block must be within role block"
  end

  def can_all(*params)
    raise Bali::DslError, "can_all block must be within role block"
  end

  def clear_rules
    raise Bali::DslError, "clear_rules must be called within role block"
  end

  def cant_all(*params)
    raise Bali::DslError, "cant_all block must be within role block"
  end
end
