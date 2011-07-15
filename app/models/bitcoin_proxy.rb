require 'json'
require 'rest_client'
module BitcoinProxy
    
    class JSONRPCException < RuntimeError
      def initialize()
        super()
      end
    end

    class ServiceProxy
        def initialize(service_url)
            @service_url = service_url
        end
    
        def method_missing(name, *args, &block)
            postdata = {"method" => name, "params" => args, "id" => "jsonrpc"}.to_json
            respdata = RestClient.post @service_url, postdata
            resp = JSON.parse respdata
            if resp["error"] != nil
                raise JSONRPCException.new, resp['error']
            end
            return resp['result']
        end
    end
    
    def createNewAddressForAccount(accountName)
        return ServiceProxy.new('http://bitflow:as@127.0.0.1:8332').getnewaddress(accountName)
    end
    
    def getBalance(accountName)
        return ServiceProxy.new('http://bitflow:as@127.0.0.1:8332').getbalance(accountName)
    end
    
    def getAllAddressesByAccount(accountName)
        return ServiceProxy.new('http://bitflow:as@127.0.0.1:8332').getaddressesbyaccount(accountName)
    end
    
end

class BitcoinProxyTest
  include BitcoinProxy
  
  def testCreateNewAddressForAccount
    acc = 'niket'
    addr = createNewAddressForAccount(acc)
    puts "#{addr} created for account: #{acc}"
  end
  
  def testGetBalance
    acc = 'niket'
    balance = getBalance(acc)
    puts "Balance for #{acc}: #{balance}"
  end
  
  def testGetAllAddressesByAccount
    acc = 'niket'
    addrs = getAllAddressesByAccount(acc)
    puts "Addresses for #{acc}: #{addrs}"
  end
  
end

test = BitcoinProxyTest.new

#test.testCreateNewAddressForAccount
test.testGetBalance
test.testGetAllAddressesByAccount
