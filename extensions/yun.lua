module("extensions.yun", package.seeall)
extension = sgs.Package("yun")

liyunpeng = sgs.General(extension, "liyunpeng", "wu", "3", true)
huaibeibei = sgs.General(extension, "huaibeibei", "wu", "4", false)
hanjing = sgs.General(extension, "hanjing", "wu", "3", false)
wangcan = sgs.General(extension, "wangcan", "wei", "3", false)
yangwenqi = sgs.General(extension, "yangwenqi", "shu", "4", false)
xiaosa = sgs.General(extension, "xiaosa", "wei", "3", false)
lishuyu = sgs.General(extension, "lishuyu", "shu", "3", false)

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
	["yun"] = "云包",
	
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
	
	["huaibeibei"] = "怀贝贝",
	["&huaibeibei"] = "怀贝贝",
	["#huaibeibei"] = "变装小乔",
	["designer:huaibeibei"] = "李云鹏",
	["cv:huaibeibei"] = "——",
	["illustrator:huaibeibei"] = "稗田阿求",
	["luatiancheng"] = "天成",
	[":luatiancheng"] = "每当你使用或打出一张手牌时，或你的判定牌生效后，若出发了技能“红颜”，你可以摸一张牌。",
	["$luatiancheng1"] = "嗯哼~",
	["$luatiancheng2"] = "哼哼~",
	
	["hanjing"] = "韩静",
	["&hanjing"] = "韩静",
	["#hanjing"] = "方块杀手",
	["designer:hanjing"] = "李云鹏",
	["cv:hanjing"] = "——",
	["illustrator:hanjing"] = "Natsu",
	["lualianji"] = "连击",
	[":lualianji"] = "你的回合外，你攻击范围内的其他角色受到伤害时，你可以对其使用一张【杀】，然后摸一张牌。",
	["@lualianji-slash"] = "出一张【杀】。",
	["~luaqiaopo"] = "选择一张杀-对该角色出杀",
	["luaqiaopo"] = "巧破",
	[":luaqiaopo"] = "每当你受到1点伤害时，可以交给一名其他角色一张方块牌并将伤害转移之。",
	["luaqiaopoCard"] = "巧破",
	["@luaqiaopo-card"] = "交给一名角色一张方块牌来转移伤害。",
	["~luaqiaopo"] = "受到1点伤害→选择一张方块牌→选择一名角色→该角色承受这点伤害并获得这张牌",
	
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

liyunpeng:addSkill(lanyan)
liyunpeng:addSkill(lienv)

huaibeibei:addSkill("hongyan")
