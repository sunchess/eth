class EthIpc
  attr_reader :client

  def initialize
    @client = Ethereum::IpcClient.new(Rails.application.secrets.eth_ipc_path)
  end

  def create_account
    password = SecureRandom.hex(6)
    result = client.personal_new_account(password) rescue nil
    return {address: result["result"], password: password} if result

    result
  end

	def balance_latest(account)
		client.eth_get_balance(account, "latest")
	end

	def balance_pending(account)
		client.eth_get_balance(account, "pending")
	end

  def accounts
		client.eth_accounts()
  end

  def counbase
    client.eth_coinbase
  end


	#https://ethereum.stackexchange.com/questions/2881/how-to-get-the-transaction-confirmations-using-the-json-rpc

end
