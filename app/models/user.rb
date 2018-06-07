class User < ApplicationRecord
  has_secure_password

  has_many :transactions, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def create_with_eth
    if self.valid? and eth_account = eth_client.create_account
      self.eth_address  = eth_account[:address]
      self.eth_password = eth_account[:password]
      return self.save!
    end
    self.errors.add(:eth_address, :blank, message: "couldn't connect to ethereum ipc network") if eth_account.nil? and self.valid?

    false
  end

	def balance
		{latest: eth_client.balance_latest(self.eth_address), pending: eth_client.balance_pending(self.eth_address)}
	end

  def raw_balance
    eth_client.balance_latest(self.eth_address)
  end

  def eth_client
    @eth_client ||= EthIpc.new
  end

  def sync_transactions
    eth_transactions = eth_client.get_transactions(self.eth_address)
    eth_haches = eth_transactions.pluck("hash")
    haches     = self.transactions.pluck(:eth_hash)

    diff = eth_haches - haches

    diff.each do |eth_hash|
      transaction = eth_transactions.find{|i| i["hash"] == eth_hash}
      self.transactions.create({eth_hash: eth_hash, data: transaction})
    end
  end

end
