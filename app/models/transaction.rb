class Transaction < ApplicationRecord
  attr_accessor :to, :eth_value

  belongs_to :user

  delegate :eth_client, to: :user

  def value
    result = formater.to_int(self.data["value"])
    formater.from_wei(result)
  end

  def outer?
    self.data["from"] == user.eth_address
  end

  def inner?
    self.data["to"] == user.eth_address
  end

  def create_with_eth
    return self.errors.add(:eth_value, "you don't have enough funds for this operation") if self.eth_value > user.raw_balance

    if eth_client.unlock_account(user.eth_address, user.eth_password)

      if txid = eth_client.send_transaction(user.eth_address, self.to, self.eth_value.to_f)
        return txid
      end

      self.errors.add(:eth_hash, "not present in transaction response")
    else
      self.errors.add(:to, "can't unlock the account for transaction")
    end
  end

  private
  def formater
    @formater ||= Ethereum::Formatter.new
  end
end
