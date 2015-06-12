module("extensions.yun", package.seeall)
extension = sgs.Package("yun")

liyunpeng = sgs.General(extension, "liyunpeng", "wu", "3", true)
huaibeibei = sgs.General(extension, "huaibeibei", "wu", "4", false)
hanjing = sgs.General(extension, "hanjing", "wu", "3", false)
wangcan = sgs.General(extension, "wangcan", "wei", "3", false)
yangwenqi = sgs.General(extension, "yangwenqi", "shu", "4", false)
xiaosa = sgs.General(extension, "xiaosa", "wei", "3", false)
lishuyu = sgs.General(extension, "lishuyu", "shu", "3", false)



sgs.LoadTranslationTable{
	["yun"] = "云包",
	
	["liyunpeng"] = "李云鹏",
	["&liyunpeng"] = "李云鹏",
	["#liyunpeng"] = "飞女正传",
	["designer:liyunpeng"] = "李云鹏",
	["cv:liyunpeng"] = "~",
	["illustrator:liyunpeng"] = "织田信奈",	
	
	["huaibeibei"] = "怀贝贝",
	["&huaibeibei"] = "怀贝贝",
	["#huaibeibei"] = "变装小乔",
	["designer:huaibeibei"] = "李云鹏",
	["cv:huaibeibei"] = "官方，呼呼，眠眠",
	["illustrator:huaibeibei"] = "东方project 稗田阿求",
	["~huaibeibei"] = "此行远兮，君尚珍重。",
	["luatiancheng"] = "天成",
	[":luatiancheng"] = "每当你打出或使用的手牌受“红颜”影响时，或你的判定牌受“红颜”影响且生效时，你可以摸一张牌。",
	["$luatiancheng1"] = "嗯哼~",
	["$luatiancheng2"] = "哼哼~",
	
	["hanjing"] = "韩静",
	["&hanjing"] = "韩静",
	["#hanjing"] = "方块杀手",
	["designer:hanjing"] = "李云鹏",
	["cv:hanjing"] = "~",
	["illustrator:hanjing"] = "Natsu",
	["lualianji"] = "连击",
	[":lualianji"] = "你的回合外，你攻击范围内的其他角色受到伤害时，你可以对其出【杀】，然后摸一张牌。",
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
	["cv:wangcan"] = "~",
	["illustrator:wangcan"] = "东方project 爱丽丝·玛格特罗依德",
	
	["yangwenqi"] = "杨文琦",
	["&yangwenqi"] = "杨文琦",
	["#yangwenqi"] = "佼佼者",
	["designer:yangwenqi"] = "李云鹏",
	["cv:yangwenqi"] = "~",
	["illustrator:yangwenqi"] = "东方project 红美玲",
	
	["xiaosa"] = "肖洒",
	["&xiaosa"] = "肖洒",
	["#xiaosa"] = "闪电奇侠",
	["designer:xiaosa"] = "李云鹏",
	["cv:xiaosa"] = "~",
	["illustrator:xiaosa"] = "东方project 上白泽慧音",
	
	["lishuyu"] = "李淑玉",
	["&lishuyu"] = "李淑玉",
	["#lishuyu"] = "咒术师",
	["designer:lishuyu"] = "李云鹏",
	["cv:lishuyu"] = "~",
	["illustrator:lishuyu"] = "东方project 博丽灵梦"
}

huaibeibei:addSkill("hongyan")
