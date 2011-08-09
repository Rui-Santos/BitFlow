require 'set'
module Admin
  class FundDepositRequestsController < ::Admin::BaseController
    
    def index
      FundDepositRequest.where(:created_by_admin => true).each {|req| req.destroy}
      @search_criteria = SearchCriteria.new :email => nil, :account_number => nil
      @fund_deposit_requests = FundDepositRequest.order("updated_at").where(:status => FundDepositRequest::Status::PENDING)
      respond_to do |format|
        format.html
      end
    end
    
    def show
      @fund_deposit_request = FundDepositRequest.find(params[:id])
    end
    
    def update
      fee = params[:fund_deposit_request][:fee]
      Fund.transaction do
        @fund_deposit_request = FundDepositRequest.find(params[:id])
        amount_received = params[:fund_deposit_request][:amount_received].to_f
        @fund_deposit_request.update_attributes :status => FundDepositRequest::Status::COMPLETE, 
                                                :amount_received => amount_received,
                                                :fee => fee,
                                                :created_by_admin => false
        @fund_deposit_request.user.usd.credit! :amount => amount_received,
                                              :currency => 'USD',
                                              :tx_code => FundTransactionDetail::TransactionCode::PAYMENT_RECEIVED,
                                              :status => FundTransactionDetail::Status::COMMITTED,
                                              :user_id => @fund_deposit_request.user.id,
                                              :fund_deposit_request_id => @fund_deposit_request.id
        unless fee.blank?
          AdminUser.usd.credit! :amount => fee.to_f,
                                :currency => 'USD',
                                :tx_code => FundTransactionDetail::TransactionCode::DEPOSIT_FEE,
                                :status => FundTransactionDetail::Status::COMMITTED,
                                :user_id => AdminUser.id,
                                :fund_deposit_request_id => @fund_deposit_request.id
          @fund_deposit_request.user.usd.debit! :amount => fee.to_f,
                                :currency => 'USD',
                                :tx_code => FundTransactionDetail::TransactionCode::DEPOSIT_FEE,
                                :status => FundTransactionDetail::Status::COMMITTED,
                                :user_id => @fund_deposit_request.user.id,
                                :fund_deposit_request_id => @fund_deposit_request.id
        end
      end
      FundDepositRequest.where(:created_by_admin => true).each {|req| req.destroy}
      respond_to do |format|
        format.html { redirect_to(admin_fund_deposit_requests_url) }
      end
    end
    
    def search
      FundDepositRequest.where(:created_by_admin => true).each {|req| req.destroy}
      @search_criteria = SearchCriteria.new(params[:search_criteria])
      if @search_criteria.operation == 'search'
        email_criteria = @search_criteria.email.downcase
        acc_criteria = @search_criteria.account_number.downcase
        sql_deposit_code = "deposit_code like ?" unless email_criteria.blank?
        sql_acc = "lower(bankaccounts.number) like ?" unless acc_criteria.blank?
        if sql_deposit_code && sql_acc
          sql = "(#{sql_deposit_code} or #{sql_acc}) and fund_deposit_requests.status = ?"
          @fund_deposit_requests = FundDepositRequest.order("updated_at").joins(:bankaccount).where(sql, "%#{email_criteria}%", "%#{acc_criteria}%", FundDepositRequest::Status::PENDING)
        elsif sql_deposit_code
          sql = "#{sql_deposit_code} and fund_deposit_requests.status = ?"
          @fund_deposit_requests = FundDepositRequest.order("updated_at").joins(:bankaccount).where(sql, "%#{email_criteria}%", FundDepositRequest::Status::PENDING)
        elsif sql_acc
          sql = "#{sql_acc} and fund_deposit_requests.status = ?"
          @fund_deposit_requests = FundDepositRequest.order("updated_at").joins(:bankaccount).where(sql, "%#{acc_criteria}%", FundDepositRequest::Status::PENDING)
        else
          sql = "fund_deposit_requests.status = ?"
          @fund_deposit_requests = FundDepositRequest.order("updated_at").joins(:bankaccount).where(sql, FundDepositRequest::Status::PENDING)
        end
      elsif @search_criteria.operation == 'create_request'
        @fund_deposit_requests = []
        bank_account_ids = Set.new
        email_criteria = @search_criteria.email.downcase
        unless email_criteria.blank?
          bank_accounts = Bankaccount.joins(:user).where("bankaccounts.status = ? and lower(users.email) like ?", Bankaccount::Status::ACTIVE, "%#{email_criteria}%")
          bank_accounts.each {|ba| bank_account_ids.add(ba.id)}
        end
        acc_criteria = @search_criteria.account_number.downcase
        unless acc_criteria.blank?
          bank_accounts = Bankaccount.where("lower(number) like ?", "%#{acc_criteria}%")
          bank_accounts.each {|ba| bank_account_ids.add(ba.id)}
        end
        
        bank_account_ids.each do |ba_id|
          related_user = Bankaccount.find(ba_id).user
          @fund_deposit_requests.<<(FundDepositRequest.create :bankaccount_id => ba_id,
                                                              :currency => 'USD',
                                                              :user_id => related_user.id,
                                                              :status => FundDepositRequest::Status::PENDING,
                                                              :deposit_code => related_user.email.downcase,
                                                              :created_by_admin => true,
                                                              :amount_requested => "0.0",
                                                              :amount_received => "0.0")
        end
      else
        
      end
      respond_to do |format|
        format.html { render :index }
      end
    end
  end
end