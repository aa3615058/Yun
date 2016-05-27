module("extensions.yun", package.seeall)
extension = sgs.Package("yun")
sgs.LoadTranslationTable{
	["yun"] = "云包"
}

luatiancheng = sgs.CreateTriggerSkill{
	name = "luatiancheng",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardResponded, sgs.CardUsed, sgs.FinishJudge, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data, room)
		local card
		if event == sgs.CardResponded then
			card = data:toCardResponse().m_card
		elseif event == sgs.CardUsed then
			card = data:toCardUse().card
		elseif event == sgs.FinishJudge then
			card = data:toJudge().card
		elseif event == sgs.EventPhaseChanging then
			if data:toPhaseChange().to == sgs.Player_NotActive then
				player:loseAllMarks("@hongyantiancheng")
			end
			return false
		end
		count = 0;
		if card then
			if card:getSkillName() == "hongyan" then
				count = count + 1
			elseif (not card:isKindOf("SkillCard")) and card:subcardsLength() > 0 then
				local subcards = card:getSubcards()
				for _, id in sgs.qlist(subcards) do
					if sgs.Sanguosha:getCard(id):getSkillName() == "hongyan" then
						count = count + 1
					end
				end
			end
		end
		for i = 0, count - 1, 1 do
			if player:askForSkillInvoke(self) then
				drawFlag = true
				if player:getPhase() == sgs.Player_Play then
					if player:hasFlag("tianchengOdd") then
						drawFlag = false
						player:gainMark("@hongyantiancheng")
						room:setPlayerFlag(player, "-tianchengOdd")
					else
						player:setFlags("tianchengOdd")
					end
				end
				if drawFlag then
					player:drawCards(1, self:objectName())
				end
			end
		end
		return false
	end
}
luatianchengkeep = sgs.CreateMaxCardsSkill{
	name = "#luatianchengkeep",
	frequency = sgs.Skill_Frequent,
	extra_func = function(self, target)
		if target:hasSkill(self) then
			return target:getMark("@hongyantiancheng")
		else
			return 0
		end
	end
}
huaibeibei = sgs.General(extension, "huaibeibei", "wu", 4, false)
huaibeibei:addSkill("hongyan")
huaibeibei:addSkill(luatiancheng)
huaibeibei:addSkill(luatianchengkeep)
extension:insertRelatedSkills("luatiancheng","#luatianchengkeep")
sgs.LoadTranslationTable{
	["#huaibeibei"] = "知心姐姐",
	["huaibeibei"] = "怀贝贝",
	["designer:huaibeibei"] = "飞哥",
	["cv:huaibeibei"] = "——",
	["illustrator:huaibeibei"] = "稗田阿求",
	["luatiancheng"] = "天成",
	[":luatiancheng"] = "每当你使用或打出一张手牌时，或你的判定牌生效后，若触发了技能“红颜”，你可以摸一张牌。若此时是你的出牌阶段且你本阶段已发动“天成”的次数为奇数，将“摸一张牌”改为“令本回合你的手牌上限+1”。"
}

