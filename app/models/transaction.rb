class Transaction < ApplicationRecord
  attr_accessor :to, :eth_value

  CONFIRM_AGE = 10
  belongs_to :user

  delegate :eth_client, to: :user

  def value
    result = formater.to_int(self.data["value"])
    formater.from_wei(result).to_f
  end

  def outer?
    self.data["from"] == user.eth_address
  end

  def inner?
    self.data["to"] == user.eth_address
  end

  def block_number
    formater.to_int(self.data["blockNumber"])
  end

  def confirmed?
    confirmed_blocks > CONFIRM_AGE
  end

  #TODO: cache the eth block number with expiration in 10 sec?
  def confirmed_blocks
    eth_client.eth_block_number.to_i - self.block_number
  end

  def create_with_eth
    return false if (self.eth_value.to_f > user.raw_balance) and self.errors.add(:eth_value, "you don't have enough funds for this operation")

    if eth_client.unlock_account(user.eth_address, user.eth_password)
      if txid = eth_client.send_transaction(user.eth_address, self.to, self.eth_value.to_f)

        #TODO: make it as background job
        #if wait_for_deployment(txid)
        #  self.transactions.create({eth_hash: txid, data: eth_client.get_transaction(txid)})
        #end

        return txid
      end

      self.errors.add(:eth_hash, "not present in transaction response")
    else
      self.errors.add(:to, "can't unlock the account for transaction")
    end

    false
  end

  def deployed?(txid)
    eth_client.get_transaction(txid)["blockNumber"] != nil
  end

  def wait_for_deployment(txid, timeout = 50.seconds)
    start_time = Time.now
    while self.deployed?(txid) == false
      return false if ((Time.now - start_time) > timeout)
      sleep 2
      return true if self.deployed?(txid)
    end
  end

  private
  def formater
    @formater ||= Ethereum::Formatter.new
  end
end
