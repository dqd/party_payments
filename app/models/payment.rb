class Payment < ActiveRecord::Base
  belongs_to :payable, polymorphic: true
  belongs_to :payment, polymorphic: true
end