lualianji = sgs.CreateTriggerSkill{
	name = "lualianji",
	events = {sgs.Damage},
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data, room)
		local victim = data:toDamage().to
		local jingmeizis = sgs.SPlayerList()

		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasSkill(self) and p:isAlive() and p:getPhase() == sgs.Player_NotActive and p:canSlash(victim) and not (p:isNude()) then
				jingmeizis:append(p)
			end
		end
		for _, jingmeizi in sgs.qlist(jingmeizis) do
			if room:askForUseSlashTo(jingmeizi, victim, "@lualianji-slash") then
				room:notifySkillInvoked(jingmeizi, self:objectName())
				local msg = sgs.LogMessage()
				msg.type = "#InvokeSkill"
				msg.from = jingmeizi
				msg.arg = self:objectName()
				room:sendLog(msg)
				jingmeizi:drawCards(1, self:objectName())
			end
		end
	end
}
luaqiaopoCard = sgs.CreateSkillCard{
	name = "luaqiaopoCard", 
	will_throw = false,
	mute = true,
	handling_method = sgs.Card_MethodNone,
	on_effect = function(self, effect)
		local target = effect.to
		local damage = effect.from:getTag("luaqiaopodamage"):toDamage()
		target:obtainCard(self)
		local damage2 = sgs.DamageStruct("luaqiaopo", damage.from, target, 1, damage.nature)
		damage2.transfer = true
		damage2.transfer_reason="luaqiaopo";
		target:getRoom():damage(damage2)
	end
}
luaqiaopoVS = sgs.CreateOneCardViewAsSkill{
	name = "luaqiaopo",
	filter_pattern = ".|diamond",
	response_pattern = "@@luaqiaopo",
	view_as = function(self, card)
		local luaqiaopocard = luaqiaopoCard:clone()
		luaqiaopocard:addSubcard(card)
		return luaqiaopocard
	end
}
luaqiaopo = sgs.CreateTriggerSkill{
	name = "luaqiaopo", 
	events = {sgs.DamageInflicted}, 
	view_as_skill = luaqiaopoVS, 
	on_trigger = function(self, event, player, data, room) 
		if player:canDiscard(player, "he") then
			player:setTag("luaqiaopodamage", data)
			local damage = data:toDamage()
			local M = damage.damage
			local x = 0
			for i = 0, M-1, 1 do
				if room:askForUseCard(player, "@@luaqiaopo", "@luaqiaopo-card") then
					x = x + 1
				else 
					break
				end
			end
			if x == M then
				return true
			else
				damage.damage = M - x
				data:setValue(damage)
			end
		end
        return false
	end
}
hanjing = sgs.General(extension, "hanjing", "wu", 3, false)
hanjing:addSkill(lualianji)
hanjing:addSkill(luaqiaopo)
sgs.LoadTranslationTable{
	["#hanjing"] = "方块杀手",
	["hanjing"] = "韩静",
	["designer:hanjing"] = "飞哥",
	["cv:hanjing"] = "——",
	["illustrator:hanjing"] = "比那名居天子",
	["lualianji"] = "连击",
	[":lualianji"] = "你的回合外，每当一名角色对你攻击范围内的其他角色造成伤害后，你可以对受到伤害的角色使用一张【杀】，然后你摸一张牌。",
	["@lualianji-slash"] = "你可以对受到伤害的角色使用一张【杀】。",
	["~luaqiaopo"] = "选择一张杀 → 对该角色出杀",
	["luaqiaopo"] = "巧破",
	[":luaqiaopo"] = "每当你受到1点伤害时，你可以交给一名其他角色一张方块牌并将伤害转移之。",
	["luaqiaopoCard"] = "巧破",
	["@luaqiaopo-card"] = "交给一名角色一张方块牌来转移 1 点伤害。",
	["~luaqiaopo"] = "受到1点伤害 → 选择一张方块牌 → 选择一名角色 → 该角色承受1点伤害并获得这张牌"
}

luasiwu = sgs.CreateTriggerSkill{
	name = "luasiwu",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damaged, sgs.EventLoseSkill, sgs.EventAcquireSkill},
	--此处的can_trigger设置所有人为可触发对象，是为了on_trigger中的EventLoseSkill能够顺利执行。如果这里不这样设置，角色在失去该技能后，也就无法触发sgs.EventLoseSkill来清空相关技能了。
	can_trigger = function(self, target)
		return target
	end,
	
	on_trigger = function(self, event, player, data, room)
		if event == sgs.Damaged and player:hasSkill(self) then
			for i = 0, data:toDamage().damage - 1, 1 do
				if player:isAlive() and player:askForSkillInvoke(self) then
					player:drawCards(1, self:objectName())
					if not player:isKongcheng() then
						local card_id
						if player:getHandcardNum() == 1 then
							card_id = player:handCards():first()
						else
							card_id = room:askForExchange(player, self:objectName(), 1, 1, false, "@siwu-prompt"):getEffectiveId()
						end
						player:addToPile("&wire", card_id, false)
					end
				end
			end
		--失去技能后，“丝”仍保留，但不能使用。
		--用这种方法做出限制，因为框架源码实现“如手牌般使用或打出”是靠牌堆名字符串加"&"来实现
		--若采用移动到另一牌堆"wire"的方式实现，则“星灿”会无法使用。
		elseif event == sgs.EventLoseSkill and data:toString() == self:objectName() then
			room:setPlayerCardLimitation(player, "use,response", ".|.|.|&wire", false)
		elseif event == sgs.EventAcquireSkill and data:toString() == self:objectName() then
			room:removePlayerCardLimitation(player, "use,response", ".|.|.|&wire")
		end
	end
}

