module("extensions.yunEX", package.seeall)
extension = sgs.Package("yunEX")

sgs.LoadTranslationTable{
	["yunEX"] = "云EX包"
}

liyunpeng = sgs.General(extension, "liyunpeng", "wu", "3", true)
luaLanYan = sgs.CreateTriggerSkill{
	name = "luaLanYan",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventAcquireSkill, sgs.EventLoseSkill, sgs.EventPhaseStart},
	
	on_trigger = function(self, event, player, data)
		if event == sgs.EventLoseSkill and data:toString() == self:objectName() then
			player:setGender(player:getGeneral():getGender())
		elseif event == sgs.EventAcquireSkill and data:toString() == self:objectName() then
			player:getPhase() == sgs.Player_NotActive then
				room:notifySkillInvoked(player,self:objectName())
				player:setGender(sgs.General_Female)
			end
		else
			if player:getPhase() == sgs.Player_Finish then
				room:notifySkillInvoked(player,self:objectName())
				player:setGender(sgs.General_Female)
			elseif player:getPhase() == sgs.Player_Start then
				room:notifySkillInvoked(player,self:objectName())
				player:setGender(player:getGeneral():getGender())
			end
		end
        return false
	end
}

luaLieNvCard = sgs.CreateSkillCard{
	name = "luaLieNvCard",
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
luaLieNvVS = sgs.CreateOneCardViewAsSkill{
	name = "luaLieNv",
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, card) 
		local lnc = luaLieNvCard:clone()
		lnc:addSubcard(card)
		lnc:setSkillName(self:objectName())
		return lnc
	end, 
	enabled_at_play = function(self, player)
		return false
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@luaLieNv"
	end
}
luaLieNv = sgs.CreateTriggerSkill{
	name = "luaLieNv",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage, sgs.Damaged, sgs.FinishJudge},
	view_as_skill = luaLieNvVS, 
	
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
				else
					room:askForUseCard(player, "@@luaLieNv", "@luaLieNv_prompt")
				end
				return false
			end
		end
		if flag then
			if player:askForSkillInvoke("luaLieNv") then
				local judge = sgs.JudgeStruct()
				judge.good = true
				judge.reason = "luaLieNv"
				judge.who = player
				room:judge(judge)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
liyunpeng:addSkill(luaLanYan)
liyunpeng:addSkill(luaLieNv)
sgs.LoadTranslationTable{
	["liyunpeng"] = "李云鹏",
	["&liyunpeng"] = "李云鹏",
	["#liyunpeng"] = "飞女正传",
	["designer:liyunpeng"] = "李云鹏",
	["cv:liyunpeng"] = "——",
	["illustrator:liyunpeng"] = "织田信奈",	
	
	["luaLanYan"] = "蓝颜",
	[":luaLanYan"] = "锁定技，你的回合外，你的性别视为女。",
	
	["luaLieNv"] = "烈女",
	[":luaLieNv"] = "每当你受到异性角色造成的一次伤害后，或你对同性角色造成一次伤害后，你可以进行一次判定，若结果为黑色，你获得此牌；若结果为红色，你可以弃置一张牌令一名已受伤的角色回复一点体力。",
	["@luaLieNv_prompt"] = "\"烈女\"判定结果为红色，你可以弃一张牌（包括装备）令任意一名角色回复一点体力。",
	["~luaLieNv"] = "请弃一张牌（包括装备）并指定一名已受伤角色。"
}

EXhuaibeibei = sgs.General(extension, "EXhuaibeibei$", "wu", "4", false)
EXhuaibeibei:addSkill("hongyan")
sgs.LoadTranslationTable{	
	["EXhuaibeibei"] = "怀贝贝",
	["&EXhuaibeibei"] = "怀贝贝",
	["#EXhuaibeibei"] = "歌姬",
	["designer:EXhuaibeibei"] = "李云鹏",
	["cv:EXhuaibeibei"] = "——",
	["illustrator:EXhuaibeibei"] = "稗田阿求"
}
EXhanjing = sgs.General(extension, "EXhanjing", "wu", "3", false)
luaPingFeng = sgs.CreateTriggerSkill {
	name = "luaPingFeng",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime, sgs.EventAcquireSkill, sgs.EventLoseSkill},
	
	on_trigger = function(self, event, player, data) {
		local room = player:getRoom()
		if event == sgs.EventLoseSkill and data:toString() == self:objectName() then
			room:handleAcquireDetachSkills(player,"-feiying|-liuli",true)
		elseif event == sgs.EventAcquireSkill and data:toString() == self:objectName() then
			room:notifySkillInvoked(player,self:objectName())
			if player:hasEquip() then
				room:handleAcquireDetachSkills(player,"liuli")
			else
				room:handleAcquireDetachSkills(player,"feiying")
			end
		elseif event == sgs.CardsMoveOneTime and player:isAlive() and player:hasSkill(self:objectName(),true) then
			local move = data:toMoveOneTime()
			if move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceEquip then
				if player:getEquips():length() == 1 then
					room:notifySkillInvoked(player,self:objectName())
					room:handleAcquireDetachSkills(player,"-feiying|liuli")
				end
			elseif move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceEquip) then
				if not player:hasEquip() then
					room:notifySkillInvoked(player,self:objectName())
					room:handleAcquireDetachSkills(player,"feiying|-liuli", true)
				end
			end
		end
		return false
	}
}
EXhanjing:addSkill(luaPingFeng)
sgs.LoadTranslationTable{
	["EXhanjing"] = "韩静",
	["&EXhanjing"] = "韩静",
	["#EXhanjing"] = "近君情怯",
	["designer:EXhanjing"] = "李云鹏",
	["cv:EXhanjing"] = "——",
	["illustrator:EXhanjing"] = "DH",
	
	["luaPingFeng"] = "凭风",
	[":luaPingFeng"] = "锁定技，你的装备区没有牌时，视为你拥有“飞影”的技能；你的装备区有牌时，视为你拥有“流离”的技能。"
}
