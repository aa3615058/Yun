module("extensions.yunEX", package.seeall)
extension = sgs.Package("yunEX")

sgs.LoadTranslationTable{
	["yunEX"] = "云EX包"
}

liyunpeng = sgs.General(extension, "liyunpeng", "wu", "3", true)
liyunpeng_female = sgs.General(extension, "liyunpeng_female", "wu", "3", false, true, true)
-- function notifyLualanyanInvoked(skill_name, player, room)
	-- local msg = sgs.LogMessage()
	-- msg.type = "#InvokeSkill"
	-- msg.from = player
	-- msg.arg = skill_name
	-- room:sendLog(msg)
	-- msg.type = "#lualanyan"
	-- room:sendLog(msg)
-- end
function liyunpengImageChanged(name, player, room)
	if player:getGeneralName() == name or player:getGeneral2Name() == name then
		return
	end
	if name == "liyunpeng_female" then
		local msg = sgs.LogMessage()
		msg.type = "#InvokeSkill"
		msg.from = player
		msg.arg = "lualanyan"
		room:sendLog(msg)
		msg.type = "#lualanyan"
		room:sendLog(msg)
	end
	if player:getGeneralName() == "liyunpeng" or player:getGeneralName() == "liyunpeng_female" then
		room:changeHero(player, name, false, false, false, false)
	end
	if player:getGeneral2Name() == "liyunpeng" or player:getGeneral2Name() == "liyunpeng_female" then
		room:changeHero(player, name, false, false, true, false)
	end
end
lualanyan = sgs.CreateTriggerSkill{
	name = "lualanyan",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd, sgs.EventAcquireSkill, sgs.EventLoseSkill,sgs.GameStart},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local skill_name = self:objectName()
		
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				player:setGender(player:getGeneral():getGender())
				liyunpengImageChanged("liyunpeng", player, room)
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Finish then
				player:setGender(sgs.General_Female)
				liyunpengImageChanged("liyunpeng_female", player, room)
			end
		elseif event == sgs.GameStart then
			player:setGender(sgs.General_Female)
			liyunpengImageChanged("liyunpeng_female", player, room)
		elseif event == sgs.EventLoseSkill and data:toString() == self:objectName() then
			player:setGender(player:getGeneral():getGender())
		elseif event == sgs.EventAcquireSkill and data:toString() == self:objectName() then
			if player:getPhase() == sgs.Player_NotActive then
				player:setGender(sgs.General_Female)
				liyunpengImageChanged("liyunpeng_female", player, room)
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
					if not player:isNude() then
						room:askForUseCard(player, "@@lualienv", "@lualienv_prompt")
					end
				end
				return false
			end
		end
		if flag then
			if room:askForSkillInvoke(player, "lualienv") then
				local judge = sgs.JudgeStruct()
				judge.good = true
				judge.reason = "lualienv"
				judge.who = player
				room:judge(judge)
			end
		end
		return false
	end
}
liyunpeng:addSkill(lualanyan)
liyunpeng:addSkill(lualienv)
liyunpeng_female:addSkill(lualanyan)
liyunpeng_female:addSkill(lualienv)
sgs.LoadTranslationTable{
	["#liyunpeng"] = "飞女正传",
	["liyunpeng"] = "李云鹏",
	["designer:liyunpeng"] = "飞哥",
	["cv:liyunpeng"] = "——",
	["illustrator:liyunpeng"] = "织田信奈",	
	["lualanyan"] = "蓝颜",
	[":lualanyan"] = "<font color=\"blue\"><b>锁定技</b></font>，你的回合外，你的性别视为女。",
	["#lualanyan"] = "%from 在回合外的性别视为 <font color=\"yellow\"><b>女性</b></font>",
	["lualienv"] = "烈女",
	[":lualienv"] = "每当你受到异性角色造成的一次伤害后，或你对同性角色造成一次伤害后，你可以进行一次判定，若结果为黑色，你获得此牌；若结果为红色，你可以弃置一张牌令一名已受伤的角色回复一点体力。",
	["@lualienv_prompt"] = "\"烈女\"判定结果为红色，你可以弃一张牌（包括装备）令任意一名角色回复一点体力。",
	["~lualienv"] = "请弃一张牌（包括装备）并指定一名已受伤角色。",
	["#liyunpeng_female"] = "飞女正传",
	["liyunpeng_female"] = "李云鹏",
	["designer:liyunpeng_female"] = "飞哥",
	["cv:liyunpeng_female"] = "——",
	["illustrator:liyunpeng_female"] = "织田信奈",	
}

