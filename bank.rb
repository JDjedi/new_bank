require "rubygems"  
require "sqlite3"
$db = SQLite3::Database.new("db_bank_file")
$db.results_as_hash = true
load "default_msg.rb"

class Bank
	attr_accessor :selected_account

	def initialize
		@selected_account = selected_account
	end

	def create_table
		puts "Creating accounts table..."
		$db.execute %q{
			CREATE TABLE accounts (
				account_number integer primary key,
				name varchar(50),
				balance integer,
				pin integer)
		}
	end

	def main_menu
		loop do
			puts "Hi and welcome to Software Bank."
			puts "Please select an option..."
			puts ""
			puts "1. Create a new account."
			puts "2. Access and existing account"
			puts "3. Exit the program"

			case gets.chomp
				when '1'
					create_account
				when '2'
					account_login
				when '3'
					exit 
				else
					error_msg
			end
		end
	end

	def create_account
		seperator
		puts "Enter the new account number:"
		account_number = gets.chomp
		puts "Enter the account holders name:"
		name = gets.chomp
		puts "Enter starting balance:"
		balance = gets.chomp
		puts "Enter account pin:"
		pin = gets.chomp

		$db.execute("INSERT INTO accounts (account_number, name, balance, pin) VALUES (?, ?, ?, ?)",
			account_number, name, balance, pin)

		seperator
		puts "New account created successfully."
	end

	def account_login
		seperator
		puts "Please enter your 7 digit account number."
		account_number = gets.chomp
		#int_account_number = account_number.to_i
		seperator

		puts "Please enter your 4 digit pin."
		pin = gets.chomp
		#int_account_pin = account_pin.to_i 
		seperator

		@selected_account = $db.execute("SELECT * FROM accounts WHERE account_number = ? AND pin = ?", account_number.to_i, pin.to_i).first

		unless @selected_account
			puts "No accounts found"
			seperator
			return
		end

		account_menu(@selected_account)
	end

	def account_menu(arg)
		puts "Hello, #{arg['name']}!"
		puts "Account Number: #{arg['account_number']}"
		puts "Balance: #{arg['balance']}"
		puts ""
		puts "What would you like to do?"
		puts "1. Deposit"
		puts "2. Withdrawl"
		puts "3. Log out and exit to the Main Menu"

		case gets.chomp
			when '1'
				seperator
				deposit(@selected_account)
			when '2'
				seperator
				withdrawl(@selected_account)
			when '3'
				puts "Logging out.... "
				seperator
				main_menu 
			else
				error_msg
				account_menu(@selected_account)
		end
	end

	def deposit(arg)
		puts "How much would you like to deposit?"
		puts "*** You may only deposit in increments of 10.00 ***"
		deposit_amount = gets.chomp

		if deposit_amount.match(/\D+/)
			error_msg
			deposit(arg)
		else
			if (deposit_amount.to_i % 10) != 0
				error_msg
				deposit(@selected_account)
			else
				new_balance = arg['balance'] + deposit_amount.to_i
				update_transaction(new_balance)

				puts ""
				puts "****************************"
				puts "You deposited $#{deposit_amount}"
				#puts "Your old balance was $#{arg['balance']}" #TEST UNIT
				puts "Your new balance is #{new_balance}"
				puts "****************************"
				thank_you_msg
				main_menu
			end
		end
	end

	def withdrawl(arg)
		puts "How much would you like to withdrawl?"
		puts "*** You may only withdrawl in increments of 10.00 ***"

		withdrawl_amount = gets.chomp

		if withdrawl_amount.match(/\D+/)
			error_msg
			withdrawl(@selected_account)
		else
			if (withdrawl_amount.to_i % 10) != 0
				error_msg
				withdrawl(@selected_account)
			elsif withdrawl_amount.to_i > arg['balance']
				seperator
				puts "Withdrawl amount is greater than account balance."
				puts "Please select a valid amount."
				seperator
				withdrawl(@selected_account)
			else
				new_balance = arg['balance'] - withdrawl_amount.to_i
				update_transaction(new_balance)

				puts ""
				puts "****************************"
				puts "Your money will now be despensed"
				puts "Your new balance is $#{new_balance}"
				puts "****************************"
				thank_you_msg
				main_menu
			end
		end
	end

	def update_transaction(arg)
		begin
			bank_db = SQLite3::Database.open "db_bank_file"
			bank_db.transaction
			bank_db.execute("UPDATE accounts SET balance = ? WHERE account_number = ?", arg, @selected_account['account_number'])
			bank_db.commit

		rescue SQLite3::Exception => e 
			puts "Exception occurred"
	   		puts e
	    	bank_db.rollback
	    
		ensure
	    	bank_db.close if bank_db
		end
	end
end

foo = Bank.new
#foo.create_table
foo.main_menu







