module("extensions.yun", package.seeall)
extension = sgs.Package("yun")

sgs.LoadTranslationTable{
	["yun"] = "云包"
}

huaibeibei = sgs.General(extension, "huaibeibei", "wu", "4", false)
luatiancheng = sgs.CreateTriggerSkill{
	name = "luatiancheng",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardResponded, sgs.CardUsed, sgs.FinishJudge},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()		
		if event == sgs.CardResponded then
			local card = data:toCardResponse().m_card
			if card:getSkillName() == "hongyan" then
				if player:askForSkillInvoke("luatiancheng") then
					player:drawCards(1, self:objectName())
				end
			end
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:getSkillName() == "hongyan" then
				if player:askForSkillInvoke("luatiancheng") then
					player:drawCards(1, self:objectName())
				end
			end
		elseif event == sgs.FinishJudge then
			local judge = data:toJudge()
			local card = judge.card			
			if card:getSkillName() == "hongyan" then
				if player:askForSkillInvoke("luatiancheng") then
					player:drawCards(1, self:objectName())
				end
			end
		end
		return false
	end
}
huaibeibei:addSkill("hongyan")
huaibeibei:addSkill(luatiancheng)
sgs.LoadTranslationTable{
	["#huaibeibei"] = "变装小乔",
	["huaibeibei"] = "怀贝贝",
	["designer:huaibeibei"] = "李云鹏",
	["cv:huaibeibei"] = "——",
	["illustrator:huaibeibei"] = "稗田阿求",
	["luatiancheng"] = "天成",
	[":luatiancheng"] = "每当你使用或打出一张手牌时，或你的判定牌生效后，若触发了技能“红颜”，你可以摸一张牌。"
}

hanjing = sgs.General(extension, "hanjing", "wu", "3", false)
lualianji = sgs.CreateTriggerSkill{
	name = "lualianji",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local victim = data:toDamage().to
		local room = player:getRoom()
		local jingmeizi = room:findPlayerBySkillName(self:objectName())
		if not jingmeizi or not jingmeizi:isAlive() or jingmeizi:isNude()
				or jingmeizi:getPhase() ~= sgs.Player_NotActive 
				or not jingmeizi:canSlash(victim, nil, true) then
			return false
		end
		if jingmeizi:askForSkillInvoke(self:objectName(), data) then
			local prompt = string.format("@lualianji-slash", victim:objectName())
			if room:askForUseSlashTo(jingmeizi, victim, prompt) then
				jingmeizi:drawCards(1, self:objectName())
			end
		end
	end
}
luaqiaopoCard = sgs.CreateSkillCard{
	name = "luaqiaopoCard", 
	target_fixed = false, 
	will_throw = false, 
	on_effect = function(self, effect)
		local target = effect.to
		local room = target:getRoom()
		local damage = room:getTag("luaqiaopodamage"):toDamage()
		target:obtainCard(self)
		local damage2 = sgs.DamageStruct(self:objectName(), damage.from, target, 1, damage.nature)
		damage2.transfer = true
		room:damage(damage2)
	end
}
luaqiaopoVS = sgs.CreateOneCardViewAsSkill{
	name = "luaqiaopo",
	filter_pattern = ".|diamond",
	view_as = function(self, card)
		local qpc = luaqiaopoCard:clone()
		qpc:addSubcard(card)
		qpc:setSkillName(self:objectName())
		return qpc
	end, 
	enabled_at_play = function(self, player)
		return false
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@luaqiaopo"
	end
}
luaqiaopo = sgs.CreateTriggerSkill{
	name = "luaqiaopo", 
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.DamageInflicted}, 
	view_as_skill = luaqiaopoVS, 
	on_trigger = function(self, event, player, data) 
		local room = player:getRoom()
		if player:canDiscard(player, "he") then
			local damage = data:toDamage()
			local value = sgs.QVariant()
			room:setTag("luaqiaopodamage", data)
			local M = damage.damage
			local x = 0
			for i = 0, M-1, 1 do
				if room:askForSkillInvoke(player, self:objectName()) then
					if room:askForUseCard(player, "@@luaqiaopo", "@luaqiaopo-card") then
						x = x + 1
					end
				else 
					break
				end
			end
			if x == M then
				return true
			end
			damage.damage = M - x
			data:setValue(damage)
		end
        return false
	end, 
	priority = 2
}
hanjing:addSkill(lualianji)
hanjing:addSkill(luaqiaopo)
sgs.LoadTranslationTable{
	["#hanjing"] = "方块杀手",
	["hanjing"] = "韩静",
	["designer:hanjing"] = "李云鹏",
	["cv:hanjing"] = "——",
	["illustrator:hanjing"] = "Natsu",
	["lualianji"] = "连击",
	[":lualianji"] = "你的回合外，每当你攻击范围内的其他角色受到伤害时，你可以对其使用一张【杀】，然后你摸一张牌。",
	["@lualianji-slash"] = "对 %s 使用一张【杀】。",
	["~luaqiaopo"] = "选择一张杀 → 对该角色出杀",
	["luaqiaopo"] = "巧破",
	[":luaqiaopo"] = "每当你受到1点伤害时，你可以交给一名其他角色一张方块牌并将伤害转移之。",
	["luaqiaopoCard"] = "巧破",
	["@luaqiaopo-card"] = "交给一名角色一张方块牌来转移1点伤害。",
	["~luaqiaopo"] = "受到1点伤害 → 选择一张方块牌 → 选择一名角色 → 该角色承受1点伤害并获得这张牌"
}

