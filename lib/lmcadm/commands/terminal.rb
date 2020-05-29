require 'websocket-eventmachine-client'
require 'io/console'
require 'date'
module LMCAdm

  class KeyboardHandler < EM::Connection
    def receive_data(data)
      if data == "\C-c"
        EventMachine::stop_event_loop
      end
      LMCAdm::getWS.send '1' + data, type: 'binary'

    end
    #include EM::Protocols::LineText2

    #def receive_line(data)
    #  LMCAdm::getWS.send '1' + data.strip + "\r", type: 'binary'
    #end
  end

  def self.getWS
    @ws
  end

  arg_name "device"
  desc "Open terminal"
  command :terminal do |t|
    t.desc "Account name|UUID"
    t.flag :account, :A, :required => true

    t.action do |g, o, args|
      account = LMC::Account.get_by_uuid_or_name o[:account]
      device = Helpers::find_device account.devices, name: args.first, id: args.first
      account.cloud.auth_for_account account
      payload = {type: 'TERMINAL',
                 deviceIds: [device.id]}
      sessionInfo = account.cloud.post ['cloud-service-devicetunnel', 'accounts', account.id, 'terminal'], payload


      if g['use-tls']
        url = 'wss://'
      else
        url = 'ws://'
      end
      url += g[:cloud_host]
      url += '/cloud-service-devicetunnel/session'
      headers_hash = {
          'Sec-WebSocket-Protocol' => "TYPE_TERMINAL, REQU_USER, IDEN_#{sessionInfo.body.first['id']}, ACCT_#{account.id}, DEVC_#{device.id}"
      }
      begin
        EventMachine.epoll
        EventMachine.run do
          trap("TERM") { stop g[:debug]}
          trap("INT") { stop g[:debug]}
          IO.console.raw!
          EventMachine.open_keyboard(LMCAdm::KeyboardHandler)
          @ws = WebSocket::EventMachine::Client.connect({uri: url, headers: headers_hash})
          closing = false

          @ws.onopen do
            print "Connected to #{device.name} (#{device.id}):\r\n"
          end

          @ws.onmessage do |msg, type|
            print "##{msg.length}##{msg.inspect}#" if g[:debug]
            if msg.start_with? "1"
              print msg[1..-1].gsub("\n","\r\n")
            else
              print msg if g[:debug]
            end
            print DateTime.now.to_s if g[:debug]
            if msg.include? "\n\nGoodbye\n\n"
              stop g[:debug]
              closing =  true
            end
          end

          @ws.onclose do
            print DateTime.now.to_s if g[:debug]
            print "Disconnected\r\n"
            stop g[:debug] unless closing
          end

          @ws.onerror do |e|
            puts "Error: #{e}"
          end

          @ws.onping do |msg|
            puts "Received ping: #{msg}" if g[:verbose]
          end

          @ws.onpong do |msg|
            puts "Received pong: #{msg}" if g[:verbose]
          end

          def stop(debug=false)
            print DateTime.now.to_s if debug
            print "Terminating connection\r\n"
            EventMachine.stop
          end
        end
      ensure
        IO.console.cooked!
      end
        # disabled, getting 401 anyways
        #account.cloud.auth_for_account account
        #account.cloud.delete ['cloud-service-devicetunnel', 'accounts', account.id, "terminal?ids=#{sessionInfo.body.first['id']}"]
    end
  end
end