class BitcoinProxy
  class JSONRPCException < RuntimeError
  end

  class ServiceProxy
    def initialize(service_url)
      @service_url = service_url
    end

    def method_missing(name, *args, &block)
      begin
        postdata = {"method" => name, "params" => args, "id" => "jsonrpc"}.to_json
        respdata = RestClient.post @service_url, postdata
        resp = JSON.parse respdata
        raise JSONRPCException.new, resp['error'] if resp["error"]
        resp['result']
      rescue => e
        puts "#{e.inspect} on invoking #{name}(#{args.join(", ")})"
        raise JSONRPCException.new, e.inspect
      end
    end
  end

  def self.new_address(account_name)
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").getnewaddress(account_name)
  end

  def self.balance(account_name)
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").getbalance(account_name)
  end

  def self.all_addresses(account_name)
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").getaddressesbyaccount(account_name)
  end
  
  def self.address(account_name)
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").getaccountaddress(account_name)
  end
  
  def self.send_from(account_name, address, amount, comment, comment_to)
    # puts "Sending #{amount}BTC from #{account_name} to #{address} with comment #{comment} and comment_to #{comment_to}"
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").sendfrom(account_name, address, amount, 1, comment, comment_to)
  end
  
  def self.account(address)
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").getaccount(address)
  end
  
  def self.generating_hashes?
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").getgenerate
  end
  
  def self.info
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").getinfo
  end

  def self.total_received(account_name)
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").getreceivedbyaccount(account_name)
  end

  def self.list_received_by_account
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").listreceivedbyaccount
  end
  
  def self.list_received_by_address
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").listreceivedbyaddress
  end

  def self.list_transactions(account_name, count)
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").listtransactions(account_name, count)
  end
  
  def self.send_to_address(address, amount, comment, comment_to)
    # puts "Sending #{amount}BTC from ? to #{address} with comment #{comment} and comment_to #{comment_to}"
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").sendtoaddress(address, amount, comment, comment_to)
  end
  
  def self.validate_address(address)
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").validateaddress(address)
  end
  
  def self.get_transaction(tx_id)
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").gettransaction(tx_id)
  end
  
  def self.set_account(address, account_name)
    ServiceProxy.new("http://#{Configuration.bitcoind_json_rpc_user}:#{Configuration.bitcoind_json_rpc_password}@127.0.0.1:8332").setaccount(address, account_name)
  end
end

