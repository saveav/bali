# Bali

[![Build Status](https://travis-ci.org/adamnoto/bali.svg?branch=release)](https://travis-ci.org/adamnoto/bali) [![Maintainability](https://api.codeclimate.com/v1/badges/7d8f2d978205bb768d06/maintainability)](https://codeclimate.com/github/adamnoto/bali/maintainability)

Bali is a to-the-point authorization library for Rails. Bali is short for Bulwark Authorization Library.

Why I created Bali?

- Defining authorization rules are complicated, I want to make it natural and so much simper like Ruby
- I want to easily segment authorization rules per roles
- I don't want to marry rules with controllers' actions
- I want an intuitive DSL
- I want to print those rules if I want, to see who can do what
- On top of that, it integrates well with Rails (also, RSpec)

Internally, Bali is quite complicated, but externally, Bali should be very easy and intuitive to use.

## Supported versions

* Ruby 2.4.4 until Ruby 2.7 (trunk)
* Rails 5.0, Rails 6.0, until Rails edge (master)

## Installation

Add this into your gemfile:

```ruby
gem 'bali'
```

And then execute:

    $ bundle

To generate a rule class, for example for a model named `User`:

    $ bundle rails g rules user

We can suplant `User` with something else

## Usage

In a nutshell, authorization rules are to be defined in a class extending `Bali::Rules` (located in `app/rules`). We use `can?` and `cant?` to check against those rules we define using `can`, `cant`, `can_all`, and `cant_all`. Unscoped rules are inherited, otherwise we can scope rules by defining them within a `role` block.

Given a model as follows:

```ruby
# == Schema Information
#
# Table name: transactions
#
#  id               :bigint           not null, primary key
#  is_settled       :boolean          not null
class Transaction < ApplicationRecord
  alias :settled? :is_settled
end
```

And given the `TransactionRules` defined as follows:

```ruby
class TransactionRules < Bali::Rules
  can :update, :unsettle
  can :print

  # overwrites :unsettle
  can :unsettle do |record, current_user|
    record.settled?
  end

  # will inherit update, print
  role :supervisor, :accountant do
    # will always be able to unsettle
    can :unsettle
  end

  role :accountant do
    # must not be able to perform an update operation
    cant :update
  end

  role :supervisor do
    can :comment
  end

  role :clerk do
    cant_all
    can :unsettle
  end

  role :admin do
    can_all
  end
end
```

We can do authorization in this way:

```ruby
transaction = Transaction.new
TransactionRules.can?(current_user, :update, transaction)
TransactionRules.cant?(current_user, :update, transaction)
TransactionRules.can?(:archive, transaction)
TransactionRules.can?(:accept_new_transaction)
```

Inside a controller or a view; we can also do:

```ruby
if can? current_user, :update, transaction
  # snip snip
end
```

Bali can automatically detect the rule class to use for such a query. That way, we don't have to manually spell out `TransactionRules` when it is clear that the `transaction` is a `Transaction`.

We may also omit `current_user` to make the call shorter and more concise:

```ruby
if can? :update, transaction
  # snip snip
end
```

For more coding examples, please take a look at the written test files. Otherwise, if you may encounter some unclear points, please feel free to suggest for edits. Thank you.

## Testing through RSpec

Bali is integrated into RSpec pretty well. There's a `be_able_to` matcher that we can use to test the rule:

```ruby
let(:transaction) { Transaction.new }
let(:accountant) { User.new(:accountant) }

# expectation on an instance of a class
it "allows accountant to print, but not update, transaction" do
  expect(accountant).to be_able_to :print, transaction
  expect(accountant).not_to be_able_to :update, transaction
end

# expectation on a class
it "allows User to sign in" do
  expect(User).to be_able_to :sign_in
end
```

## Scoping data to role

Some user can access all data, and some can only access to data belonging to them. This can be achieved by using a `scope` block.

An example of defining a `scope` block for the `TransactionRules`.

```ruby
class TransactionRules < Bali::Rules
  scope do |data, current_user|
    unless current_user.role == "admin"
      data.where(user_id: current_user.id)
    end
  end

  # ...
end
```

We can use `rule_scope` to execute the scope for a given data:

```ruby
transactions = TransactionRules.rule_scope(Transaction.all, current_user)
```

Inside a controller/view, we may also omit `current_user` to make the call concise.

```ruby
transactions = rule_scope(Transaction.all)
```

It is important to note that a `scope` block must not be defined within a `role` block.

## Usage outside of Rails

This authorization library might be used outside of Rails, such as with Grape or Sinatra projects. However, although it should work as expected, such integration is not natively supported by Bali itself. Hence, additional works for such integration is needed.

If ActiveRecord is not used, we need to add the following code into a user class.

```ruby
class User
  extend Bali::Statics::Record
  extract_roles_from :roles
end
```

On the controller, we should add these helper modules:

```ruby
include Bali::Statics::ScopeRuler
include Bali::Statics::Authorizer
```

Doing so allow us to use the `can?` and other functions on the controller. Bali should also be able to deduce the user's roles properly.

## Printing defined roles

```ruby
puts Bali::Printer.printable
```

Or execute:

```
$ rails bali:print_rules
```

Will print, for example, this definition:

```
===== Transaction =====

      By default
      --------------------------------------------------------------------------------
        1. By default can update
        2. By default can unsettle, with condition
        3. By default can print
      Supervisor
      --------------------------------------------------------------------------------
        1. Supervisor can unsettle
        2. Supervisor can comment
      Accountant
      --------------------------------------------------------------------------------
        1. Accountant can unsettle
        2. Accountant cant update
      Clerk
      --------------------------------------------------------------------------------
        1. Clerk can unsettle
      Admin
      --------------------------------------------------------------------------------
        1. Admin can do anything except if explicitly stated otherwise


===== User =====

      By default
      --------------------------------------------------------------------------------
        1. By default can see_timeline, with condition
        2. By default can sign_in, with condition


Printed at 2020-01-01 12:34AM +00:00
```

## License

Bali is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Changelog

Please refer to CHANGELOG.md to see it
