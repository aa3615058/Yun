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
		local card
		if event == sgs.CardResponded then
			card = data:toCardResponse().m_card
		elseif event == sgs.CardUsed then
			card = data:toCardUse().card
		elseif event == sgs.FinishJudge then
			card = data:toJudge().card
		end
		if card and card:getSkillName() == "hongyan" then
			if room:askForSkillInvoke(player,self:objectName()) then
				player:drawCards(1)
			end
		end
		return false
	end
}
huaibeibei:addSkill("hongyan")
huaibeibei:addSkill(luatiancheng)
sgs.LoadTranslationTable{
	["#huaibeibei"] = "知心姐姐",
	["huaibeibei"] = "怀贝贝",
	["designer:huaibeibei"] = "飞哥",
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
		local jingmeizis = sgs.SPlayerList()

		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasSkill(self:objectName()) then
				jingmeizis:append(p)
			end
		end
		for _, jingmeizi in sgs.qlist(jingmeizis) do
			if not jingmeizi:isAlive() 
				or jingmeizi:isNude()
				or jingmeizi:getPhase() ~= sgs.Player_NotActive 
				or not jingmeizi:canSlash(victim, nil, true) 
				then
			elseif jingmeizi:askForSkillInvoke(self:objectName(), data) then
				if room:askForUseSlashTo(jingmeizi, victim, "@lualianji-slash") then					
					jingmeizi:drawCards(1, self:objectName())
				end
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
	["designer:hanjing"] = "飞哥",
	["cv:hanjing"] = "——",
	["illustrator:hanjing"] = "Natsu",
	["lualianji"] = "连击",
	[":lualianji"] = "你的回合外，每当你攻击范围内的其他角色受到伤害时，你可以对其使用一张【杀】，然后你摸一张牌。",
	["@lualianji-slash"] = "你可以使用一张【杀】。",
	["~luaqiaopo"] = "选择一张杀 → 对该角色出杀",
	["luaqiaopo"] = "巧破",
	[":luaqiaopo"] = "每当你受到1点伤害时，你可以交给一名其他角色一张方块牌并将伤害转移之。",
	["luaqiaopoCard"] = "巧破",
	["@luaqiaopo-card"] = "交给一名角色一张方块牌来转移 1 点伤害。",
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
			local pattern
			if dest:isWounded() then
				pattern = string.format("%s+^Nullification+^Jink|.|.|.",tostring(self:getEffectiveId()))
			else
				pattern = string.format("%s+^Nullification+^Jink+^Peach|.|.|.",tostring(self:getEffectiveId()))
			end
			room:askForUseCard(dest, pattern, "@luaxingcan", -1, sgs.Card_MethodUse)
		elseif result == "luaxingcan_lockhandcard" then
			if dest:getMark("luaxingcan") > 0 then
			else 
				dest:setMark("luaxingcan",1)
				room:setPlayerCardLimitation(dest, "use,response", ".|.|.|hand", true)
			end
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
	end
}
function removeXingcanMarkAndLimitation(room)
	for _, p in sgs.qlist(room:getAllPlayers()) do 
		if p:getMark("luaxingcan") > 0 then
			p:removeMark("luaxingcan")
			room:removePlayerCardLimitation(p, "use,response", ".|.|.|hand$1")
		end
	end
