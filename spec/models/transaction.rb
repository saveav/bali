class Transaction < ActiveRecord::Base
  alias :settled? :is_settled
end
