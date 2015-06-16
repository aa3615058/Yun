module("extensions.yunEX", package.seeall)
extension = sgs.Package("yunEX")

liyunpeng = sgs.General(extension, "liyunpeng", "wu", "3", true)
EXhuaibeibei = sgs.General(extension, "EXhuaibeibei$", "wu", "4", false)
EXhanjing = sgs.General(extension, "EXhanjing", "wu", "3", false)

lualanyan = sgs.CreateTriggerSkill{
	name = "lualanyan",
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

lualienvCard = sgs.CreateSkillCard{
	name = "lualienvCard",
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
lualienvVS = sgs.CreateOneCardViewAsSkill{
	name = "lualienv",
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, card) 
		local lnc = lualienvCard:clone()
		lnc:addSubcard(card)
		lnc:setSkillName(self:objectName())
		return lnc
	end, 
	enabled_at_play = function(self, player)
		return false
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@lualienv"
	end
}
lualienv = sgs.CreateTriggerSkill{
	name = "lualienv",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage, sgs.Damaged, sgs.FinishJudge},
	view_as_skill = lualienvVS, 
	
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
					room:askForUseCard(player, "@@lualienv", "@lualienv_prompt")
				end
				return false
			end
		end
		if flag then
			if player:askForSkillInvoke("lualienv") then
				local judge = sgs.JudgeStruct()
				judge.good = true
				judge.reason = "lualienv"
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

luapingfeng = sgs.CreateTriggerSkill {
	name = "luapingfeng",
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

sgs.LoadTranslationTable{
	["yunEX"] = "云EX包",
	
	["liyunpeng"] = "李云鹏",
	["&liyunpeng"] = "李云鹏",
	["#liyunpeng"] = "飞女正传",
	["designer:liyunpeng"] = "李云鹏",
	["cv:liyunpeng"] = "——",
	["illustrator:liyunpeng"] = "织田信奈",	
	
	["lualanyan"] = "蓝颜",
	[":lualanyan"] = "锁定技，你的回合外，你的性别视为女。",
	
	["lualienv"] = "烈女",
	[":lualienv"] = "每当你受到异性角色造成的一次伤害后，或你对同性角色造成一次伤害后，你可以进行一次判定，若结果为黑色，你获得此牌；若结果为红色，你可以弃置一张牌令一名已受伤的角色回复一点体力。",
	["@lualienv_prompt"] = "\"烈女\"判定结果为红色，你可以弃一张牌（包括装备）令任意一名角色回复一点体力。",
	["~lualienv"] = "请弃一张牌（包括装备）并指定一名已受伤角色。",
	
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
	["illustrator:EXhanjing"] = "DH",
	
	["luapingfeng"] = "凭风",
	[":luapingfeng"] = "锁定技，你的装备区没有牌时，视为你拥有“飞影”的技能；你的装备区有牌时，视为你拥有“流离”的技能。"
}

liyunpeng:addSkill(lualanyan)
liyunpeng:addSkill(lualienv)

EXhuaibeibei:addSkill("hongyan")

EXhanjing:addSkill(luapingfeng)
