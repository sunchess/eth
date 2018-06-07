class Transaction < ApplicationRecord
  belongs_to :user

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

  private
  def formater
    @formater ||= Ethereum::Formatter.new
  end
end