-- EXhuaibeibei = sgs.General(extension, "EXhuaibeibei$", "wu", "4", false)
-- EXhuaibeibei:addSkill("hongyan")
sgs.LoadTranslationTable{	
	["#EXhuaibeibei"] = "歌姬",
	["EXhuaibeibei"] = "怀贝贝",
	["designer:EXhuaibeibei"] = "飞哥",
	["cv:EXhuaibeibei"] = "——",
	["illustrator:EXhuaibeibei"] = "稗田阿求"
}

EXhanjing = sgs.General(extension, "EXhanjing", "wu", "3", false, true)
luapingfeng = sgs.CreateTriggerSkill {
	name = "luapingfeng",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime, sgs.EventAcquireSkill, sgs.EventLoseSkill, sgs.GameStart},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			room:handleAcquireDetachSkills(player, "feiying")
		elseif event == sgs.EventLoseSkill and data:toString() == self:objectName() then
			room:handleAcquireDetachSkills(player,"-feiying|-liuli",true)
		elseif event == sgs.EventAcquireSkill and data:toString() == self:objectName() then
			if player:hasEquip() then
				room:handleAcquireDetachSkills(player, "liuli")
			else
				room:handleAcquireDetachSkills(player, "feiying")
			end
		elseif event == sgs.CardsMoveOneTime and player:isAlive() and player:hasSkill(self:objectName(),true) then
			local move = data:toMoveOneTime()
			if move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceEquip then
				if player:getEquips():length() == 1 then
					room:handleAcquireDetachSkills(player,"-feiying|liuli")
				end
			elseif move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceEquip) then
				if not player:hasEquip() then
					room:handleAcquireDetachSkills(player,"feiying|-liuli", true)
				end
			end
		end
		return false
	end
}
luaduanyan = sgs.CreateTriggerSkill {
	name = "luaduanyan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getGender() ~= sgs.General_Male or player:getPhase() ~= sgs.Player_Start then
			return false
		end
		local jingmeizi = room:findPlayerBySkillName(self:objectName())
		if not jingmeizi or not jingmeizi:isAlive() or not jingmeizi:canDiscard(jingmeizi, "he")
				or jingmeizi:getPhase() == sgs.Player_Play then
			return false
		end
		if room:askForSkillInvoke(jingmeizi, self:objectName()) then
			local card = room:askForCard(jingmeizi, ".|diamond", "@luaduanyan-prompt", 
								sgs.QVariant(), sgs.Card_MethodNone)
			if card then
				player:obtainCard(card)
				room:damage(sgs.DamageStruct(self:objectName(), jingmeizi, player))
				local x = math.floor(player:distanceTo(jingmeizi) / 2)
				if x > 0 then
					room:drawCards(player, x, self:objectName())
				end
			end
		end
		return false
	end
}
EXhanjing:addSkill(luaduanyan)
EXhanjing:addSkill(luapingfeng)
sgs.LoadTranslationTable{
	["#EXhanjing"] = "近君情怯",
	["EXhanjing"] = "韩静",
	["designer:EXhanjing"] = "飞哥",
	["cv:EXhanjing"] = "——",
	["illustrator:EXhanjing"] = "DH",
	["luapingfeng"] = "凭风",
	[":luapingfeng"] = "<font color=\"blue\"><b>锁定技</b></font>，你的装备区没有牌时，视为你拥有技能“飞影”；你的装备区有牌时，视为你拥有技能“流离”。",
	["luaduanyan"] = "断雁",
	[":luaduanyan"] = "一名男性角色的准备阶段开始时，你可以交给其一张方块牌，这名角色受到你造成的1点伤害并摸X张牌，X为这名角色与你的距离的一半（向下取整）。",
	["@luaduanyan-prompt"] = "你可以交给这名角色一张方块牌，这名角色受到你造成的1点伤害并摸X张牌，X为这名角色与你的距离的一半（向下取整）。"
}