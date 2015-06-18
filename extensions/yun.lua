module("extensions.yun", package.seeall)
extension = sgs.Package("yun")

sgs.LoadTranslationTable{
["yun"] = "云包"}

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
					player:drawCards(1)
				end
			end
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:getSkillName() == "hongyan" then
				if player:askForSkillInvoke("luatiancheng") then
					player:drawCards(1)
				end
			end
		elseif event == sgs.FinishJudge then
			local judge = data:toJudge()
			local card = judge.card			
			if card:getSkillName() == "hongyan" then
				if player:askForSkillInvoke("luatiancheng") then
					player:drawCards(1)
				end
			end
		end
		return false
	end
}
huaibeibei:addSkill("hongyan")
huaibeibei:addSkill(luatiancheng)

sgs.LoadTranslationTable{
	["huaibeibei"] = "怀贝贝",
	["&huaibeibei"] = "怀贝贝",
	["#huaibeibei"] = "变装小乔",
	["designer:huaibeibei"] = "李云鹏",
	["cv:huaibeibei"] = "——",
	["illustrator:huaibeibei"] = "稗田阿求",
	
	["luatiancheng"] = "天成",
	[":luatiancheng"] = "每当你使用或打出一张手牌时，或你的判定牌生效后，若触发了技能“红颜”，你可以摸一张牌。"}

hanjing = sgs.General(extension, "hanjing", "wu", "3", false)
lualianji = sgs.CreateTriggerSkill{
	name = "lualianji",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage},
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
			local prompt = string.format("@lualianji-slash:%s", victim:objectName())
			if room:askForUseSlashTo(jingmeizi, victim, prompt) then
				jingmeizi:drawCards(1)
			end
		end
	end,
	can_trigger = function(self, target)
		return target
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
	can_trigger = function(self, target)
		return target
	end, 
	priority = 2
}
hanjing:addSkill(lualianji)
hanjing:addSkill(luaqiaopo)
sgs.LoadTranslationTable{
	["hanjing"] = "韩静",
	["&hanjing"] = "韩静",
	["#hanjing"] = "方块杀手",
	["designer:hanjing"] = "李云鹏",
	["cv:hanjing"] = "——",
	["illustrator:hanjing"] = "Natsu",
	["lualianji"] = "连击",
	[":lualianji"] = "你的回合外，每当你攻击范围内的其他角色受到伤害时，你可以对其使用一张【杀】，然后你摸一张牌。",
	["@lualianji-slash"] = "使用一张【杀】。",
	["~luaqiaopo"] = "选择一张杀 → 对该角色出杀",
	["luaqiaopo"] = "巧破",
	[":luaqiaopo"] = "每当你受到1点伤害时，你可以交给一名其他角色一张方块牌并将伤害转移之。",
	["luaqiaopoCard"] = "巧破",
	["@luaqiaopo-card"] = "交给一名角色一张方块牌来转移1点伤害。",
	["~luaqiaopo"] = "受到1点伤害 → 选择一张方块牌 → 选择一名角色 → 该角色承受1点伤害并获得这张牌"}

wangcan = sgs.General(extension, "wangcan", "wei", "3", false)
yangwenqi = sgs.General(extension, "yangwenqi", "shu", "4", false)
xiaosa = sgs.General(extension, "xiaosa", "wei", "3", false)
lishuyu = sgs.General(extension, "lishuyu", "shu", "3", false)
sgs.LoadTranslationTable{
	["wangcan"] = "王灿",
	["&wangcan"] = "王灿",
	["#wangcan"] = "星光飞舞",
	["designer:wangcan"] = "李云鹏",
	["cv:wangcan"] = "——",
	["illustrator:wangcan"] = "爱丽丝·玛格特罗依德",
	
	["yangwenqi"] = "杨文琦",
	["&yangwenqi"] = "杨文琦",
	["#yangwenqi"] = "佼佼者",
	["designer:yangwenqi"] = "李云鹏",
	["cv:yangwenqi"] = "——",
	["illustrator:yangwenqi"] = "红美玲",
	
	["xiaosa"] = "肖洒",
	["&xiaosa"] = "肖洒",
	["#xiaosa"] = "闪电奇侠",
	["designer:xiaosa"] = "李云鹏",
	["cv:xiaosa"] = "——",
	["illustrator:xiaosa"] = "上白泽慧音",
	
	["lishuyu"] = "李淑玉",
	["&lishuyu"] = "李淑玉",
	["#lishuyu"] = "咒术师",
	["designer:lishuyu"] = "李云鹏",
	["cv:lishuyu"] = "——",
	["illustrator:lishuyu"] = "博丽灵梦"
}
