require 'logger'

class LoggerModule
  def log_info(message)
    Logger.new('app.log').info(message)
  end

  def log_warning(message)
    Logger.new('app.log').warn(message)
  end

  def log_error(message)
    Logger.new('app.log').error(message)
  end
end

class User
  attr_accessor :name, :balance

  def initialize(name, balance)
    @name = name
    @balance = balance
  end
end

class Transaction
  attr_reader :user, :value

  def initialize(user, value)
    @user = user
    @value = value
  end
end

module Bank
  def process_transactions(transactions, callback)
    log_info("Processing Transactions #{transactions.map { |t| "#{t.user.name} transaction with value #{t.value}" }.join(', ')}...")
    transactions.each do |transaction|
      begin
        if transaction.user.instance_of?(User)
          if self.users.include?(transaction.user)
            new_balance = transaction.user.balance + transaction.value
            if new_balance < 0
              raise "Not enough balance"
            elsif new_balance == 0
              log_warning("#{transaction.user.name} has 0 balance")
            end
            transaction.user.balance = new_balance
            callback.call("success", transaction)
          else
            raise "#{transaction.user.name} not exist in the bank!!"
          end
        else
          raise "Invalid user"
        end
      rescue StandardError => e
        log_error("User #{transaction.user.name} transaction with value #{transaction.value} failed with message #{e.message}")
        callback.call("failure", transaction)
      end
    end
  end
end

class CBABank
  include Bank
  include LoggerModule

  attr_reader :users

  def initialize(users)
    @users = users
  end
end

# Example usage
users = [
  User.new("Ali", 200),
  User.new("Nour", 500),
  User.new("Monagem install rails", 100)
]

out_side_bank_users = [
  User.new("Menna", 400),
]

transactions = [
  Transaction.new(users[0], -20),
  Transaction.new(users[0], -30),
  Transaction.new(users[0], -50),
  Transaction.new(users[0], -100),
  Transaction.new(users[0], -100),
  Transaction.new(out_side_bank_users[0], -100)
]

callback = Proc.new do |status, transaction|
  puts "Call endpoint for #{status} of User #{transaction.user.name} transaction with value #{transaction.value} #{status == 'failure' ? "with reason #{transaction.user.name} not exist in the bank!!" : ''}"
end

cba_bank = CBABank.new(users)
cba_bank.process_transactions(transactions, callback)
