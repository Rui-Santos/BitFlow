class BitcoinProxy
  class JSONRPCException < RuntimeError
  end

  class ServiceProxy
    def initialize(service_url)
      @service_url = service_url
    end

    def method_missing(name, *args, &block)
      postdata = {"method" => name, "params" => args, "id" => "jsonrpc"}.to_json
      respdata = RestClient.post @service_url, postdata
      resp = JSON.parse respdata
      raise JSONRPCException.new, resp['error'] if resp["error"]
      resp['result']
    end
  end

  def self.new_address(accountName)
    ServiceProxy.new('http://bitflow:as@127.0.0.1:8332').getnewaddress(accountName)
  end

  def self.balance(accountName)
    ServiceProxy.new('http://bitflow:as@127.0.0.1:8332').getbalance(accountName)
  end

  def self.all_addresses(accountName)
    ServiceProxy.new('http://bitflow:as@127.0.0.1:8332').getaddressesbyaccount(accountName)
  end
  
  def self.sendfrom(accountName, address, amount, comment, comment_to)
    # ServiceProxy.new('http://bitflow:as@127.0.0.1:8332').sendfrom(accountName, address, amount, comment, comment_to)
    puts "Sending #{amount}BTC from #{accountName} to #{address} with comment #{comment} and comment_to #{comment_to}"
  end

end

