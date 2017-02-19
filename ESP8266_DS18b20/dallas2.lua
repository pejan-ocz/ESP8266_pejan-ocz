require('ds18b20')
--require('ds18b20_2')

port = 80

-- ESP-01 GPIO Mapping
gpio0 = 3
gpio1 = 4

ds18b20.setup(gpio1)
--ds18b20_2.setup(gpio1)

last1=-1
last2=-1
function sendData()

  t1=ds18b20.read()
  t1=ds18b20.read()
--  t2=ds18b20_2.read()
--  t2=ds18b20_2.read()
  if (t1 == nil) then
    t1=last1
  end  
--  if (t2 == nil) then
--    t2=last2
--  end  
  --t2=t1-2
  print("Temp:"..t1.." C  \n")
  if (t1 ~= 85) then
    -- conection to thingspeak.com
    print("Sending data to thingspeak.com")
    print(wifi.sta.getip())
    conn=net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, payload) print(payload) end)
    -- api.thingspeak.com 184.106.153.149
    conn:connect(80,'184.106.153.149') 
    conn:send("GET /update?key=ThingSpeakAPIKey&field2="..t1.." HTTP/1.1\r\n") 
    conn:send("Host: api.thingspeak.com\r\n") 
    conn:send("Accept: */*\r\n") 
    conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
    conn:send("\r\n")
    conn:on("sent",function(conn)
                        print("Closing connection")
                        last1=t1
--                        last2=t2
                        conn:close()
                    end)
    conn:on("disconnection", function(conn)
            print("Got disconnection...")
    end)
  end
  --node.dsleep(1000000 * 60)
end

-- send data every X ms to thing speak
sendData()
tmr.alarm(0, 1800000, 1, function() sendData() end )
