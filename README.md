# Bali

[ ![Codeship Status for saveav/bali](https://codeship.com/projects/d2f3ded0-20cf-0133-e425-0eade5a669ff/status?branch=master)](https://codeship.com/projects/95727)

Bali is a powerful, framework-agnostic, thread-safe Ruby language authorization library. It is a universal authorization library, in the sense that it does not assume you to use specific Ruby library/gem/framework in order for successful use of this gem.

Bali is short for Bulwark Authorization Library.

## Installation

It can be installed directly by using bundler's install:

    $ gem install bali

Otherwise, if you are using a framework such as Rails, you can add this into your gemfile:

```ruby
gem 'bali'
```

And then execute:

    $ bundle

## Usage

### First things first: defining rules

Rule in Bali is the law determining whether a user (called `subtarget`) can do or perform specific operation on a target (which is your resource/model).

```ruby
  Bali.map_rules do
    rules_for My::Transaction, as: :transaction do
      describe(:supreme_user) { can_all }
      describe :admin_user do
        can_all
        # a more specific rule would be executed even if can_all is present
        can :cancel, 
          if: proc { |record| record.payment_channel == "CREDIT_CARD" && 
                              !record.is_settled? }
      end
      describe "general user", can: [:update, :edit], cant: [:delete]
      describe "finance user" do
        can :update, :delete, :edit
        can :delete, if: proc { |record| record.is_settled? }
      end # finance_user description
      describe :guest { cant_all }
      describe nil { cant_all }
    end # rules_for
  end
```

You may or may not assign an alias name (`as`). Make sure to keep it unique had you decided to give alias name to your rules group.

### Authorization

Say:

```ruby
class My::Transaction
  include Bali::Objector

  attr_accessor :is_settled
  attr_accessor :payment_channel

  alias :is_settled? :is_settled
end

class My::Employee
  include Bali::Objector

  # working experience in the company
  attr_accessor :exp_years
end
```

Assuming that there exist a variable `transaction` which is an instance of `My::Transaction`, we can query about whether the subtarget is granted to perform certain operation:

```ruby
transaction.cant?(:general_user, :delete)      # => true
transaction.can("general user", :update)       # => true
transaction.can?(:finance_user, :delete)       # depend on context
transaction.can?(:monitoring_user, :view)      # => true
transaction.can?("monitoring user", :view)     # => true
transaction.can?(:admin_user, :cancel)         # depend on context
transaction.can?(:supreme_user, :cancel)       # => true
transaction.can?(:guest, :view)                # => false
transaction.can?(:undefined_subtarget, :see)   # => false
transaction.cant?(:undefined_subtarget, :new)  # => true
```

If a rule is depending on a certain context, then the context will be evaluated to determine whether the subtarget is authorized or not.

In the above example, deletion of `transaction` is only allowed if the subtarget is a "finance user" and, the `transaction` itself is already settled.

Also, asking `can?` on which the subtarget is not yet defined will always return `false`. In the example above, as `undefined_subtarget` is by itself has never been defined in `describe` under `My::Transaction` rule class, `can?` for `undefined_subtarget` will always return `false`. But, `cant` on simillar ocassion will return `true`.

Rule can also be called on a class:

```ruby
My::Transaction.can?(:supreme_user, :new)      # => true
My::Transaction.can?(:guest, :view)            # => false
My::Employee.can?(:undefined_subtarget, :new)  # => false, rule class for this is by its own undefined
```

As we have never define the `rules_for` My::Employee before, any attempt to `can?` for `My::Employee` will return `false`, so does any attempt to object `cant?` on which will only return `true` for any given subtarget and operation.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/saveav/bali. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

### Changelog

#### Version 1.0.0beta1
1. Initial version

#### Version 1.0.0rc1
1. Fix bug where user can't check on class
2. Adding new clause: cant_all

#### Version 1.0.0rc2
1. [Fix bug when class's name, as a constant, is reloaded](http://stackoverflow.com/questions/2509350/rails-class-object-id-changes-after-i-make-a-request) (re-allocated to different address in the memory)
2. Allow describing rule for `nil`, useful if user is not authenticated thus role is probably `nil`
3. Remove pry from development dependency

#### Version 1.0.0rc3
1. Each target class should includes `Bali::Objector`, for the following reasons:
   - Makes it clear that class do want to include the Bali::Objector
   - Transparant, and thus less confusing as to where "can?" and "cant" come from
   - When ruby re-parse the class's codes for any reasons, parser will be for sure include Bali::Objector
2. Return `true` to any `can?` for undefined target/subtarget alike
3. Return `false` to any `cant?` for undefined target/subtarget alike