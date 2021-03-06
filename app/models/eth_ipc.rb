class EthIpc
  attr_reader :client, :formater

  def initialize
    @client = Ethereum::IpcClient.new(Rails.application.secrets.eth_ipc_path)
    @formater = Ethereum::Formatter.new
  end

  def create_account
    password = SecureRandom.hex(6)
    result = client.personal_new_account(password) rescue nil
    return {address: result["result"], password: password} if result

    result
  end

  def unlock_account(address, password)
    client.personal_unlock_account(address, password)["result"] rescue nil
  end

  def send_transaction(from, to, value)
    value  = to_eth(value)
    gas    = to_hex(21000)
    params = {
      from: from,
      to: to,
      #gas: gas,
      #gasPrice: "0x9184e72a000", # 10000000000000
      value:  value,
      data: "0x"
    }
    result = client.eth_send_transaction(params)
    return result["result"] if result["result"]

    Rails.logger.debug("error: #{result["error"]}")

    false
  end

  def get_transaction(txid)
    client.eth_get_transaction_by_hash(txid)["result"]
  end

  def get_transactions(address, size = 500)
    end_block = eth_block_number
    start_block = end_block - size;

    transactions = client.batch do
      (start_block..end_block).map do |block_number|
        hex_block = "0x" + formater.to_twos_complement(block_number)
        client.eth_get_block_by_number(hex_block, true)
      end
    end.map{|b| b["result"]["transactions"]}.flatten

    select_transactions_by(address, transactions)
  end

  def balance_latest(account)
    result = formater.to_int(client.eth_get_balance(account, "latest")["result"])
    formater.from_wei(result)
  end

  def balance_pending(account)
    result = formater.to_int(client.eth_get_balance(account, "pending")["result"])
    formater.from_wei(result)
  end

  def accounts
    client.eth_accounts
  end

  def counbase
    client.eth_coinbase
  end

  def to_eth(value)
    "0x" + formater.to_twos_complement(formater.to_wei(value))
  end

  def to_hex(value)
    "0x" + formater.to_twos_complement(value)
  end

  def eth_block_number
    formater.to_int(client.eth_block_number["result"])
  end

  private

  def select_transactions_by(address, transactions)
    return [] unless transactions.any?
    transactions.select{|t| t["from"] == address or t["to"] == address}
  end


  #https://ethereum.stackexchange.com/questions/2881/how-to-get-the-transaction-confirmations-using-the-json-rpc

end
