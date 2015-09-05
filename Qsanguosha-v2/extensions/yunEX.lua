module("extensions.yunEX", package.seeall)
extension = sgs.Package("yunEX")

sgs.LoadTranslationTable{
	["yunEX"] = "云EX包"
}

function EXliyunpengImageChanged(name, player, room)
	if player:getGeneralName() == name or player:getGeneral2Name() == name then
		return
	end
	if name == "EXliyunpeng_female" then
		local msg = sgs.LogMessage()
		msg.type = "#InvokeSkill"
		msg.from = player
		msg.arg = "lualanyan"
		room:sendLog(msg)
		msg.type = "#lualanyan"
		msg.arg = "female"
		room:sendLog(msg)
	end
	if player:getGeneralName() == "EXliyunpeng" or player:getGeneralName() == "EXliyunpeng_female" then
		room:changeHero(player, name, false, false, false, false)
	end
	if player:getGeneral2Name() == "EXliyunpeng" or player:getGeneral2Name() == "EXliyunpeng_female" then
		room:changeHero(player, name, false, false, true, false)
	end
end
lualanyan = sgs.CreateTriggerSkill{
	name = "lualanyan",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd, sgs.EventAcquireSkill, sgs.EventLoseSkill,sgs.GameStart},
	
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start and player:hasSkill(self:objectName(), true) then
				player:setGender(player:getGeneral():getGender())
				EXliyunpengImageChanged("EXliyunpeng", player, room)
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Finish and player:hasSkill(self:objectName(), true) then
				player:setGender(sgs.General_Female)
				EXliyunpengImageChanged("EXliyunpeng_female", player, room)
			end
		elseif event == sgs.GameStart and player:hasSkill(self:objectName(), true) and player:getPhase() == sgs.Player_NotActive then
			player:setGender(sgs.General_Female)
			EXliyunpengImageChanged("EXliyunpeng_female", player, room)
		elseif event == sgs.EventLoseSkill and data:toString() == self:objectName() then
			player:setGender(player:getGeneral():getGender())
		elseif event == sgs.EventAcquireSkill and data:toString() == self:objectName() then
			if player:getPhase() == sgs.Player_NotActive then
				player:setGender(sgs.General_Female)
				EXliyunpengImageChanged("EXliyunpeng_female", player, room)
			end
		end
        return false
	end
}
lualienvCard = sgs.CreateSkillCard{
	name = "lualienvCard",
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
			if room:askForSkillInvoke(player, self:objectName()) then
				local judge = sgs.JudgeStruct()
				judge.good = true
				judge.reason = self:objectName()
				judge.who = player
				room:judge(judge)
			end
		end
		return false
	end
}
EXliyunpeng = sgs.General(extension, "EXliyunpeng", "wu", "3", true)
EXliyunpeng:addSkill(lualanyan)
EXliyunpeng:addSkill(lualienv)
EXliyunpeng_female = sgs.General(extension, "EXliyunpeng_female", "wu", "3", false, true, true)
EXliyunpeng_female:addSkill(lualanyan)
EXliyunpeng_female:addSkill(lualienv)
sgs.LoadTranslationTable{
	["#EXliyunpeng"] = "飞女正传",
	["EXliyunpeng"] = "EX李云鹏",
	["designer:EXliyunpeng"] = "飞哥",
	["cv:EXliyunpeng"] = "——",
	["illustrator:EXliyunpeng"] = "织田信奈",	
	["lualanyan"] = "蓝颜",
	[":lualanyan"] = "<font color=\"blue\"><b>锁定技</b></font>，你的回合外，你的性别视为女。",
	["#lualanyan"] = "%from 在回合外的性别视为 %arg",
	["lualienv"] = "烈女",
	[":lualienv"] = "每当你受到异性角色造成的一次伤害后，或你对同性角色造成一次伤害后，你可以进行一次判定，若结果为黑色，你获得此牌；若结果为红色，你可以弃置一张牌令一名已受伤的角色回复一点体力。",
	["@lualienv_prompt"] = "技能“烈女”判定结果为红色，你可以弃一张牌（包括装备）令一名已受伤的角色回复一点体力。",
	["~lualienv"] = "请弃一张牌（包括装备）并指定一名已受伤角色。",
	["#EXliyunpeng_female"] = "飞女正传",
	["EXliyunpeng_female"] = "EX李云鹏",
	["designer:EXliyunpeng_female"] = "飞哥",
	["cv:EXliyunpeng_female"] = "——",
	["illustrator:EXliyunpeng_female"] = "织田信奈",	
}
luayigeCard = sgs.CreateSkillCard{
	name = "luayigeCard",
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:isFemale() and to_select:objectName() ~= sgs.Self:objectName()
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_effect = function(self, effect)
		local beibi = effect.from
		local general = effect.to
		local room = beibi:getRoom()		
		local skill_names = {}
		local skill_name
		local yige_skill = beibi:getTag("luayige_skill"):toString()
		
		if yige_skill ~= "" then
			room:handleAcquireDetachSkills(beibi, string.format("-%s",yige_skill), true)
		end
		beibi:removeTag("luayige_skill")
		for _, p in sgs.qlist(room:getOtherPlayers(beibi)) do 
			if p:getMark("luayige") > 0 then
				p:removeMark("luayige")
				if p:hasSkill("hongyan") then
					room:handleAcquireDetachSkills(p, string.format("-hongyan"), true)
				end
				break
			end
		end
		
		for _,skill in sgs.qlist(general:getVisibleSkillList()) do
			if skill:isLordSkill() or skill:getFrequency() == sgs.Skill_Limited or skill:getFrequency() == sgs.Skill_Wake then
				continue
			end
			if not table.contains(skill_names,skill:objectName()) then
				table.insert(skill_names,skill:objectName())
			end
		end
		table.insert(skill_names,"cancel")
		if #skill_names > 0 then
			skill_name = room:askForChoice(beibi, "luayige",table.concat(skill_names,"+"))
		end		
		if skill_name ~= "cancel" then
			beibi:setTag("luayige_skill",sgs.QVariant(skill_name))
			room:handleAcquireDetachSkills(beibi, skill_name)
			if not general:hasSkill("hongyan") then
				local give_hongyan = room:askForChoice(beibi, "@give_hongyan", "yes+no")
				if give_hongyan == "yes" then
					room:handleAcquireDetachSkills(general, "hongyan")
					general:setMark("luayige",1)
				end
			end
		end
	end
}
luayigeVS = sgs.CreateZeroCardViewAsSkill{
	name = "luayige",
	enabled_at_play = function(self, player)
		return false
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@luayige"
	end,
	view_as = function()
		return luayigeCard:clone()
	end
}
luayige = sgs.CreateTriggerSkill{
	name = "luayige",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.GameStart},
	view_as_skill = luayigeVS,
	on_trigger = function(self, event, beibi, data)
		local room = beibi:getRoom()
		local existFemale = false
		for _, p in sgs.qlist(room:getOtherPlayers(beibi)) do 
			if p:isFemale() then
				existFemale = true
				break
			end
		end
		if event == sgs.EventPhaseStart then
			if beibi:getPhase() == sgs.Player_Start and existFemale then
				room:askForUseCard(beibi, "@@luayige", "@luayige")
			end
		elseif event == sgs.GameStart then
			if not existFemale then
				local choice = room:askForChoice(beibi, self:objectName(),"#yige_convert+cancel")
				if choice == "#yige_convert" then
					room:notifySkillInvoked(beibi, self:objectName())
					local msg = sgs.LogMessage()
					msg.type = "#InvokeSkill"
					msg.from = beibi
					msg.arg = self:objectName()
					room:sendLog(msg)
					
					room:handleAcquireDetachSkills(beibi, string.format("-%s",self:objectName()))
					room:handleAcquireDetachSkills(beibi, "-luajianmei")
					room:handleAcquireDetachSkills(beibi, "luatiancheng")
				end
			end
		end
	end
}
luajianmei = sgs.CreateTriggerSkill{
	name = "luajianmei$",
	frequency = sgs.Skill_NotFrequent,
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
			local beibis = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:hasLordSkill(self:objectName()) then
					beibis:append(p)
				end
			end
			while not beibis:isEmpty() do
				local beibi = room:askForPlayerChosen(player, beibis, self:objectName(), "@luajianmei-to", true)
				if beibi then
					--注意！没有配音将导致技能执行失败！
					if not beibi:isLord() and beibi:hasSkill("weidi") then
                        room:broadcastSkillInvoke("weidi")
                    else
                        room:broadcastSkillInvoke(self:objectName());
					end
					
					room:notifySkillInvoked(beibi, self:objectName());
					local msg = sgs.LogMessage()
					msg.type = "#InvokeOthersSkill"
					msg.from = player
					msg.to:append(beibi)
					msg.arg = self:objectName()
					room:sendLog(msg)
					
					beibi:drawCards(1, self:objectName())
					beibis:removeOne(beibi)
				else
					break
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasSkill("hongyan") and not target:hasSkill(self:objectName())
	end
}
EXhuaibeibei = sgs.General(extension, "EXhuaibeibei$", "wu", "4", false)
EXhuaibeibei:addSkill("hongyan")
EXhuaibeibei:addSkill(luayige)
EXhuaibeibei:addSkill(luajianmei)
sgs.LoadTranslationTable{
	["#EXhuaibeibei"] = "歌姬",
	["EXhuaibeibei"] = "EX怀贝贝",
	["designer:EXhuaibeibei"] = "飞哥",
	["cv:EXhuaibeibei"] = "——",
	["illustrator:EXhuaibeibei"] = "稗田阿求",
	["luayige"] = "亦歌",
	[":luayige"] = "准备阶段开始时，你可以选择一名其他女性角色，直到你下次触发该技能：你可以选择拥有该角色的一项技能（除主公技、限定技与觉醒技），你可以令该角色拥有技能“红颜”。游戏开始时，若场上没有其他女性角色，你可以失去技能“亦歌”和“兼美”，获得技能“天成”。",
	["luajianmei"] = "兼美",
	[":luajianmei"] = "<font color=\"orange\"><b>主公技</b></font>，每当其他角色使用或打出一张手牌时，或其他角色的判定牌生效后，若触发了技能“红颜”，该角色可以令你摸一张牌。",
	
	["@luayige"] = "请指定一名其他女性角色，获得其一项技能，然后可以赋予其技能“红颜”。",
	["~luayige"] = "选择目标 → 选择技能 → 获得技能 → 赋予“红颜”",
	["#yige_convert"] = "失去“亦歌”和“兼美”，获得“天成”",
	["@give_hongyan"] = "赋予“红颜”？",
	["@luajianmei-to"] = "请选择“兼美”的目标角色",
}
luapingfeng = sgs.CreateTriggerSkill {
	name = "luapingfeng",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime, sgs.EventAcquireSkill, sgs.EventLoseSkill, sgs.GameStart},
	
	--此处的can_trigger设置所有人为可触发对象，是为了on_trigger中的EventLoseSkill能够顺利执行。如果这里不这样设置，角色在失去该技能后，也就无法触发sgs.EventLoseSkill来清空相关技能了。
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart and player:hasSkill(self:objectName()) then
			room:handleAcquireDetachSkills(player, "feiying")
		elseif event == sgs.EventLoseSkill and data:toString() == self:objectName() then
			room:handleAcquireDetachSkills(player, "-feiying|-liuli", true)
		elseif event == sgs.EventAcquireSkill and data:toString() == self:objectName() then
			room:notifySkillInvoked(player, self:objectName());
			if player:hasEquip() then
				room:handleAcquireDetachSkills(player, "liuli")
			else
				room:handleAcquireDetachSkills(player, "feiying")
			end
		elseif event == sgs.CardsMoveOneTime and player:isAlive() and player:hasSkill(self:objectName(), true) then
			local move = data:toMoveOneTime()
			if move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceEquip then
				if player:getEquips():length() == 1 then
					room:handleAcquireDetachSkills(player,"-feiying|liuli", true)
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
luaduanyanCard = sgs.CreateSkillCard{
	name = "luaduanyanCard",
	will_throw = false,
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local target = room:getCurrent()
		local jingmeizi = source
		target:obtainCard(self)
		room:damage(sgs.DamageStruct(self:objectName(), jingmeizi, target, 1))
		local x = math.floor(target:distanceTo(jingmeizi) / 2)
		if x > 0 then
			room:drawCards(target, x, "luaduanyan")
		end
	end
}
luaduanyanVS = sgs.CreateOneCardViewAsSkill{
	name = "luaduanyan",
	filter_pattern = ".|diamond",
	view_as = function(self, card)
		local c = luaduanyanCard:clone()
		c:addSubcard(card)
		c:setSkillName(self:objectName())
		return c
	end, 
	enabled_at_play = function(self, player)
		return false
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@luaduanyan"
	end
}
luaduanyan = sgs.CreateTriggerSkill {
	name = "luaduanyan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = luaduanyanVS, 
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getGender() ~= sgs.General_Male or player:getPhase() ~= sgs.Player_Start then
			return false
		end
		local jingmeizis = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasSkill(self:objectName()) and p:isAlive() then
				jingmeizis:append(p)
			end
		end
		for _, jingmeizi in sgs.qlist(jingmeizis) do
			if jingmeizi:canDiscard(jingmeizi, "he") then
				room:askForUseCard(jingmeizi, "@@luaduanyan", "@luaduanyan-prompt")
			end
		end
		return false
	end
}
EXhanjing = sgs.General(extension, "EXhanjing", "wu", "3", false)
EXhanjing:addSkill(luaduanyan)
EXhanjing:addSkill(luapingfeng)
sgs.LoadTranslationTable{
	["#EXhanjing"] = "近君情怯",
	["EXhanjing"] = "EX韩静",
	["designer:EXhanjing"] = "飞哥",
	["cv:EXhanjing"] = "——",
	["illustrator:EXhanjing"] = "比那名居天子",
	["luapingfeng"] = "凭风",
	[":luapingfeng"] = "<font color=\"blue\"><b>锁定技</b></font>，你的装备区没有牌时，视为你拥有技能“飞影”；你的装备区有牌时，视为你拥有技能“流离”。",
	["luaduanyan"] = "断雁",
	[":luaduanyan"] = "一名男性角色的准备阶段开始时，你可以交给其一张方块牌，这名角色受到你造成的1点伤害并摸X张牌，X为这名角色与你的距离的一半（向下取整）。",
	["@luaduanyan-prompt"] = "你可以交给这名角色一张方块牌来发动技能“断雁”。",
	["~luaduanyan"] = "交给卡牌 → 该角色受到伤害 → 该角色摸牌",
}
