class TransactionsController < ApplicationController

  def new
    @transaction = Transaction.new
  end

  def create
    @transaction = Transaction.new(transaction_params)
    @transaction.user = current_user
    if txid = @transaction.create_with_eth
      redirect_to user_path(current_user), notice: "Transaction is created. TxHash: #{txid}"
    else
      render :new
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:to, :eth_value)
  end

end
