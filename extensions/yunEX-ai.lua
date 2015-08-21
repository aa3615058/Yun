sgs.ai_skill_invoke.lualienv = true

sgs.ai_skill_playerchosen.luajianmei = function(self, targets)
	targets = sgs.QList2Table(targets)
	for _, target in ipairs(targets) do
		if self:isFriend(target) and target:isAlive() then
			return target
		end
	end
	return nil
end

sgs.ai_playerchosen_intention.luajianmei = -50