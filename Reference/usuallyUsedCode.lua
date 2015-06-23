--Test message output
local msg = sgs.LogMessage()
msg.type = "#test"
msg.arg = "DamageCaused!"
room:sendLog(msg)

--TriggerSkill
luatest = sgs.CreateTriggerSkill{
	name = "luatest",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageForseen},
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		return false
	end
}