end
luaxingcan = sgs.CreateTriggerSkill{
	name = "luaxingcan",
	events = {sgs.EventPhaseChanging, sgs.EventLoseSkill, sgs.EnterDying, sgs.QuitDying},
	view_as_skill = luaxingcanVS,
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data) 
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive and player:hasSkill(self:objectName())then
				removeXingcanMarkAndLimitation(room)
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == self:objectName() then 
				removeXingcanMarkAndLimitation(room)
			end
		elseif player:getMark("luaxingcan") > 0 and event == sgs.EnterDying then
			room:removePlayerCardLimitation(player, "use,response", ".|.|.|hand$1")
		elseif player:getMark("luaxingcan") > 0 and event == sgs.QuitDying then
			room:setPlayerCardLimitation(player, "use,response", ".|.|.|hand", true)
		end
		return false
	end
}
wangcan:addSkill(luasiwu)
wangcan:addSkill(luasiwuremove)
extension:insertRelatedSkills("luasiwu","#luasiwuremove")
wangcan:addSkill(luaxingcan)
sgs.LoadTranslationTable{
	["#wangcan"] = "星光飞舞",
	["wangcan"] = "王灿",
	["designer:wangcan"] = "飞哥",
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
	["@luaxingcan"] = "你可以立即使用获得的“丝”",
}
yangwenqi = sgs.General(extension, "yangwenqi", "shu", "4", false, true)
luazhangui = sgs.CreateTargetModSkill{
	name = "luazhangui",
	frequency = sgs.Skill_NotFrequent,
	pattern = "Slash",
	distance_limit_func = function(self, player)
		if player:hasSkill(self:objectName()) and not player:hasFlag("zhangui_used") then
			return 1000
		else
			return 0
		end
	end,
	extra_target_func = function(self, player)
		if player:hasSkill(self:objectName()) and not player:hasFlag("zhangui_used") then
			return 2
		else
			return 0
		end
	end,
}
luadiaolue = sgs.CreateTriggerSkill{
	name = "luadiaolue",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageForseen},
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		return false
	end
}
yangwenqi:addSkill(luazhangui)
yangwenqi:addSkill(luadiaolue)
sgs.LoadTranslationTable{
	["#yangwenqi"] = "佼佼者",
	["yangwenqi"] = "杨文琦",
	["designer:yangwenqi"] = "飞哥",
	["cv:yangwenqi"] = "——",
	["illustrator:yangwenqi"] = "红美玲",
	["luazhangui"] = "战鬼",
	[":luazhangui"] = "出牌阶段，你有以下技能：你本回合使用的首张【杀】可以额外指定至多两名角色为目标。<font color=\"blue\"><b>锁定技</b></font>，你使用【杀】无距离限制，你使用【杀】的所有目标角色需座次连续且至少有一名目标角色与你座次相邻。",
	["luadiaolue"] = "调略",
	[":luadiaolue"] = "你可以将一张红色牌当【调虎离山】使用。",
}
xiaosa = sgs.General(extension, "xiaosa", "wei", "4", false)
luaxiaohan = sgs.CreateTriggerSkill{
	name = "luaxiaohan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused, sgs.PreCardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.PreCardUsed then
			local use = data:toCardUse()
			local card = use.card
			if card:objectName() == "slash" then
				if room:askForSkillInvoke(player, self:objectName()) then
					local acard = sgs.Sanguosha:cloneCard("thunder_slash", card:getSuit(), card:getNumber())
					acard:addSubcard(card)
					acard:setSkillName(self:objectName())
					-- 为处理酒杀而特别加入的代码
					-- 在“将普通杀当火杀/雷杀打出”的技能上，如果想要实现TriggerSkill形式而不是ViewAsSkill形式，
					-- 按照Qsanguosha-v2-0504的源码，技能代码只能集成在slash的on_use函数中
					-- 本技能因此还存在未知缺陷
					local drank = card:hasFlag("drank")
					if drank then
						room:setCardFlag(acard, "drank")
						acard:setTag("drank", sgs.QVariant(1))
					end
					
					use.card = acard
					data:setValue(use)
					room:setEmotion(player, "thunder_slash")
				end
			end
		elseif event == sgs.DamageCaused then
			local damage = data:toDamage()
			if damage.nature == sgs.DamageStruct_Thunder and not damage.to:isNude() then
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
		end
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
					msg.type = "##luaxiaohancompulsory"
					msg.arg = "lightning"
					room:sendLog(msg)
					damage.from = source
				else
					damage.from = nil
				end
				data:setValue(damage)
				return room:getThread():trigger(sgs.DamageCaused, room, source, data)
			end
		end
		return false
	end
}
luamiyuCard = sgs.CreateSkillCard{
	name = "luamiyuCard",
	filter = function(self, targets, to_select)
		local x = math.ceil(sgs.Self:getLostHp() / 2)
		return #targets < x and to_select:objectName() ~= sgs.Self:objectName()
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_effect = function(self, effect)
		local dest = effect.to
		local room = dest:getRoom()
		local lightning = sgs.Sanguosha:cloneCard("Lightning", sgs.Card_NoSuit, 0)
		lightning:setSkillName(self:objectName())
		lightning:deleteLater()
		local lightningEffect = sgs.CardEffectStruct()
		lightningEffect.card = lightning
		lightningEffect.from = effect.from
		lightningEffect.to = dest
		room:cardEffect(lightningEffect)
	end
}
luamiyuVS = sgs.CreateZeroCardViewAsSkill{
	name = "luamiyu",
	enabled_at_play = function(self, player)
		return false
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@luamiyu"
	end,
	view_as = function()
		return luamiyuCard:clone()
	end
}
luamiyu = sgs.CreateTriggerSkill{
	name = "luamiyu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = luamiyuVS,
	can_trigger = function(self, target)
		return target:hasSkill(self:objectName()) and target:isWounded()
	end,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			local room = player:getRoom()
			if room:askForSkillInvoke(player, self:objectName()) then
				room:askForUseCard(player, "@@luamiyu", "@luamiyu")
			end
		end
	end
}
xiaosa:addSkill(luaxiaohan)
xiaosa:addSkill(luaxiaohancompulsory)
extension:insertRelatedSkills("luaxiaohan","#luaxiaohancompulsory")
xiaosa:addSkill(luamiyu)
sgs.LoadTranslationTable{
	["#xiaosa"] = "闪电奇侠",
	["xiaosa"] = "肖洒",
	["designer:xiaosa"] = "飞哥",
	["cv:xiaosa"] = "——",
	["illustrator:xiaosa"] = "上白泽慧音",
	["luaxiaohan"] = "潇寒",
	[":luaxiaohan"] = "你可以将一张普通【杀】当【雷杀】使用；你对一名角色造成雷电伤害时，若该角色有牌，你可以防止此伤害，改为依次弃置其两张牌；<font color=\"blue\"><b>锁定技</b></font>，你是任何【闪电】造成伤害的来源。",
	["#luaxiaohancompulsory"] = "潇寒",
	["##luaxiaohancompulsory"] = "%from 成为【%arg】的伤害来源",
	["luamiyu"] = "秘雨",
	[":luamiyu"] = "结束阶段，若你已受伤，你可以选择至多X名其他角色，视为这些角色各判定一次【闪电】。X为你已损失体力值的一半（向上取整）。",
	["@luamiyu"] = "请选择至多X名其他角色，视为这些角色各判定一次【闪电】。X为你已损失体力值的一半（向上取整）",
	["~luamiyu"] = "选择目标 → 判定闪电",
}
lishuyu = sgs.General(extension, "lishuyu", "shu", "3", false, true)
sgs.LoadTranslationTable{	
	["#lishuyu"] = "咒术师",
	["lishuyu"] = "李淑玉",
	["designer:lishuyu"] = "飞哥",
	["cv:lishuyu"] = "——",
	["illustrator:lishuyu"] = "博丽灵梦"
}
