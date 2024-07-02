-- Local references for shorter names and avoiding global lookup on every use
--local Get, GetNum, GetId, GetEntity, AreEqual, Set = InstGet, InstGetNum, InstGetId, InstGetEntity, InstAreEqual, InstSet
local Get, GetNum, GetCoord, GetId, GetEntity, AreEqual, Set, BeginBlock = InstGet, InstGetNum, InstGetCoord, InstGetId,
	InstGetEntity, InstAreEqual, InstSet, InstBeginBlock


 -- Lightweight Call Subroutine function - creates a simple frame.
data.instructions.subroutine =
{
	func = function(comp, state, cause, label, exec_done)
		-- Iterator is just a table to allow mutation by reference
		local it = { 0 , cause}
		BeginBlock(comp, state, it)
	end,

	next = function(comp, state, it, label, exec_done)
		-- iterator is just a one off wrapped in a table
		if it[1] ~= 0 then return true end
		it[1]=1

		-- Ripped from Jump
		--[[
		for i, v in ipairs(state.asm) do
			if v[1] == "label" and AreEqual(comp, state, label, v[3]) then
				state.counter = i
				return
			end
		end
		--]]
		fake_cause = {}
		data.instructions.jump.func(comp, state, fake_cause, label)
		-- Remove this and remove "exec_arg=false" in order to treat the next_exec tag as a the subroutine.  Eww.
		return true
	end,

	last = function(comp, state, it, label, exec_done)
		state.counter = exec_done
	end,
	exec_arg = false,
	args = {
		{ "in",   "Label", "Subroutine Label Identifier", "any" },
		{ "exec", "Done",  "Return here after Subroutine finishes" },
	},
	name = "Subroutine",
	desc = "Calls a Subroutine indicated by the Label",
	category = "Flow",
	icon = "Main/skin/Icons/Common/32x32/Request.png"
}


-- Adds an optional channel ID number to the logistics connect function.
-- Intended as a candidate replacement for .connect

data.instructions.connect_channel =
{
	func = function(comp, state, cause, index)
		local ix = GetNum(comp, state, index)
		-- I'm so sorry, but it isn't in a more accessible format.
		if ix == 0 then
			comp.owner.disconnected = false
		elseif ix == 1 then
			comp.owner.logistics_channel_1 = true
		elseif ix == 2 then
			comp.owner.logistics_channel_2 = true
		elseif ix == 3 then
			comp.owner.logistics_channel_3 = true
		elseif ix == 4 then
			comp.owner.logistics_channel_4 = true
		end
	end,
	args = {
		{ "in",   "Channel", "Channel Identifier", "num", true },
	},
	name = "Connect Channel",
	desc = "Connects Unit from Logistics Channel",
	category = "Unit",
	icon = "Main/skin/Icons/Common/56x56/Carry.png",
}

-- Adds an optional channel ID number to the logistics disconnect function.
data.instructions.disconnect_channel =
{
	func = function(comp, state, cause, index)
		local ix = GetNum(comp, state, index)
		if ix == 0 then
			comp.owner.disconnected = true
		elseif ix == 1 then
			comp.owner.logistics_channel_1 = false
		elseif ix == 2 then
			comp.owner.logistics_channel_2 = false
		elseif ix == 3 then
			comp.owner.logistics_channel_3 = false
		elseif ix == 4 then
			comp.owner.logistics_channel_4 = false
		end
	end,
	args = {
		{ "in",   "Channel", "Channel Identifier", "num", true },
	},
	name = "Disconnect Channel",
	desc = "Disconnects Units from Logistics Channel",
	category = "Unit",
	icon = "Main/skin/Icons/Common/56x56/Carry.png",
}


------------- Register Links


-- Iterate over register links
data.instructions.for_register_links =
{
	func = function(comp, state, cause,  from_reg, to_reg, exec_done)
		local owner = comp.owner
		local links = owner:GetRegisterLinks()
		print(links)
		local it = { 2 }
		for i, row in ipairs(links) do
			table.insert(it, row)
		end
		return BeginBlock(comp, state, it)
	end,

	next = function(comp, state, it, from_reg, to_reg, exec_done)
		local i = it[1]
		if i > #it then return true end
		Set(comp, state, from_reg, { num = it[i].source_index })
		Set(comp, state, to_reg, {num = it[i].index} )
		it[1] = i + 1
	end,

	last = function(comp, state, it, from_reg, to_reg, exec_done)
		Set(comp, state, from_reg, nil)
		Set(comp, state, to_reg, nil)
		state.counter = exec_done
	end,

	args = {
		{ "out", "From", "Link Source" },
		{ "out", "To", "Link Destination",  },
		{ "exec", "Done", "Finished looping through all entities with signal" },
	},
	name = "Loop Register Links",
	desc = "Loops through Register Links",
	category = "Register Links",
	icon = "Main/skin/Icons/Special/Commands/Make Order.png",
}

-- Set a specific Link
data.instructions.set_register_link =
{
	func = function(comp, state, cause, from_reg, to_reg)
		local owner = comp.owner
		owner:LinkRegisterFromRegister(
			GetNum(comp, state, from_reg),
			GetNum(comp, state, to_reg)
		)
	end,
	args = {
		{ "in",   "From", "Link Source", "num" },
		{ "in",   "To", "Link Destination", "num" },
	},
	name = "Link Register",
	desc = "Links two registers together",
	category = "Register Links",
	icon = "Main/skin/Icons/Common/56x56/Carry.png",
}

-- Delete a specific Link
data.instructions.unset_register_link =
{
	func = function(comp, state, cause, from_reg, to_reg)
		local owner = comp.owner
		owner:UnlinkRegisterFromRegister(
			GetNum(comp, state, from_reg),
			GetNum(comp, state, to_reg)
		)
	end,
	args = {
		{ "in",   "From", "Link Source", "num" },
		{ "in",   "To", "Link Destination", "num" },
	},
	name = "Unlink Register",
	desc = "Unlinks two registers",
	category = "Register Links",
	icon = "Main/skin/Icons/Common/56x56/Carry.png",
}