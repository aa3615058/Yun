module("extensions.yunEX", package.seeall)
extension = sgs.Package("yunEX")

EXhuaibeibei = sgs.General(extension, "EXhuaibeibei$", "wu", "4", false)
EXhanjing = sgs.General(extension, "EXhanjing", "wu", "3", false)

sgs.LoadTranslationTable{
	["yunEX"] = "云EX包",
	
	["EXhuaibeibei"] = "怀贝贝",
	["&EXhuaibeibei"] = "怀贝贝",
	["#EXhuaibeibei"] = "歌姬",
	["designer:EXhuaibeibei"] = "李云鹏",
	["cv:EXhuaibeibei"] = "~",
	["illustrator:EXhuaibeibei"] = "东方project 稗田阿求",
	
	["EXhanjing"] = "韩静",
	["&EXhanjing"] = "韩静",
	["#EXhanjing"] = "近君情怯",
	["designer:EXhanjing"] = "李云鹏",
	["cv:EXhanjing"] = "~",
	["illustrator:EXhanjing"] = "DH"
}

EXhuaibeibei:addSkill("hongyan")
