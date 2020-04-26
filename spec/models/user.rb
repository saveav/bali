class User
  include Bali::Authorizer

  attr_accessor :role
  attr_accessor :friends

  def initialize(role = nil)
    @role = role
    @friends = []
  end

  def self.no_more_beta?
    true
  end
end