luaxingcanCard = sgs.CreateSkillCard{ 
	name = "luaxingcanCard",
	mute = true,
    will_throw = false,
    handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		return true
	end,
	on_effect = function(self, effect)
		local cancan = effect.from
		local dest = effect.to
		local room = cancan:getRoom()
		dest:obtainCard(self)
		cancan:drawCards(1, "luaxingcan")
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
			if dest:getMark("@ningxingcanyu") == 0 then
				dest:gainMark("@ningxingcanyu")
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
		return not player:hasUsed("#luaxingcanCard") and not player:getPile("&wire"):isEmpty()
	end,
	view_as = function(self, card)
		local xingcanCard = luaxingcanCard:clone()
		xingcanCard:addSubcard(card)
		return xingcanCard
	end
}
function removeXingcanMarkAndLimitation(room)
	for _, p in sgs.qlist(room:getAllPlayers()) do 
		if p:getMark("@ningxingcanyu") > 0 then
			p:loseMark("@ningxingcanyu")
			room:removePlayerCardLimitation(p, "use,response", ".|.|.|hand$1")
		end
	end
end
luaxingcan = sgs.CreateTriggerSkill{
	name = "luaxingcan",
	events = {sgs.EventPhaseChanging, sgs.EventLoseSkill, sgs.EnterDying, sgs.QuitDying, sgs.Death},
	view_as_skill = luaxingcanVS,
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data, room) 
		if event == sgs.EventPhaseChanging then
			if data:toPhaseChange().to == sgs.Player_NotActive and player:hasSkill(self) then
				removeXingcanMarkAndLimitation(room)
			end
		elseif event == sgs.EventLoseSkill then
			if player:getPhase() == sgs.Player_Play and data:toString() == self:objectName() then 
				removeXingcanMarkAndLimitation(room)
			end
		elseif player:getMark("@ningxingcanyu") > 0 and event == sgs.EnterDying then
			room:removePlayerCardLimitation(player, "use,response", ".|.|.|hand$1")
		elseif player:getMark("@ningxingcanyu") > 0 and event == sgs.QuitDying then
			room:setPlayerCardLimitation(player, "use,response", ".|.|.|hand", true)
		elseif event == sgs.Death then
			local victim = data:toDeath().who
			if victim:getPhase() == sgs.Player_Play and victim:hasSkill(self) then
				removeXingcanMarkAndLimitation(room)
			end
		end
	end
}
wangcan = sgs.General(extension, "wangcan", "wei", 3, false)
wangcan:addSkill(luasiwu)
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
	["@ningxingcanyu"]="凝星灿玉",
	["@siwu-prompt"] = "请将一张手牌置于武将牌上",
	["luaxingcan"] = "星灿",
	[":luaxingcan"] = "出牌阶段限一次， 你可以将一张“丝”交给一名角色，然后你摸一张牌。若这名角色不是你，你选择一项：该角色可以立即使用这张牌；或除处于濒死状态时，该角色不能使用或打出手牌直至回合结束。",
	["luaxingcan_canuse"] = "该角色可以立即使用这张牌",
	["luaxingcan_lockhandcard"] = "除处于濒死状态时，该角色不能使用或打出手牌直至回合结束",
	["@luaxingcan"] = "你可以立即使用获得的“丝”",
}
-- 杨文琦的两个技能，lua均无法实现
yangwenqi = sgs.General(extension, "yangwenqi", "shu", 4, false, true)
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
luaxiaohan = sgs.CreateTriggerSkill{
	name = "luaxiaohan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused, sgs.PreCardUsed},
	on_trigger = function(self, event, player, data, room)
		if event == sgs.PreCardUsed then
			local use = data:toCardUse()
			local card = use.card
			if card:objectName() == "slash" then
				--若一张【杀】是通过转化而来，“潇寒”不能二次转化
				if card:isVirtualCard() then return end
				--if card:subcardsLength() > 0 and card:getSubcards():first() ~= card:getId() then return end
				
				if room:askForSkillInvoke(player, "luaxiaohan-thunder_slash") then
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
			if damage.nature == sgs.DamageStruct_Thunder 
				and not damage.to:isNude()
				and damage.to:getMark("Equips_of_Others_Nullified_to_You") == 0
				and player:canDiscard(damage.to, "he")
				and room:askForSkillInvoke(player, "luaxiaohan-ice_sword")
				then

				room:notifySkillInvoked(player, self:objectName())
				local msg = sgs.LogMessage()
				msg.type = "#InvokeSkill"
				msg.from = player
				msg.arg = self:objectName()
				room:sendLog(msg)
					
				room:setEmotion(player, "weapon/ice_sword")
				local card_id = room:askForCardChosen(player, damage.to, "he", self:objectName(), false,sgs.Card_MethodDiscard)
				room:throwCard(sgs.Sanguosha:getCard(card_id), damage.to, player)
				if player:isAlive() and damage.to:isAlive() and player:canDiscard(damage.to, "he") then
					card_id = room:askForCardChosen(player, damage.to, "he", self:objectName(), false, sgs.Card_MethodDiscard)
					room:throwCard(sgs.Sanguosha:getCard(card_id), damage.to, player)
				end
				return true
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
	on_trigger = function(self, event, player, data, room)
		local damage = data:toDamage()
		local card = damage.card
		if card then
			if card:isKindOf("Lightning") then
				local source = room:findPlayerBySkillName(self:objectName())
				if source:isAlive() then
					room:notifySkillInvoked(source, self:objectName())
					local msg = sgs.LogMessage()
					--msg.type = "#InvokeSkill"
					msg.from = source
					--msg.arg = self:objectName()
					--room:sendLog(msg)
					msg.type = "#luaxiaohan-transfer"
					msg.arg = self:objectName()
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
	on_effect = function(self, effect)
		local dest = effect.to
		local room = dest:getRoom()
		local lightning = sgs.Sanguosha:cloneCard("Lightning", sgs.Card_NoSuit, 0)
		lightning:setSkillName("luamiyu")
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
luamiyu = sgs.CreatePhaseChangeSkill{
	name = "luamiyu",
	view_as_skill = luamiyuVS,
	on_phasechange = function(self, target)
		if target:getPhase() == sgs.Player_Finish then
			if target:isWounded() then
				target:getRoom():askForUseCard(target, "@@luamiyu", "@luamiyu")
			end
		end
		return false
	end
}
xiaosa = sgs.General(extension, "xiaosa", "wei", 4, false)
xiaosa:addSkill(luaxiaohan)
xiaosa:addSkill(luaxiaohancompulsory)
extension:insertRelatedSkills("luaxiaohan","#luaxiaohancompulsory")
xiaosa:addSkill(luamiyu)
sgs.LoadTranslationTable{
	["#xiaosa"] = "闪电奇侠",
	["xiaosa"] = "肖洒",
	["designer:xiaosa"] = "飞哥",
	["cv:xiaosa"] = "——",
	["illustrator:xiaosa"] = "上白沢慧音",
	["luaxiaohan"] = "潇寒",
	[":luaxiaohan"] = "你可以将一张普通【杀】当【雷杀】使用；你对一名角色造成雷电伤害时，若该角色有牌，你可以防止此伤害，改为依次弃置其两张牌；<font color=\"blue\"><b>锁定技</b></font>，你是任何【闪电】造成伤害的来源。",
	["#luaxiaohancompulsory"] = "潇寒",
	["#luaxiaohan-transfer"] = "%from 的“%arg”被触发，【<font color=\"yellow\"><b>闪电</b></font>】的伤害来源改为 %from",
	["luaxiaohan-thunder_slash"] = "潇寒(<font color=yellow><b>雷杀</b></font>)",
	["luaxiaohan-ice_sword"] = "潇寒(<font color=yellow><b>寒冰剑</b></font>)",
	["luamiyu"] = "秘雨",
	[":luamiyu"] = "结束阶段，若你已受伤，你可以选择至多X名其他角色，视为这些角色各判定一次【闪电】。X为你已损失体力值的一半（向上取整）。",
	["@luamiyu"] = "请选择至多X名其他角色，视为这些角色各判定一次【闪电】。X为你已损失体力值的一半（向上取整）",
	["~luamiyu"] = "选择目标 → 判定闪电",
}
luayingzhouVS = sgs.CreateOneCardViewAsSkill{
	name = "luayingzhou",
	filter_pattern = ".|.|.|hand",
	enabled_at_play = function(self, player)
		return player:hasFlag("yingzhouCanInvoke") and not player:hasFlag("yingzhouInvoked")
	end,
	view_as = function(self, card)
		local acard = sgs.Sanguosha:cloneCard(sgs.Self:property("yingzhouCard"):toString(), card:getSuit(), card:getNumber())
		acard:addSubcard(card:getId())
		acard:setSkillName(self:objectName())
		return acard
	end,
	enabled_at_response = function (self, player, pattern)
		return not player:hasFlag("yingzhouInvoked") and (player:hasFlag("yingzhouNullFication") or player:hasFlag("yingzhouBasicCard"))
	end,
	enabled_at_nullification = function(self, player)
		return player:hasFlag("yingzhouNullFication") and not player:hasFlag("yingzhouInvoked")
	end
}
luayingzhou = sgs.CreateTriggerSkill{
	name = "luayingzhou",
	events = {sgs.CardUsed, sgs.CardResponded, sgs.EventPhaseChanging},
	view_as_skill = luayingzhouVS,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.EventPhaseChanging and data:toPhaseChange().to == sgs.Player_Play then
			room:setPlayerFlag(player, "-yingzhouInvoked")
			room:setPlayerFlag(player, "-yingzhouCanInvoke")
			room:setPlayerFlag(player, "-yingzhouNullFication")
			room:setPlayerFlag(player, "-yingzhouBasicCard")
		elseif player:getPhase() == sgs.Player_Play and not player:hasFlag("yingzhouInvoked") then
			local card
			if event == sgs.CardResponded then 
				card = data:toCardResponse().m_card
			elseif event == sgs.CardUsed  then 
				card = data:toCardUse().card
			end
			if card then
				if card:getSkillName() == self:objectName() then
					room:setPlayerFlag(player, "yingzhouInvoked")
				else
					if card:isNDTrick() or card:isKindOf("BasicCard") then
						room:setPlayerFlag(player, "yingzhouCanInvoke")
						room:setPlayerProperty(player, "yingzhouCard", sgs.QVariant(card:getClassName()))

						if card:objectName() == "nullification" then
							room:setPlayerFlag(player, "yingzhouNullFication")
						elseif card:isKindOf("BasicCard") then
							room:setPlayerFlag(player, "yingzhouBasicCard")
						end
					elseif card:isKindOf("EquipCard") or card:isKindOf("TrickCard") then
						room:setPlayerFlag(player, "-yingzhouCanInvoke")
					end
				end
			end
		end
	end
}
luaqifengCard = sgs.CreateSkillCard{
	name = "luaqifengCard", 
	filter = function(self, targets, to_select)
		return #targets < 1 and not (to_select:hasFlag("qifeng_original")) and to_select:objectName() ~= sgs.Self:objectName()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	on_effect = function(self, effect)
		local target = effect.to
		local room = target:getRoom()
		local data = room:getTag("luaqifengdamage")
		local damage = data:toDamage()
		
		local invoke_transfer = false
		if target:canDiscard(target, "h") then
			if not room:askForDiscard(target, self:objectName(), 1, 1, true, true, "@luaqifeng-discard", ".|red") then
				invoke_transfer = true
			end
		else
			invoke_transfer = true
		end
		if invoke_transfer then
			local damage2 = sgs.DamageStruct(self:objectName(), damage.from, target, damage.damage, damage.nature)
			damage2.transfer = true
			
			damage.damage = 0
			data:setValue(damage)
			room:setTag("luaqifengdamage", data)
			
			room:damage(damage2)
		end
	end
}
luaqifengVS = sgs.CreateZeroCardViewAsSkill{
	name = "luaqifeng",
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@luaqifeng"
	end,
	view_as = function()
		return luaqifengCard:clone()
	end
}
luaqifeng = sgs.CreateTriggerSkill{
	name = "luaqifeng",
	events = {sgs.DamageCaused},
	view_as_skill = luaqifengVS,
	on_trigger = function(self, event, player, data, room)
		local damage = data:toDamage()
		local target = damage.to
		local transfer = false
		if damage.transfer == false then
			local can_invoke = false
			local players = room:getOtherPlayers(player)
			players:removeOne(target)
			can_invoke = players:length() > 0 and target ~= player
			if can_invoke then
				room:setTag("luaqifengdamage", data)
				room:setPlayerFlag(damage.to, "luaqifeng_original")
				if room:askForUseCard(player, "@@luaqifeng", "@luaqifeng") then
					if room:getTag("luaqifengdamage"):toDamage().damage == 0 then
						transfer = true
					end
				end
				room:setPlayerFlag(damage.to, "-luaqifeng_original")
			end
		end
		return transfer
	end
}
lishuyu = sgs.General(extension, "lishuyu", "shu", 3, false)
lishuyu:addSkill(luayingzhou)
lishuyu:addSkill(luaqifeng)
sgs.LoadTranslationTable{
	["#lishuyu"] = "咒术师",
	["lishuyu"] = "李淑玉",
	["designer:lishuyu"] = "飞哥",
	["cv:lishuyu"] = "——",
	["illustrator:lishuyu"] = "博丽灵梦",
	["luayingzhou"] = "影咒",
	[":luayingzhou"] = "出牌阶段限一次，你可以将一张手牌当你本阶段上一张使用的，且是非延时类锦囊牌或基本牌的牌使用。",
	["luaqifeng"] = "奇风",
	[":luaqifeng"] = "每当你对其他角色造成伤害时，你可以令另一名其他角色弃置一张红色牌，否则将伤害转移之。（转移的伤害不能发动“奇风”）",
	
	["@luaqifeng-discard"] = "请弃置一张红色牌，否则将会受到转移的伤害",
	["@luaqifeng"] = "请指定受伤害角色外的一名其他角色，发动“奇风”",
	["~luaqifeng"] = "选择目标 → 目标选择是否弃牌 → 弃牌 或 不弃牌转移伤害",
}
