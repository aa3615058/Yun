module("extensions.yunEX", package.seeall)
extension = sgs.Package("yunEX")

liyunpeng = sgs.General(extension, "liyunpeng", "wu", "3", true)
EXhuaibeibei = sgs.General(extension, "EXhuaibeibei$", "wu", "4", false)
EXhanjing = sgs.General(extension, "EXhanjing", "wu", "3", false)


lanyan = sgs.CreatePhaseChangeSkill{
	name = "lanyan",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	
	on_phasechange = function(skill, player)
		if player:getPhase() == sgs.Player_Finish then
            player:setGender(sgs.General_Female)
        end
		if player:getPhase() == sgs.Player_Start then
            player:setGender(sgs.General_Male)
        end
        return false
	end
}

lienv = sgs.CreateTriggerSkill{
	name = "lienv",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damage,sgs.Damaged,sgs.FinishJudge},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local target = nil
		local flag = nil
		if event == sgs.Damage then
			target = damage.to
			flag = player:getGender() == target:getGender()
		elseif event == sgs.Damaged then
			target = damage.from
			flag = player:getGender() ~= target:getGender()
		elseif event == sgs.FinishJudge then
			local judge = data:toJudge()
			if judge.reason == self:objectName() then
				local card = judge.card
				if card:isBlack() then
					player:obtainCard(card)
				end
				else
					
				end
				return true
			end
		
		if flag then
			if player:askForSkillInvoke("lienv") then
				local judge = sgs.JudgeStruct()
				judge.good = true
				judge.reason = "lienv"
				judge.who = player
				room:judge(judge)
			else
				return true
			end
			return false
		end
	end
}
lienvCard = sgs.CreateSkillCard{
	name = "lienvCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:isWounded())
	end,
	feasible = function(self, targets)
		if #targets == 1 then
			return targets[1]:isWounded()
		end
		return #targets == 0 and sgs.Self:isWounded()
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1] or source
		local effect = sgs.CardEffectStruct()
		effect.card = self
		effect.from = source
		effect.to = target
		room:cardEffect(effect)
	end,
	on_effect = function(self, effect)
		local dest = effect.to
		local room = dest:getRoom()
		local recover = sgs.RecoverStruct()
		recover.card = self
		recover.who = effect.from
		room:recover(dest, recover)
	end
}

sgs.LoadTranslationTable{
	["yunEX"] = "云EX包",
	
	["liyunpeng"] = "李云鹏",
	["&liyunpeng"] = "李云鹏",
	["#liyunpeng"] = "飞女正传",
	["designer:liyunpeng"] = "李云鹏",
	["cv:liyunpeng"] = "——",
	["illustrator:liyunpeng"] = "织田信奈",	
	
	["lanyan"] = "蓝颜",
	[":lanyan"] = "锁定技，你的回合外，你的性别视为女。",
	
	["lienv"] = "烈女",
	[":lienv"] = "每当你受到异性角色造成的一次伤害后，或你对同性角色造成一次伤害后，你可以进行判定，若结果为黑色，判定牌生效后你获得之；若结果为红色，你可以弃置一张牌并选择一名已受伤的角色，该角色回复一点体力。",
	
	["EXhuaibeibei"] = "怀贝贝",
	["&EXhuaibeibei"] = "怀贝贝",
	["#EXhuaibeibei"] = "歌姬",
	["designer:EXhuaibeibei"] = "李云鹏",
	["cv:EXhuaibeibei"] = "——",
	["illustrator:EXhuaibeibei"] = "稗田阿求",
	
	["EXhanjing"] = "韩静",
	["&EXhanjing"] = "韩静",
	["#EXhanjing"] = "近君情怯",
	["designer:EXhanjing"] = "李云鹏",
	["cv:EXhanjing"] = "——",
	["illustrator:EXhanjing"] = "DH"
}

liyunpeng:addSkill(lanyan)
liyunpeng:addSkill(lienv)

EXhuaibeibei:addSkill("hongyan")
