require_relative "bali/version"

begin
  require "rails"
  require "rails/generators"
rescue LoadError => e
  # ignores
end

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/generators")
loader.ignore("#{__dir__}/bali/rails")
loader.setup

module Bali
  # {
  #   User: :roles,
  #   AdminUser: :admin_roles
  # }
  TRANSLATED_SUBTARGET_ROLES = {}

  extend self

  def config
    @config ||= Bali::Config.new
  end

  def configure
    yield config
  end

  if defined? Rails
    require "bali/railtie"
    require "bali/rails/action_controller"
    require "bali/rails/action_view"
    require "bali/rails/active_record"
  end
end

loader.eager_load
