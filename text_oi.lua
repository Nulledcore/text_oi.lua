--[[ let's do this shit before everything else :3 ]]
local client_latency, client_log, client_screen_size, client_set_event_callback, entity_get_local_player, entity_get_player_resource, entity_get_prop, globals_chokedcommands, pcall, error, globals_absoluteframetime, globals_realtime, math_floor, math_min, ui_get, ui_reference = client.latency, client.log, client.screen_size, client.set_event_callback, entity.get_local_player, entity.get_player_resource, entity.get_prop, globals.chokedcommands, pcall, error, globals.absoluteframetime, globals.realtime, math.floor, math.min, ui.get, ui.reference
local screenh, screenw = client_screen_size()
local defh, defw = 300, screenw/2-400
local neww = 10
local table_insert, table_remove = table.insert, table.remove
local min, abs, sqrt, floor = math_min, math.abs, math.sqrt, math_floor
local frametimes = {}
local fps_prev = 0
local toggle = ui.new_checkbox("lua", "a", "Toggle text_oi")

--[[ let's load the surface library ]]
local surface = require('gamesense/surface')

--[[ let's give some credits :) ]]
client_log("Credits > Aviarita - Surface library | Masterlooser15 - x88 inspiration")

--[[ create fonts ]]
local logo_font = surface.create_font("cherryfont", 17, 400, {0x200})
local info_font = surface.create_font("Cambria", 17, 700, {0x200})
local small_font = surface.create_font("Small Fonts", 8, 100, {0x200})
local default_font = surface.create_font("Tahoma", 13, 400, {0x200})
local active_font = surface.create_font("Tahoma", 13, 700, {0x200})

--[[ references ]]
--[[ > rage ]]
local rage_active = ui_reference("rage", "aimbot", "enabled")
local rage_target = ui_reference("rage", "aimbot", "target selection")
local rage_mp_scale = ui_reference("rage", "aimbot", "multi-point scale")
local rage_autofire = ui_reference("rage", "aimbot", "automatic fire")
local rage_autowall = ui_reference("rage", "aimbot", "automatic penetration")
local rage_silentaim = ui_reference("rage", "aimbot", "silent aim")
local rage_hitchance = ui_reference("rage", "aimbot", "minimum hit chance")
local rage_mindmg = ui_reference("rage", "aimbot", "minimum damage")
local rage_autoscope = ui_reference("rage", "aimbot", "automatic scope")
local rage_aimstep = ui_reference("rage", "aimbot", "reduce aim step")
local rage_norecoil = ui_reference("rage", "other", "remove recoil")
local rage_accboost = ui_reference("rage", "other", "accuracy boost")
local rage_autostop= ui_reference("rage", "other", "quick stop")
local rage_resolver = ui_reference("rage", "other", "anti-aim correction")

--[[ > anti-aim ]]
local aa_enable = ui_reference("aa", "anti-aimbot angles", "enabled")
local aa_pitch = ui_reference("aa", "anti-aimbot angles", "pitch")
local aa_yaw = ui_reference("aa", "anti-aimbot angles", "yaw")
local aa_yaw_jitter = ui_reference("aa", "anti-aimbot angles", "yaw jitter")
local aa_desync_yaw = ui_reference("aa", "anti-aimbot angles", "body yaw")
local aa_lby = ui_reference("aa", "anti-aimbot angles", "lower body yaw target")
local aa_fakelag = ui_reference("aa", "fake lag", "enabled")
local aa_fakelag_amount = ui_reference("aa", "fake lag", "amount")
local aa_fakelag_variance = ui_reference("aa", "fake lag", "variance")
local aa_fakelag_limit = ui_reference("aa", "fake lag", "limit")
local aa_infduck = ui_reference("misc", "movement", "infinite duck")
local aa_onshot = ui_reference("aa", "other", "on shot anti-aim")

--[[ > legit ]]
local l_aimbot = ui_reference("legit", "aimbot", "enabled")
local l_triggerbot = ui_reference("legit", "triggerbot", "enabled")
local l_backtrack = ui_reference("legit", "other", "accuracy boost")
local l_reaction = ui_reference("legit", "aimbot", "reaction time")
local l_fov = ui_reference("legit", "aimbot", "maximum fov")

--[[ draw functions ]]
local function draw_rage(neww)
	surface.draw_text(defh+20, defw-2, 236, 240, 241, 255, small_font, "RAGE")
	surface.draw_text(defh, defw, 236, 240, 241, 255, logo_font, "A")

	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "Aimbot:")
	surface.draw_text(defh+55, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", string.format("%s", ui_get(rage_active))))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "Target:")
	surface.draw_text(defh+55, defw+neww, 46, 204, 113, 255, active_font, string.format("%s", ui_get(rage_target)))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "MP Scale:")
    surface.draw_text(defh+65, defw+neww, 52, 152, 219, 255, active_font, string.format("%s", ui_get(rage_mp_scale).."%"))
    
	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "AutoFire:")
	surface.draw_text(defh+63, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", ui_get(rage_autofire)))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "AutoWall:")
	surface.draw_text(defh+65, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", ui_get(rage_autowall)))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "SilentAim:")
	surface.draw_text(defh+65, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", ui_get(rage_silentaim)))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "HitChance:")
	if ui_get(rage_hitchance) <= 0 then
		hitchance = "Off"
		hitchanceR, hitchanceG, hitchanceB = 44, 62, 80
	else
		hitchance = ui_get(rage_hitchance).."%"
		hitchanceR, hitchanceG, hitchanceB = 52, 152, 219
	end
	surface.draw_text(defh+70, defw+neww, hitchanceR, hitchanceG, hitchanceB, 255, active_font, string.format("%s", hitchance))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "MinDamage:")
	if ui_get(rage_mindmg) == 0 then
		minimumdamage = "Auto"
	elseif ui_get(rage_mindmg) >= 100 then
		minimumdamage = "HP+"..ui_get(rage_mindmg)-100
	else
		minimumdamage = ui_get(rage_mindmg)
	end
	surface.draw_text(defh+77, defw+neww, 52, 152, 219, 255, active_font, string.format("%s", minimumdamage))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "AutoScope:")
	surface.draw_text(defh+75, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", ui_get(rage_autoscope)))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "AimStep:")
	surface.draw_text(defh+62, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", ui_get(rage_aimstep)))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "NoRecoil:")
	surface.draw_text(defh+63, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", ui_get(rage_norecoil)))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "BackTrack:")
	surface.draw_text(defh+70, defw+neww, 46, 204, 113, 255, active_font, string.format("%s", ui_get(rage_accboost)))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "AutoStop:")
	surface.draw_text(defh+67, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", ui_get(rage_autostop)))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "Resolver:")
	surface.draw_text(defh+63, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", ui_get(rage_resolver)))
end

local function draw_aa(neww)
	surface.draw_text(defh+220, defw-2, 236, 240, 241, 255, small_font, "ANTI-AIMBOT")
	surface.draw_text(defh+200, defw, 236, 240, 241, 255, logo_font, "C")

	surface.draw_text(defh+215, defw+neww, 236, 240, 241, 255, default_font, "Anti-Aimbot:")
	surface.draw_text(defh+280, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", ui_get(aa_enable)))

	neww = neww + 15
	surface.draw_text(defh+215, defw+neww, 236, 240, 241, 255, default_font, "Pitch:")
	surface.draw_text(defh+245, defw+neww, 46, 204, 113, 255, active_font, string.format("%s", ui_get(aa_pitch)))

	neww = neww + 15
	surface.draw_text(defh+215, defw+neww, 236, 240, 241, 255, default_font, "Yaw:")
	surface.draw_text(defh+240, defw+neww, 46, 204, 113, 255, active_font, string.format("%s", ui_get(aa_yaw)))

	neww = neww + 15
	surface.draw_text(defh+215, defw+neww, 236, 240, 241, 255, default_font, "Desync:")
	surface.draw_text(defh+257, defw+neww, 46, 204, 113, 255, active_font, string.format("%s", ui_get(aa_desync_yaw)))

	neww = neww + 15
	surface.draw_text(defh+215, defw+neww, 236, 240, 241, 255, default_font, "LBY-T:")
	surface.draw_text(defh+250, defw+neww, 46, 204, 113, 255, active_font, string.format("%s", ui_get(aa_lby)))

	neww = neww + 15
	surface.draw_text(defh+215, defw+neww, 236, 240, 241, 255, default_font, "Fakelag:")
	surface.draw_text(defh+260, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", ui_get(aa_fakelag)))

	neww = neww + 15
	surface.draw_text(defh+215, defw+neww, 236, 240, 241, 255, default_font, "Amount:")
	surface.draw_text(defh+260, defw+neww, 46, 204, 113, 255, active_font, string.format("%s", ui_get(aa_fakelag_amount)))

	neww = neww + 15
	surface.draw_text(defh+215, defw+neww, 236, 240, 241, 255, default_font, "Variance:")
	surface.draw_text(defh+265, defw+neww, 52, 152, 219, 255, active_font, string.format("%s", ui_get(aa_fakelag_variance)))

	neww = neww + 15
	surface.draw_text(defh+215, defw+neww, 236, 240, 241, 255, default_font, "Limit:")
	surface.draw_text(defh+245, defw+neww, 52, 152, 219, 255, active_font, string.format("%s", ui_get(aa_fakelag_limit).." [ "..globals_chokedcommands().." ] "))

	neww = neww + 15
	surface.draw_text(defh+215, defw+neww, 236, 240, 241, 255, default_font, "Inf-Duck:")
	surface.draw_text(defh+265, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", ui_get(aa_infduck)))

	neww = neww + 15
	surface.draw_text(defh+215, defw+neww, 236, 240, 241, 255, default_font, "Onshot-AA:")
	surface.draw_text(defh+275, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", ui_get(aa_onshot)))
end

local function draw_legit(neww)
	surface.draw_text(defh+20, defw-2, 236, 240, 241, 255, small_font, "LEGIT")
	surface.draw_text(defh, defw, 236, 240, 241, 255, logo_font, "J")

	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "Aimbot:")
	surface.draw_text(defh+55, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", string.format("%s", ui_get(l_aimbot))))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "Backtrack:")
	surface.draw_text(defh+67, defw+neww, 46, 204, 113, 255, active_font, string.format("%s", string.format("%s", ui_get(l_backtrack))))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "Reaction:")
	surface.draw_text(defh+67, defw+neww, 52, 152, 219, 255, active_font, string.format("%s", string.format("%s", ui_get(l_reaction))))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "Field of View:")
	surface.draw_text(defh+80, defw+neww, 52, 152, 219, 255, active_font, string.format("%s", ui_get(l_fov)/10))

	neww = neww + 15
	surface.draw_text(defh+15, defw+neww, 236, 240, 241, 255, default_font, "Triggerbot:")
	surface.draw_text(defh+73, defw+neww, 26, 188, 156, 255, active_font, string.format("%s", ui_get(l_triggerbot)))
end

local function accumulate_fps() -- idk who to credit for this tbh.
	local ft = globals_absoluteframetime()
	if ft > 0 then
		table_insert(frametimes, 1, ft)
	end

	local count = #frametimes
	if count == 0 then
		return 0
	end

	local i, accum = 0, 0
	while accum < 0.5 do
		i = i + 1
		accum = accum + frametimes[i]
		if i >= count then
			break
		end
	end
	accum = accum / i
	while i < count do
		i = i + 1
		table_remove(frametimes)
	end
	local fps = 1 / accum
	local rt = globals_realtime()
	if abs(fps - fps_prev) > 4 or rt - last_update_time > 2 then
		fps_prev = fps
		last_update_time = rt
	else
		fps = fps_prev
	end

	return floor(fps + 0.5)
end

local function draw_info(neww)
	local fps = accumulate_fps()
	local m_iKills = entity_get_prop(entity_get_player_resource(), "m_iKills", entity_get_local_player())
	local m_iDeaths = entity_get_prop(entity_get_player_resource(), "m_iDeaths", entity_get_local_player())
	local kd = math_floor(m_iKills/m_iDeaths, 2) -- I guess credits to Aviarita??? (stole it from his x88 lua cuz tired :c )
	if kd == math.huge or kd == -math.huge or kd~=kd then
		kd = m_iKills
	end

	if ui_get(aa_enable) then
		info_h = 300
	else
		info_h = 150
	end
	surface.draw_text(info_h+380, defw-2, 236, 240, 241, 255, small_font, "INFO")
	surface.draw_text(info_h+370, defw, 236, 240, 241, 255, info_font, "i")
	surface.draw_text(info_h+380, defw+neww, 236, 240, 241, 255, default_font, "FPS:")
	surface.draw_text(info_h+405, defw+neww, 26, 188, 156, 255, active_font, string.format("%i", fps))

	neww = neww+15
	surface.draw_text(info_h+380, defw+neww, 236, 240, 241, 255, default_font, "Ping:")
	surface.draw_text(info_h+407, defw+neww, 26, 188, 156, 255, active_font, string.format("%i", math_floor(math_min(1000, client_latency()*1000))))

	neww = neww+15
	surface.draw_text(info_h+380, defw+neww, 236, 240, 241, 255, default_font, "Kills:")
	surface.draw_text(info_h+405, defw+neww, 26, 188, 156, 255, active_font, string.format("%i", m_iKills))

	neww = neww+15
	surface.draw_text(info_h+380, defw+neww, 236, 240, 241, 255, default_font, "Deaths:")
	surface.draw_text(info_h+420, defw+neww, 26, 188, 156, 255, active_font, string.format("%i", m_iDeaths))

	neww = neww+15
	surface.draw_text(info_h+380, defw+neww, 236, 240, 241, 255, default_font, "K/D:")
	surface.draw_text(info_h+405, defw+neww, 26, 188, 156, 255, active_font, string.format("%d",kd))
end

local function draw(ctx)
	if not ui.get(toggle) then return end
	if ui_get(rage_active) then
		draw_rage(neww)
	else
		draw_legit(neww)
	end
	if ui_get(aa_enable) then
		draw_aa(neww)
	end
	draw_info(neww)
end

client_set_event_callback("paint", draw)
