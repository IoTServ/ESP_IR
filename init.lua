-- ESP IR Sender
-- Simonarde Lima - http://github.com/simonardejr/ESP_IR

ir_pin = 4 -- GPIO2
gpio.mode(ir_pin, gpio.OUTPUT)

broker = ""
port = 1883
topic = "/ir/"

user_mqtt = ""
pwd_mqtt = ""

-- todo: colocar as configuracoes em arquivo separado
if(file.open("remotes.lua")) then
    dofile("remotes.lua")
end

-- MQTT
m = mqtt.Client("ESP1", 120, user_mqtt, pwd_mqtt)
m:lwt("/lwt", "offline", 0, 0)
m:connect(broker, port, 0, function(conn) print("conectado no broker")
    m:subscribe(topic,0, function(conn) print("subscribed "..topic) 
    end)
end)

-- Reconecta ao broker se for preciso
m:on("offline", function(con) print ("reconectando...")
    tmr.alarm(1, 10000, 0, function()
        m:connect(broker, port, 0, function(conn) print("conectado no broker")
            m:subscribe(topic,0, function(conn) print("subscribed "..topic) 
            end)
        end)
    end)
end)

-- Recebe as mensagens do MQTT
m:on("message", function(conn, topic, msg)   
    print("Recieved: " .. topic .. ": " .. msg)   
    -- por enquanto, controle da LG
    if (msg=="POWER") then
        dofile("irsend.lua").nec(4, 0x20DF10EF)
    elseif(msg=="VOL+") then
        dofile("irsend.lua").nec(4, 0x20DF40BF)
    elseif(msg=="VOL-") then
        dofile("irsend.lua").nec(4, 0x20DFC03F)
    elseif(msg=="INPUT") then
        dofile("irsend.lua").nec(4, 0x20DFD02F)
    else  
        print("Invalido - Ignorando")   
    end   
end)