wangcan = sgs.General(extension, "wangcan", "wei", "3", false)
luasiwu = sgs.CreateMasochismSkill{
	name = "luasiwu",
	frequency = sgs.Skill_Frequent,
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		local x = damage.damage
		for i = 0, x - 1, 1 do
			if player:askForSkillInvoke(self:objectName()) then
				room:drawCards(player, 1, self:objectName())
				if not player:isKongcheng() then
					local card_id
					if player:getHandcardNum() == 1 then
						card_id = player:handCards():first()
					else
						local card = room:askForExchange(player, self:objectName(), 1, 1, false, "@siwu-prompt")
						card_id = card:getEffectiveId()
					end
					player:addToPile("&wire", card_id, false)
				end
			end
		end
	end
}
luasiwuremove = sgs.CreateTriggerSkill{
	name = "#luasiwuremove",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		if data:toString() == "luasiwu" then
			player:clearOnePrivatePile("&wire")
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
luaxingcanCard = sgs.CreateSkillCard{ 
	name = "luaxingcanCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return true
	end,
	on_use = function(self, room, cancan, targets)
		local dest = targets[1]
		dest:obtainCard(self)
		room:drawCards(cancan, 1, "luaxingcan")
		if dest == cancan then
			return
		end
		local result = room:askForChoice(cancan,"luaxingcan","luaxingcan_canuse+luaxingcan_lockhandcard")
		if result == "luaxingcan_canuse" then
			local pattern = ".|.|.|&wireUse"
			dest:addToPile("&wireUse", self, false)
			if room:askForUseCard(dest, pattern, "@luaxingcan", -1, sgs.Card_MethodUse) then
			else
				local dummy = sgs.DummyCard(dest:getPile("&wireUse"))
				room:obtainCard(dest, dummy)
			end
		elseif result == "luaxingcan_lockhandcard" then
			dest:setMark("luaxingcan",1)
			room:setPlayerCardLimitation(dest, "use,response", ".|.|.|hand", true)
		end
	end
}
luaxingcanVS = sgs.CreateOneCardViewAsSkill{
	name = "luaxingcan",
	filter_pattern = ".|.|.|&wire",
    expand_pile = "&wire",
	enabled_at_play = function(self,player)
		return player:getPile("&wire"):isEmpty() == false
	end,
	view_as = function(self, card)
		local xcc = luaxingcanCard:clone()
		xcc:addSubcard(card)
		xcc:setSkillName(self:objectName())
		return xcc
	end,
}
luaxingcan = sgs.CreateTriggerSkill{
	name = "luaxingcan",
	events = {sgs.EventPhaseChanging, sgs.Death, sgs.EventLoseSkill},
	view_as_skill = luaxingcanVS,
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data) 
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if(death.who:objectName() ~= player:objectName() or player:objectName() ~= room:getCurrent():objectName()) then
				return false
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() ~= self:objectName() then return false end
		end
		for _, p in sgs.qlist(room:getAllPlayers()) do 
			if p:getMark(self:objectName()) > 0 then
				p:removeMark(self:objectName())
				room:removePlayerCardLimitation(p, "use,response", ".|.|.|hand$1");
			end
		end
	end
}
luaxingcan_buff = sgs.CreateTriggerSkill{
	name = "#luaxingcan_buff",
	events = {sgs.EnterDying, sgs.QuitDying},
	can_trigger = function(self, target)
		return target:getMark("luaxingcan") > 0
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EnterDying then
			room:removePlayerCardLimitation(player, "use,response", ".|.|.|hand$1");
		else
			room:setPlayerCardLimitation(player, "use,response", ".|.|.|hand", true)
		end
	end
}
wangcan:addSkill(luasiwu)
wangcan:addSkill(luasiwuremove)
extension:insertRelatedSkills("luasiwu","#luasiwuremove")
wangcan:addSkill(luaxingcan)
wangcan:addSkill(luaxingcan_buff)
extension:insertRelatedSkills("luaxingcan","#luaxingcan_buff")
sgs.LoadTranslationTable{
	["#wangcan"] = "星光飞舞",
	["wangcan"] = "王灿",
	["designer:wangcan"] = "李云鹏",
	["cv:wangcan"] = "——",
	["illustrator:wangcan"] = "爱丽丝·玛格特罗依德",
	["luasiwu"] = "丝舞",
	[":luasiwu"] = "每当你受到1点伤害后， 你可以摸一张牌，然后将一张手牌置于你的武将牌上。称为“丝”。（“丝”背面朝上放置）你可以将“丝”如手牌般使用或打出。",
	["&wire"] = "丝",
	["&wireUse"] = "丝",
	["@siwu-prompt"] = "请将一张手牌置于武将牌上",
	["luaxingcan"] = "星灿",
	[":luaxingcan"] = "出牌阶段， 你可以将一张“丝”交给一名角色，然后你摸一张牌。若这名角色不是你，你选择一项：该角色可以立即使用这张牌；或除处于濒死状态时，该角色不能使用或打出手牌直至回合结束。",
	["luaxingcan_canuse"] = "该角色可以立即使用这张牌",
	["luaxingcan_lockhandcard"] = "除处于濒死状态时，该角色不能使用或打出手牌直至回合结束",
	["#test"] = "%arg!!!!!!"
}
xiaosa = sgs.General(extension, "xiaosa", "wei", "4", false)
luaxiaohanVS = sgs.CreateOneCardViewAsSkill{
	name = "luaxiaohan",
	filter_pattern = "%slash",
	enabled_at_play = function(self, player)
		return sgs.Slash_IsAvailable(player)
	end,
	enabled_at_response = function(self, player, pattern)
		return sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE and pattern == "slash"
	end,
	view_as = function(self, card)
		local acard = sgs.Sanguosha:cloneCard("thunder_slash", card:getSuit(), card:getNumber())
		acard:addSubcard(card)
		acard:setSkillName(self:objectName())
		return acard
	end
}
luaxiaohan = sgs.CreateTriggerSkill{
	name = "luaxiaohan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused},
	view_as_skill = luaxiaohanVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local msg = sgs.LogMessage()
		local damage = data:toDamage()
		if damage.nature == sgs.DamageStruct_Thunder and not damage.to:isNude() then
			local msg = sgs.LogMessage()
			if room:askForSkillInvoke(player, self:objectName()) then
				room:setEmotion(player, "weapon/ice_sword")
				if player:canDiscard(damage.to, "he") then
					local card_id = room:askForCardChosen(player, damage.to, "he", self:objectName(), false,sgs.Card_MethodDiscard)
					room:throwCard(sgs.Sanguosha:getCard(card_id), damage.to, player)
					if player:isAlive() and damage.to:isAlive() and player:canDiscard(damage.to, "he") then
						card_id = room:askForCardChosen(player, damage.to, "he", self:objectName(), false, sgs.Card_MethodDiscard)
						room:throwCard(sgs.Sanguosha:getCard(card_id), damage.to, player)
					end
				end
				return true
			end
		end
		return false
	end
}
luaxiaohancompulsory = sgs.CreateTriggerSkill{
	name = "#luaxiaohancompulsory",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageForseen},
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local card = damage.card
		if card then
			if card:isKindOf("Lightning") then
				local source = room:findPlayerBySkillName(self:objectName())
				if source:isAlive() then
					local msg = sgs.LogMessage()
					msg.type = "#InvokeSkill"
					msg.from = source
					msg.arg = self:objectName()
					room:sendLog(msg)
					damage.from = source
				else
					damage.from = nil
				end
				data:setValue(damage)
			end
		end
		return false
	end
}
xiaosa:addSkill(luaxiaohan)
xiaosa:addSkill(luaxiaohancompulsory)
extension:insertRelatedSkills("luaxiaohan","#luaxiaohancompulsory")
sgs.LoadTranslationTable{
	["#xiaosa"] = "闪电奇侠",
	["xiaosa"] = "肖洒",
	["designer:xiaosa"] = "李云鹏",
	["cv:xiaosa"] = "——",
	["illustrator:xiaosa"] = "上白泽慧音",
	["luaxiaohan"] = "潇寒",
	[":luaxiaohan"] = "你可以将一张普通【杀】当【雷杀】使用；你对一名角色造成雷电伤害时，若该角色有牌，你可以防止此伤害，改为依次弃置其两张牌；<font color=\"blue\"><b>锁定技</b></font>，你是任何【闪电】造成伤害的来源。",
	["#luaxiaohancompulsory"] = "潇寒",
	["luamiyu"] = "秘雨",
	[":luamiyu"] = "结束阶段，若你已受伤，你可以选择 X 名其他角色，视为这些角色各判定一次【闪电】。X 为你已损失体力值的一半（向上取整）。"
	
}
-- yangwenqi = sgs.General(extension, "yangwenqi", "shu", "4", false)
-- lishuyu = sgs.General(extension, "lishuyu", "shu", "3", false)
sgs.LoadTranslationTable{
	["#yangwenqi"] = "佼佼者",
	["yangwenqi"] = "杨文琦",
	["designer:yangwenqi"] = "李云鹏",
	["cv:yangwenqi"] = "——",
	["illustrator:yangwenqi"] = "红美玲",
	
	["#lishuyu"] = "咒术师",
	["lishuyu"] = "李淑玉",
	["designer:lishuyu"] = "李云鹏",
	["cv:lishuyu"] = "——",
	["illustrator:lishuyu"] = "博丽灵梦"
}
