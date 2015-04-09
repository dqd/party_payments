# -*- encoding : utf-8 -*-
class BankPayment < ActiveRecord::Base

  scope :unpaired, -> { where(accounting_status: :pending) }

  validate unique: :transaction_id

  has_many :payments, as: :payment
  belongs_to :organization

  #has_one :payment
  #has_one :membership_fee
  #has_one :supporter_fee

  has_many :accountings, as: :payment

  include AASM

  aasm :column => 'accounting_status' do
    state :pending, :initial => true
    state :completed

    event :process_payment do
      transitions :from => :pending, :to => :completed
    end
  end

  def self.import
    Organization.all.each {|organization|
      FioAPI.token = organization.token
      list = FioAPI::List.new
      list.from_last_fetch

      response = list.response
      response.transactions.each do |row|
        puts row.inspect
        create!(
          :organization_id => organization.id,
          :amount => row.amount,
          :paid_on => Date.parse(row.date),
          :currency => row.currency,
          :transaction_id => row.transaction_id,
          :account_number => row.account,
          :bank_code => row.bank_code,
          :vs => row.vs || '',
          :ks => row.ks || '',
          :ss => row.ss || '',
          :info => row.message_for_recipient || '',
          :account_name => row.user_identification || ''
        ) unless find_by_transaction_id(row.transaction_id)
      end
    }
  end

  def positive_amount
    amount < 0 ? amount*-1 : amount
  end

  def remaining_amount
    if amount < 0
      amount + payments.sum(:amount)
    else
      amount - payments.sum(:amount)
    end
  end

  def pair
    if remaining_amount < 0
      if invoice = Invoice.where(amount: positive_amount).detect{|i| i.vs==vs && i.account_number==account_number}
        payments.create(payable: invoice, amount: positive_amount)
      end
    elsif remaining_amount > 0 && vs.length==5 && vs[0]=="1"
      response = HTTParty.post("#{configatron.registry.uri}/people/#{vs}/payments.json", basic_auth: configatron.registry.auth)
      if response["payment"]["membership_type"]=="member"
        membership_fee = MembershipFee.create(
          region_id: response["payment"]["region_id"],
          amount: amount,
          person_id: response["payment"]["id"],
          name: response["payment"]["name"],
          received_on: paid_on
        )
        payments.create(payable: membership_fee, amount: positive_amount)
      end if response.success?
    end
  end

end
