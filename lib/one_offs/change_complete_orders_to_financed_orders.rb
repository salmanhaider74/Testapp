# To Run: OneOffs::ChangeCompleteOrdersToFinancedOrders.run
module OneOffs
  class ChangeCompleteOrdersToFinancedOrders
    def self.run
      Order.where(status: :complete).each do |o|
        o.update_column(:status, :financed)
      end
    end
  end
end
