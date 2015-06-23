--Test message output
local msg = sgs.LogMessage()
msg.type = "#test"
msg.arg = "DamageCaused!"
room:sendLog(msg)
