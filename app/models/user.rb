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
    eth_client.balance_latest(self.eth_address).to_f - unconfirmed_balance
  end

  def eth_client
    @eth_client ||= EthIpc.new
  end

  def unconfirmed_transactions
    transactions.order(id: :desc).limit(100).where('data @> ?', {to: self.eth_address}.to_json).select{|t| t.confirmed_blocks < Transaction::CONFIRM_AGE}
  end

  def unconfirmed_balance
    unconfirmed_transactions.sum{|t| t.value}  #rescue 0
  end

  def sync_transactions
    eth_transactions = eth_client.get_transactions(self.eth_address)
    eth_hashes = eth_transactions.pluck("hash")
    hashes     = self.transactions.pluck(:eth_hash)

    diff = eth_hashes - hashes

    diff.each do |eth_hash|
      transaction = eth_transactions.find{|i| i["hash"] == eth_hash}
      self.transactions.create({eth_hash: eth_hash, data: transaction})
    end
  end

end
