
require 'xmlrpc/client'

# A useful helper for running Confluence XML-RPC from Ruby. Takes care of
# adding the token to each method call (so you can call server.getSpaces()
# instead of server.getSpaces(token)). Also takes care of re-logging in
# if your login times out.
#
# Usage:
#
# server = Confluence::Server.new("http://confluence.atlassian.com")
# server.login("user", "password")
# puts server.getSpaces()
#
module Confluence
   class Server
        def initialize(server_url)
            server_url += "/rpc/xmlrpc" unless server_url[-11..-1] == "/rpc/xmlrpc"
            @server_url = server_url
            server = XMLRPC::Client.new2(server_url)
            @conf = server.proxy("confluence1")
            @token = "12345"
        end

        def login(username, password)
            @user = username
            @pass = password
            do_login()
        end

        def method_missing(method_name, *args)
            begin
                @conf.send(method_name, *([@token] + args))
            rescue XMLRPC::FaultException => e
                if (e.faultString.include?("InvalidSessionException"))
                    do_login
                    retry
                else
                    raise e.faultString
                end
            end
        end

        private

        def do_login()
            begin
                @token = @conf.login(@user, @pass)
            rescue XMLRPC::FaultException => e
                raise e.faultString
            end
        end
    end
end


