#define NOT_IF_TOGGLES_ARE_OFF if (!toggles_enabled) { alert("Toggling toggles has been disabled."); return; }


// if it's in Toggles (Server) it should be in here, ya dig?
var/list/server_toggles_tab_verbs = list(
/client/proc/toggle_attack_messages,
/client/proc/toggle_ghost_respawns,
/client/proc/toggle_adminwho_alerts,
/client/proc/toggle_toggles,
/client/proc/toggle_jobban_announcements,
/client/proc/toggle_banlogin_announcements,
/client/proc/toggle_literal_disarm,
/client/proc/toggle_spooky_light_plane,\
/client/proc/toggle_random_job_selection,
/client/proc/toggle_tracy_profiling,
/datum/admins/proc/toggleooc,
/datum/admins/proc/togglelooc,
/datum/admins/proc/toggleoocdead,
/datum/admins/proc/toggletraitorscaling,
/datum/admins/proc/pcap,
/datum/admins/proc/toggle_pcap_kick_messages,
/datum/admins/proc/toggleenter,
/datum/admins/proc/toggleAI,
/datum/admins/proc/toggle_soundpref_override,
/datum/admins/proc/toggle_respawns,
/datum/admins/proc/adsound,
/datum/admins/proc/adspawn,
/datum/admins/proc/adrev,
/datum/admins/proc/toggledeadchat,
/datum/admins/proc/togglefarting,
/datum/admins/proc/toggle_blood_system,
/datum/admins/proc/toggle_bone_system,
/datum/admins/proc/togglesuicide,
/datum/admins/proc/togglethetoggles,
/datum/admins/proc/toggleautoending,
/datum/admins/proc/toggleaprilfools,
/datum/admins/proc/togglespeechpopups,
/datum/admins/proc/toggle_global_parallax,
/datum/admins/proc/togglemonkeyspeakhuman,
/datum/admins/proc/toggle_antagonists_seeing_each_other,
/datum/admins/proc/togglelatetraitors,
/datum/admins/proc/togglesoundwaiting,
/datum/admins/proc/adjump,
/datum/admins/proc/togglesimsmode,
/datum/admins/proc/toggle_pull_slowing,
/datum/admins/proc/togglepowerdebug,
/client/proc/admin_toggle_nightmode,
/client/proc/toggle_camera_network_reciprocity,
/datum/admins/proc/toggle_radio_audio,
/datum/admins/proc/toggle_remote_music_announcements,
)

/client/proc/toggle_server_toggles_tab()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Server Toggles Tab"
	set desc = "Toggle all the crap in the Toggles (Server) tab so it should go away/show up.  in theory."
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/list/final_verblist

	//The main bunch
	for (var/I = 1,  I <= admin_verbs.len && I <= rank_to_level(src.holder.rank)+2, I++)
		final_verblist += server_toggles_tab_verbs & admin_verbs[I] //So you only toggle verbs at your level

	//The special A+ observer verbs
	if (rank_to_level(src.holder.rank) >= LEVEL_IA)
		final_verblist |= special_admin_observing_verbs
		//And the special PA+ observer verbs why do we even use this? It's dumb imo
		if (rank_to_level(src.holder.rank) >= LEVEL_PA)
			final_verblist |= special_pa_observing_verbs

	if (final_verblist.len)
		if (!src.holder.servertoggles_toggle)
			for (var/V in final_verblist)
				src.verbs -= V
		else
			for (var/V in final_verblist)
				src.verbs += V
		src.holder.servertoggles_toggle = !src.holder.servertoggles_toggle

		boutput(usr, SPAN_NOTICE("Toggled Server Toggle tab [src.holder.servertoggles_toggle?"off":"on"]!"))

	return

/client/proc/toggle_extra_verbs()//Going to put some things in here that we dont need to see every single second when trying to play though atm only the add_r is in it
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Extra Verbs"
	ADMIN_ONLY
	SHOW_VERB_DESC
	if (!src.holder.extratoggle)
		src.verbs -= /client/proc/addreagents

		//src.verbs -= /proc/possess
		src.verbs -= /client/proc/addreagents
		src.verbs -= /client/proc/cmd_admin_rejuvenate

		src.verbs -= /client/proc/main_loop_context
		src.verbs -= /client/proc/main_loop_tick_detail
		src.verbs -= /client/proc/ticklag

		src.holder.extratoggle = 1
		boutput(src, "Extra Toggled Off")
	else
		src.verbs += /client/proc/addreagents
		src.holder.extratoggle = 0
		boutput(src, "Extra Toggled On")
		src.verbs += /client/proc/addreagents


		//src.verbs += /proc/possess
		src.verbs += /client/proc/addreagents
		src.verbs += /client/proc/cmd_admin_rejuvenate

		src.verbs += /client/proc/main_loop_context
		src.verbs += /client/proc/main_loop_tick_detail
		src.verbs += /client/proc/ticklag

var/global/IP_alerts = 1

/client/proc/toggle_ip_alerts()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle IP Alerts"
	set desc = "Toggles the same-IP alerts"
	ADMIN_ONLY
	SHOW_VERB_DESC

	IP_alerts = !IP_alerts
	logTheThing(LOG_ADMIN, usr, "has toggled same-IP alerts [(IP_alerts ? "On" : "Off")]")
	logTheThing(LOG_DIARY, usr, "has toggled same-IP alerts [(IP_alerts ? "On" : "Off")]", "admin")
	message_admins("[key_name(usr)] has toggled same-IP alerts [(IP_alerts ? "On" : "Off")]")

/client/proc/toggle_attack_messages()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Attack Alerts"
	set desc = "Toggles the after-join attack messages"
	ADMIN_ONLY
	SHOW_VERB_DESC

	src.holder.attacktoggle = !src.holder.attacktoggle
	boutput(usr, SPAN_NOTICE("Toggled attack log messages [src.holder.attacktoggle ?"on":"off"]!"))

client/proc/toggle_ghost_respawns()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Ghost Respawn offers"
	set desc = "Toggles receiving offers to respawn as a ghost"
	ADMIN_ONLY
	SHOW_VERB_DESC

	src.holder.ghost_respawns = !src.holder.ghost_respawns
	boutput(usr, SPAN_NOTICE("Toggled ghost respawn offers [src.holder.ghost_respawns ?"on":"off"]!"))

/client/proc/toggle_adminwho_alerts()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Who/Adminwho alerts"
	set desc = "Toggles the alerts for players using Who/Adminwho"
	ADMIN_ONLY
	SHOW_VERB_DESC

	src.holder.adminwho_alerts = !src.holder.adminwho_alerts
	boutput(usr, SPAN_NOTICE("Toggled who/adminwho alerts [src.holder.adminwho_alerts ?"on":"off"]!"))

/client/proc/toggle_rp_word_filtering()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle \"Low RP\" Word Alerts"
	set desc = "Toggles notifications for players saying \"fail-rp\" words (sussy, poggers, etc)"
	ADMIN_ONLY
	SHOW_VERB_DESC
	src.holder.rp_word_filtering = !src.holder.rp_word_filtering
	if(src.holder.rp_word_filtering)
		src.holder.RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_SUSSY_PHRASE, TYPE_PROC_REF(/datum/admins, admin_message_to_me))
	else
		src.holder.UnregisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_SUSSY_PHRASE)
	boutput(usr, SPAN_NOTICE("Toggled RP word filter notifications [src.holder.rp_word_filtering ?"on":"off"]!"))

/client/proc/toggle_uncool_word_filtering()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Uncool Word Alerts"
	set desc = "Toggles notifications for players saying uncool words"
	ADMIN_ONLY
	SHOW_VERB_DESC
	src.holder.uncool_word_filtering = !src.holder.uncool_word_filtering
	if(src.holder.uncool_word_filtering)
		src.holder.RegisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_UNCOOL_PHRASE, TYPE_PROC_REF(/datum/admins, admin_message_to_me))
	else
		src.holder.UnregisterSignal(GLOBAL_SIGNAL, COMSIG_GLOBAL_UNCOOL_PHRASE)
	boutput(usr, SPAN_NOTICE("Toggled uncool word filter notifications [src.holder.uncool_word_filtering ?"on":"off"]!"))

/client/proc/toggle_hear_prayers()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Hearing Prayers"
	set desc = "Toggles if you can hear prayers or not"
	ADMIN_ONLY
	SHOW_VERB_DESC

	src.holder.hear_prayers = !src.holder.hear_prayers
	boutput(usr, SPAN_NOTICE("Toggled prayers [src.holder.hear_prayers ?"on":"off"]!"))

/client/proc/toggle_atags()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle ATags"
	set desc = "Toggle local atags on or off"
	ADMIN_ONLY
	SHOW_VERB_DESC

	_toggle_atags()

/client/proc/_toggle_atags()
	src.holder.see_atags = !src.holder.see_atags
	boutput(usr, SPAN_NOTICE("Toggled ATags [src.holder.see_atags ?"on":"off"]!"))

/client/proc/toggle_buildmode_view()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Buildmode View"
	set desc = "Toggles if buildmode changes your view"
	ADMIN_ONLY
	SHOW_VERB_DESC

	src.holder.buildmode_view = !src.holder.buildmode_view
	boutput(usr, SPAN_NOTICE("Toggled buildmode changing view [src.holder.buildmode_view ?"off":"on"]!"))

/client/proc/toggle_hide_offline()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Offline Indicators"
	set desc = "Toggles if your offline indicators are hidden when mob jumping"
	ADMIN_ONLY
	SHOW_VERB_DESC

	src.holder.hide_offline_indicators = !src.holder.hide_offline_indicators
	boutput(usr, SPAN_NOTICE("Toggled hiding offline indicators [src.holder.hide_offline_indicators ? "on":"off"]!"))

/client/proc/toggle_spawn_in_loc()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Spawn in Loc"
	set desc = "Toggles if buildmode changes your view"
	ADMIN_ONLY
	SHOW_VERB_DESC

	src.holder.spawn_in_loc = !src.holder.spawn_in_loc
	boutput(usr, SPAN_NOTICE("Toggled spawn verb spawning in your loc [src.holder.spawn_in_loc ?"off":"on"]!"))

/client/proc/cmd_admin_playermode()
	set name = "Toggle Player mode"
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set desc = "Disables most admin messages."

	ADMIN_ONLY
	SHOW_VERB_DESC

	if (player_mode)
		player_mode = 0
		player_mode_asay = 0
		player_mode_ahelp = 0
		player_mode_mhelp = 0

		src.holder.admin_speech_tree.update_target_speech_tree(src.speech_tree)
		src.holder.admin_listen_tree.update_target_listen_tree(src.listen_tree)

		boutput(usr, SPAN_NOTICE("Player mode now OFF."))

	else
		var/choice = input(src, "ASAY = adminsay, AHELP = adminhelp, MHELP = mentorhelp", "Choose which messages to receive") as null|anything in list("NONE (Remove admin menus)","NONE (Keep admin menus)", "ASAY, AHELP & MHELP", "ASAY & AHELP", "ASAY & MHELP", "AHELP & MHELP", "ASAY ONLY", "AHELP ONLY", "MHELP ONLY")
		var/remove_holder = FALSE
		switch (choice)
			if ("ASAY, AHELP & MHELP")
				player_mode = 1
				player_mode_asay = 1
				player_mode_ahelp = 1
				player_mode_mhelp = 1
			if ("ASAY & AHELP")
				player_mode = 1
				player_mode_asay = 1
				player_mode_ahelp = 1
				player_mode_mhelp = 0
			if ("ASAY & MHELP")
				player_mode = 1
				player_mode_asay = 1
				player_mode_ahelp = 0
				player_mode_mhelp = 1
			if ("AHELP & MHELP")
				player_mode = 1
				player_mode_asay = 0
				player_mode_ahelp = 1
				player_mode_mhelp = 1
			if ("ASAY ONLY")
				player_mode = 1
				player_mode_asay = 1
				player_mode_ahelp = 0
				player_mode_mhelp = 0
			if ("AHELP ONLY")
				player_mode = 1
				player_mode_asay = 0
				player_mode_ahelp = 1
				player_mode_mhelp = 0
			if ("MHELP ONLY")
				player_mode = 1
				player_mode_asay = 0
				player_mode_ahelp = 0
				player_mode_mhelp = 1
			if ("NONE (Keep admin menus)")
				player_mode = 1
				player_mode_asay = 0
				player_mode_ahelp = 0
				player_mode_mhelp = 0
			if ("NONE (Remove admin menus)")
				player_mode = 1
				player_mode_asay = 0
				player_mode_ahelp = 0
				player_mode_mhelp = 0
				remove_holder = TRUE
			else
				// Cancel = don't turn on player mode
				return

		src.holder.admin_speech_tree.update_target_speech_tree()
		src.holder.admin_listen_tree.update_target_listen_tree()

		if (remove_holder)
			src.cmd_admin_disable()

		boutput(usr, SPAN_NOTICE("Player mode now on. [player_mode_asay ? "&mdash; ASAY ON" : ""] [player_mode_ahelp ? "&mdash; AHELPs ON" : ""] [player_mode_mhelp ? "&mdash; MHELPs ON" : ""]"))

	logTheThing(LOG_ADMIN, usr, "has set player mode to [(player_mode ? "On" : "Off")]")
	logTheThing(LOG_DIARY, usr, "has set player mode to [(player_mode ? "On" : "Off")]", "admin")
	message_admins("[key_name(usr)] has set player mode to [(player_mode ? "On" : "Off")]")

/client/proc/cmd_admin_godmode(mob/M as mob in world)
	SET_ADMIN_CAT(ADMIN_CAT_FUN)
	set name = "Toggle Mob Godmode"
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!isliving(M))
		return
	M.nodamage = !(M.nodamage)
	boutput(usr, SPAN_NOTICE("<b>[M]'s godmode is now [usr.nodamage ? "ON" : "OFF"]</b>"))

	logTheThing(LOG_ADMIN, usr, "has toggled [constructTarget(M,"admin")]'s nodamage to [(M.nodamage ? "On" : "Off")]")
	logTheThing(LOG_DIARY, usr, "has toggled [constructTarget(M,"diary")]'s nodamage to [(M.nodamage ? "On" : "Off")]", "admin")
	message_admins("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.nodamage ? "On" : "Off")]")

/client/proc/cmd_admin_godmode_self()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Your Godmode"
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (!isliving(usr))
		return
	usr.nodamage = !(usr.nodamage)
	var/list/datum/statusEffect/statuses = usr.getStatusList()
	for (var/status in statuses)
		if (statuses[status].effect_quality == STATUS_QUALITY_NEGATIVE)
			usr.delStatus(status)
	boutput(usr, SPAN_NOTICE("<b>Your godmode is now [usr.nodamage ? "ON" : "OFF"]</b>"))

	logTheThing(LOG_ADMIN, usr, "has toggled their nodamage to [(usr.nodamage ? "On" : "Off")]")
	logTheThing(LOG_DIARY, usr, "has toggled their nodamage to [(usr.nodamage ? "On" : "Off")]", "admin")
	message_admins("[key_name(usr)] has toggled their nodamage to [(usr.nodamage ? "On" : "Off")]")

/client/proc/cmd_admin_toggle_ghost_interaction()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Ghost Interaction"
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC

	src.holder.ghost_interaction = !src.holder.ghost_interaction
	boutput(usr, SPAN_NOTICE("<b>Your ghost interaction mode is now [src.holder.ghost_interaction ? "ON" : "OFF"]</b>"))
	if(isobserver(mob))
		setalive(mob)

	logTheThing(LOG_ADMIN, usr, "has toggled their ghost interaction to [(src.holder.ghost_interaction ? "On" : "Off")]")
	logTheThing(LOG_DIARY, usr, "has toggled their ghost interaction to [(src.holder.ghost_interaction ? "On" : "Off")]", "admin")
	message_admins("[key_name(usr)] has toggled their ghost interaction to [(src.holder.ghost_interaction ? "On" : "Off")]")

/client/proc/iddqd()
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "iddqd"
	set popup_menu = 0
	ADMIN_ONLY
	usr.client.cmd_admin_godmode_self()
	boutput(usr, SPAN_NOTICE("<b>Degreelessness mode [usr.nodamage ? "On" : "Off"]</b>"))

/client/var/flying = 0
/client/proc/noclip()
	set name = "Toggle Your Noclip"
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set desc = "Fly through walls"
	ADMIN_ONLY
	SHOW_VERB_DESC
	usr.client.flying = !usr.client.flying
	boutput(usr, "Noclip mode [usr.client.flying ? "ON" : "OFF"].")

/client/proc/idclip()
	SET_ADMIN_CAT(ADMIN_CAT_NONE)
	set name = "idclip"
	set popup_menu = 0
	ADMIN_ONLY
	usr.client.noclip()


/client/proc/cmd_admin_omnipresence()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Your Mob's Omnipresence"
	set popup_menu = 0
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/omnipresent
	if(!length(by_cat[TR_CAT_OMNIPRESENT_MOBS]) || !(src.mob in by_cat[TR_CAT_OMNIPRESENT_MOBS]))
		if(alert(usr, "Are you sure you want to see all messages from the whole world? This is very experimental, possibly laggy, clientcrashing and of dubious usefulness.", "Really???", "Yes", "No") != "Yes")
			return
		OTHER_START_TRACKING_CAT(src.mob, TR_CAT_OMNIPRESENT_MOBS)
		omnipresent = TRUE
	else
		OTHER_STOP_TRACKING_CAT(src.mob, TR_CAT_OMNIPRESENT_MOBS)
		omnipresent = FALSE
	boutput(usr, SPAN_NOTICE("<b>Your omnipresence is now [omnipresent ? "ON" : "OFF"]</b>"))

	logTheThing(LOG_ADMIN, usr, "has toggled their omnipresence to [(omnipresent ? "On" : "Off")]")
	logTheThing(LOG_DIARY, usr, "has toggled their omnipresence to [(omnipresent ? "On" : "Off")]", "admin")
	message_admins("[key_name(usr)] has toggled their omnipresence to [(omnipresent ? "On" : "Off")]")

/client/proc/toggle_atom_verbs() // I hate calling them "atom verbs" but wtf else should they be called, fuck
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle Atom Verbs"
	ADMIN_ONLY
	SHOW_VERB_DESC
	if(!src.holder.disable_atom_verbs)
		src.holder.disable_atom_verbs = 1
		boutput(src, "Atom interaction options toggled off.")
	else
		src.holder.disable_atom_verbs = 0
		boutput(src, "Atom interaction options toggled on.")

/client/proc/toggle_view_range()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set name = "Toggle View Range"
	set desc = "switches between 1x and custom views"
	ADMIN_ONLY
	SHOW_VERB_DESC
	if(src.view == world.view || src.view == "21x15")
		var/x = input("Enter view width in tiles: (1 - 59, default 15 (normal) / 21 (widescreen))", "Width", 21)
		var/y = input("Enter view height in tiles: (1 - 30, default 15)", "Height", 15)

		src.set_view_size(x,y)
	else
		// Reset view - takes into account widescreen
		src.reset_view()
		//src.view = world.view

/client/proc/toggle_toggles()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Toggles"
	set desc = "Toggles toggles ON/OFF"
	ADMIN_ONLY
	SHOW_VERB_DESC
	if(!(src.holder.rank in list("Host", "Coder")))
		NOT_IF_TOGGLES_ARE_OFF

	toggles_enabled = !toggles_enabled
	logTheThing(LOG_ADMIN, usr, "toggled Toggles to [toggles_enabled].")
	logTheThing(LOG_DIARY, usr, "toggled Toggles to [toggles_enabled].", "admin")
	message_admins("[key_name(usr)] toggled Toggles [toggles_enabled ? "on" : "off"].")

/client/proc/toggle_force_mixed_wraith()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Toggle Force Wraith"
	set desc = "If turned on, a wraith will always appear in mixed or traitor, regardless of player count or probabilities."
	ADMIN_ONLY
	SHOW_VERB_DESC
	debug_mixed_forced_wraith = !debug_mixed_forced_wraith
	logTheThing(LOG_ADMIN, usr, "toggled force mixed wraith [debug_mixed_forced_wraith ? "on" : "off"]")
	logTheThing(LOG_DIARY, usr, "toggled force mixed wraith [debug_mixed_forced_wraith ? "on" : "off"]")
	message_admins("[key_name(usr)] toggled force mixed wraith [debug_mixed_forced_wraith ? "on" : "off"]")

/client/proc/toggle_force_mixed_blob()
	SET_ADMIN_CAT(ADMIN_CAT_DEBUG)
	set name = "Toggle Force Blob"
	set desc = "If turned on, a blob will always appear in mixed, regardless of player count or probabilities."
	ADMIN_ONLY
	SHOW_VERB_DESC
	debug_mixed_forced_blob = !debug_mixed_forced_blob
	logTheThing(LOG_ADMIN, usr, "toggled force mixed blob [debug_mixed_forced_blob ? "on" : "off"]")
	logTheThing(LOG_DIARY, usr, "toggled force mixed blob [debug_mixed_forced_blob ? "on" : "off"]")
	message_admins("[key_name(usr)] toggled force mixed blob [debug_mixed_forced_blob ? "on" : "off"]")

/client/proc/toggle_jobban_announcements()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Jobban Alerts"
	set desc = "Toggles the announcement of job bans ON/OFF"
	ADMIN_ONLY
	SHOW_VERB_DESC
	if (!(src.holder.rank in list("Host", "Coder", "Administrator")))
		NOT_IF_TOGGLES_ARE_OFF

	if (announce_jobbans == 1) announce_jobbans = 0
	else announce_jobbans = 1
	logTheThing(LOG_ADMIN, usr, "toggled Jobban Alerts to [announce_jobbans].")
	logTheThing(LOG_DIARY, usr, "toggled Jobban Alerts to [announce_jobbans].", "admin")
	message_admins("[key_name(usr)] toggled Jobban Alerts [announce_jobbans ? "on" : "off"].")

/client/proc/toggle_banlogin_announcements()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Banlog Alerts"
	set desc = "Toggles the announcement of failed logins ON/OFF"
	ADMIN_ONLY
	SHOW_VERB_DESC
	if (announce_banlogin == 1) announce_banlogin = 0
	else announce_banlogin = 1
	logTheThing(LOG_ADMIN, usr, "toggled Banned User Alerts to [announce_banlogin].")
	logTheThing(LOG_DIARY, usr, "toggled Banned User Alerts to [announce_banlogin].", "admin")
	message_admins("[key_name(usr)] toggled Banned User Alerts to [announce_banlogin ? "on" : "off"].")

/client/proc/toggle_literal_disarm()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Literal Disarm"
	set desc = "Toggles literal disarm intent ON/OFF"
	ADMIN_ONLY
	SHOW_VERB_DESC
	if(!(src.holder.rank in list("Host", "Coder")))
		NOT_IF_TOGGLES_ARE_OFF
	literal_disarm = !literal_disarm
	logTheThing(LOG_ADMIN, usr, "toggled literal disarming to [literal_disarm].")
	logTheThing(LOG_DIARY, usr, "toggled literal disarming to [literal_disarm].", "admin")
	message_admins("[key_name(usr)] toggled literal disarming [literal_disarm ? "on" : "off"].")

/datum/admins/proc/toggleooc()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle dis"
	set name="Toggle OOC"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF

	var/ooc_allowed = !global.SpeechManager.GetSayChannelInstance(SAY_CHANNEL_OOC).enabled
	global.toggle_ooc_allowed(ooc_allowed)

	boutput(world, "<B>The OOC channel has been globally [ooc_allowed ? "en" : "dis"]abled!</B>")
	logTheThing(LOG_ADMIN, usr, "toggled OOC.")
	logTheThing(LOG_DIARY, usr, "toggled OOC.", "admin")
	message_admins("[key_name(usr)] toggled OOC.")

/proc/toggle_ooc_allowed(ooc_allowed)
	global.SpeechManager.GetSayChannelInstance(SAY_CHANNEL_OOC).enabled = ooc_allowed

/datum/admins/proc/togglelooc()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle dis"
	set name="Toggle LOOC"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF

	var/looc_allowed = !global.SpeechManager.GetSayChannelInstance(SAY_CHANNEL_LOOC).enabled
	global.toggle_looc_allowed(looc_allowed)

	boutput(world, "<B>The LOOC channel has been globally [looc_allowed ? "en" : "dis"]abled!</B>")
	logTheThing(LOG_ADMIN, usr, "toggled LOOC.")
	logTheThing(LOG_DIARY, usr, "toggled LOOC.", "admin")
	message_admins("[key_name(usr)] toggled LOOC.")

/proc/toggle_looc_allowed(looc_allowed)
	global.SpeechManager.GetSayChannelInstance(SAY_CHANNEL_LOOC).enabled = looc_allowed

/datum/admins/proc/toggleoocdead()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle dis."
	set name="Toggle Dead OOC"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	dooc_allowed = !( dooc_allowed )
	logTheThing(LOG_ADMIN, usr, "toggled OOC.")
	logTheThing(LOG_DIARY, usr, "toggled OOC.", "admin")
	message_admins("[key_name(usr)] toggled Dead OOC.")

/datum/admins/proc/toggletraitorscaling()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle traitor scaling"
	set name="Toggle Traitor Scaling"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	traitor_scaling = !traitor_scaling
	logTheThing(LOG_ADMIN, usr, "toggled Traitor Scaling to [traitor_scaling].")
	logTheThing(LOG_DIARY, usr, "toggled Traitor Scaling to [traitor_scaling].", "admin")
	message_admins("[key_name(usr)] toggled Traitor Scaling [traitor_scaling ? "on" : "off"].")

/datum/admins/proc/pcap()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle player cap"
	set name = "Toggle Player Cap"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	player_capa = !( player_capa )
	if (player_capa)
		boutput(world, "<B>The global player cap has been enabled at [player_cap] players.</B>")
	else
		boutput(world, "<B>The global player cap has been disabled.</B>")
	logTheThing(LOG_ADMIN, usr, "toggled player cap of [player_cap] [player_capa ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled player cap of [player_cap] [player_capa ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled player cap [player_capa ? "on" : "off"].")

/datum/admins/proc/toggle_pcap_kick_messages()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle pcap kick and redicrection acceptance messages on or off"
	set name = "Toggle PCap Kick Alerts"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	global.pcap_kick_messages = !(global.pcap_kick_messages)
	logTheThing(LOG_ADMIN, usr, "toggled player cap kick and redirection acceptance messages [global.pcap_kick_messages ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled player cap kick and redirection acceptance messages [global.pcap_kick_messages ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled player cap kick and redirection acceptance messages [global.pcap_kick_messages ? "on" : "off"].")

/datum/admins/proc/toggleenter()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="People can't enter"
	set name="Toggle Entering"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	enter_allowed = !( enter_allowed )
	if (!( enter_allowed ))
		boutput(world, "<B>You may no longer enter the game.</B>")
	else
		boutput(world, "<B>You may now enter the game.</B>")
	logTheThing(LOG_ADMIN, usr, "toggled new player game entering.")
	logTheThing(LOG_DIARY, usr, "toggled new player game entering.", "admin")
	message_admins(SPAN_INTERNAL("[key_name(usr)] toggled new player game entering."))
	world.update_status()

/datum/admins/proc/toggleAI()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="People can't be AI"
	set name="Toggle AI"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	config.allow_ai = !( config.allow_ai )
	if (!( config.allow_ai ))
		boutput(world, "<B>The AI job is no longer chooseable.</B>")
	else
		boutput(world, "<B>The AI job is chooseable now.</B>")
	logTheThing(LOG_ADMIN, usr, "toggled AI allowed.")
	logTheThing(LOG_DIARY, usr, "toggled AI allowed.", "admin")
	world.update_status()

/datum/admins/proc/toggle_soundpref_override()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Force people to hear admin-played sounds even if they have them disabled."
	set name = "Toggle SoundPref Override"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	soundpref_override = !( soundpref_override )
	logTheThing(LOG_ADMIN, usr, "toggled Sound Preference Override [soundpref_override ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled Sound Preference Override [soundpref_override ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled Sound Preference Override [soundpref_override ? "on" : "off"]")

/datum/admins/proc/toggle_respawns()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Enable or disable the ability for all players to respawn"
	set name="Toggle Respawn"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	abandon_allowed = !( abandon_allowed )
	if (abandon_allowed)
		boutput(world, "<B>You may now respawn.</B>")
	else
		boutput(world, "<B>You may no longer respawn :(</B>")
	message_admins(SPAN_INTERNAL("[key_name(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"]."))
	logTheThing(LOG_ADMIN, usr, "toggled respawn to [abandon_allowed ? "On" : "Off"].")
	logTheThing(LOG_DIARY, usr, "toggled respawn to [abandon_allowed ? "On" : "Off"].", "admin")
	world.update_status()

/client/proc/toggle_flourish()
	SET_ADMIN_CAT(ADMIN_CAT_SELF)
	set desc="Toggles Your Flourish Mode"
	set name="Toggle Flourish Mode"
	ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	if(flourish)
		flourish = 0
		boutput(usr, SPAN_NOTICE("Flourish Mode disabled."))
	else
		flourish = 1
		boutput(usr, SPAN_NOTICE("Flourish Mode enabled."))

/datum/admins/proc/adsound()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle admin sound playing"
	set name="Toggle Sound Playing"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	config.allow_admin_sounds = !(config.allow_admin_sounds)
	message_admins(SPAN_INTERNAL("Toggled admin sound playing to [config.allow_admin_sounds]."))

/datum/admins/proc/adspawn()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle admin spawning"
	set name="Toggle Spawn"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	config.allow_admin_spawning = !(config.allow_admin_spawning)
	message_admins(SPAN_INTERNAL("Toggled admin item spawning to [config.allow_admin_spawning]."))

/datum/admins/proc/adrev()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle admin revives"
	set name="Toggle Revive"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	config.allow_admin_rev = !(config.allow_admin_rev)
	message_admins(SPAN_INTERNAL("Toggled reviving to [config.allow_admin_rev]."))

/datum/admins/proc/toggledeadchat()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle Deadchat on or off."
	set name = "Toggle Deadchat"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF

	var/deadchat_allowed = !global.SpeechManager.GetSayChannelInstance(SAY_CHANNEL_DEAD).enabled
	global.toggle_deadchat_allowed(deadchat_allowed)

	if (deadchat_allowed)
		boutput(world, "<B>The Deadsay channel has been enabled.</B>")
	else
		boutput(world, "<B>The Deadsay channel has been disabled.</B>")
	logTheThing(LOG_ADMIN, usr, "toggled Deadchat [deadchat_allowed ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled Deadchat [deadchat_allowed ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled Deadchat [deadchat_allowed ? "on" : "off"]")

/proc/toggle_deadchat_allowed(deadchat_allowed)
	global.SpeechManager.GetSayChannelInstance(SAY_CHANNEL_DEAD).enabled = deadchat_allowed

/datum/admins/proc/togglefarting()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle Farting on or off."
	set name = "Toggle Farting"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	farting_allowed = !( farting_allowed )
	if (farting_allowed)
		boutput(world, "<B>Farting has been enabled.</B>")
	else
		boutput(world, "<B>Farting has been disabled.</B>")
	logTheThing(LOG_ADMIN, usr, "toggled Farting [farting_allowed ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled Farting [farting_allowed ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled Farting [farting_allowed ? "on" : "off"]")

/datum/admins/proc/toggle_emote_cooldowns()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Let everyone spam emotes, including farts/filps/suplexes. Oh no."
	set name="Toggle Emote Cooldowns"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	no_emote_cooldowns = !( no_emote_cooldowns )
	logTheThing(LOG_ADMIN, usr, "toggled emote cooldowns [!no_emote_cooldowns ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled emote cooldowns [!no_emote_cooldowns ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled emote cooldowns [!no_emote_cooldowns ? "on" : "off"].")

/datum/admins/proc/toggle_blood_system()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle the blood system on or off."
	set name = "Toggle Blood System"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	blood_system = !(blood_system)
	boutput(world, "<B>Blood system has been [blood_system ? "enabled" : "disabled"].</B>")
	logTheThing(LOG_ADMIN, usr, "toggled the blood system [blood_system ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled the blood system [blood_system ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled the blood system [blood_system ? "on" : "off"]")

/datum/admins/proc/toggle_bone_system()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle the bone system on or off."
	set name = "Toggle Bone System"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	bone_system = !(bone_system)
	boutput(world, "<B>Bone system has been [bone_system ? "enabled" : "disabled"].</B>")
	logTheThing(LOG_ADMIN, usr, "toggled the bone system [bone_system ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled the bone system [bone_system ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled the bone system [bone_system ? "on" : "off"]")

/datum/admins/proc/togglesuicide()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Allow/Disallow people to commit suicide."
	set name = "Toggle Suicide"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	suicide_allowed = !( suicide_allowed )
	logTheThing(LOG_ADMIN, usr, "toggled Suicides [suicide_allowed ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled Suicides [suicide_allowed ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled Suicides [suicide_allowed ? "on" : "off"]")

/datum/admins/proc/togglethetoggles()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle All Toggles"
	set name = "Toggle All Toggles"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	dooc_allowed = !( dooc_allowed )
	player_capa = !( player_capa )
	enter_allowed = !( enter_allowed )
	config.allow_ai = !( config.allow_ai )
	soundpref_override = !( soundpref_override )
	abandon_allowed = !( abandon_allowed )
	config.allow_admin_jump = !(config.allow_admin_jump)
	config.allow_admin_sounds = !(config.allow_admin_sounds)
	config.allow_admin_spawning = !(config.allow_admin_spawning)
	config.allow_admin_rev = !(config.allow_admin_rev)
	farting_allowed = !( farting_allowed )
	no_emote_cooldowns = !( no_emote_cooldowns )
	suicide_allowed = !( suicide_allowed )
	monkeysspeakhuman = !( monkeysspeakhuman )
	no_automatic_ending = !( no_automatic_ending )
	late_traitors = !( late_traitors )
	sound_waiting = !( sound_waiting )
	message_admins("[key_name(usr)] toggled Dead OOC  [dooc_allowed ? "on" : "off"], Global Player Cap  [player_capa ? "on" : "off"], Entering [enter_allowed ? "on" : "off"],Playing as the AI [config.allow_ai ? "on" : "off"], Sound Preference override [soundpref_override ? "on" : "off"], Abandoning [abandon_allowed ? "on" : "off"], Admin Jumping [config.allow_admin_jump ? "on" : "off"], Admin sound playing [config.allow_admin_sounds ? "on" : "off"], Admin Spawning [config.allow_admin_spawning ? "on" : "off"], Admin Reviving [config.allow_admin_rev ? "on" : "off"], Farting [farting_allowed ? "on" : "off"], Blood system [blood_system ? "on" : "off"], Suicide [suicide_allowed ? "on" : "off"], Monkey/Human communication [monkeysspeakhuman ? "on" : "off"], Late Traitors [late_traitors ? "on" : "off"], and Sound Queuing [sound_waiting ? "on" : "off"]   ")

/datum/admins/proc/toggleaprilfools()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle manual breathing and/or blinking."
	set name = "Toggle Manual Breathing/Blinking"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF

	var/priorbreathing = manualbreathing
	var/breathing = alert("Manual breathing mode?","Toggle","On","Off")
	if(breathing == "On")
		manualbreathing = 1
		if(priorbreathing != manualbreathing) boutput(world, "<B>You must now breathe manually using the *inhale and *exhale emotes!</B>")
	else
		manualbreathing = 0
		if(priorbreathing != manualbreathing) boutput(world, "<B>You no longer need to breathe manually!</B>")

	var/priorblinking = manualblinking
	var/blinking = alert("Manual blinking mode?","Toggle","On","Off")
	if(blinking == "On")
		manualblinking = 1
		if(priorblinking != manualblinking) boutput(world, "<B>You must now blink manually using the *closeeyes and *openeyes emotes!</B>")
	else
		manualblinking = 0
		if(priorblinking != manualblinking) boutput(world, "<B>You no longer need to blink manually!</B>")

	logTheThing(LOG_ADMIN, usr, "turned manual breathing [manualbreathing ? "on" : "off"] and manual blinking [manualblinking ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "turned manual breathing [manualbreathing ? "on" : "off"] and manual blinking [manualblinking ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] turned manual breathing [manualbreathing ? "on" : "off"] and manual blinking [manualblinking ? "on" : "off"].")

/datum/admins/proc/togglespeechpopups()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Makes mob chat show up in-game as floating text."
	set name = "Toggle Global Flying Chat"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	speechpopups = !( speechpopups )
	logTheThing(LOG_ADMIN, usr, "toggled speech popups [speechpopups ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled speech popups [speechpopups ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled speech popups [speechpopups ? "on" : "off"]")

/datum/admins/proc/toggle_global_parallax()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Global Parallax"
	set desc = "Toggles parallax on or off globally. Toggling on respects client preferences in regard to parallax."
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	parallax_enabled = !parallax_enabled

	for (var/client/client in clients)
		client.toggle_parallax()

	logTheThing(LOG_ADMIN, src, "toggled parallax [parallax_enabled ? "on" : "off"] globally.")
	logTheThing(LOG_DIARY, src, "toggled parallax [parallax_enabled ? "on" : "off"] globally.", "admin")
	message_admins("[key_name(src)] toggled parallax [parallax_enabled ? "on" : "off"] globally.")

/datum/admins/proc/togglemonkeyspeakhuman()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle monkeys being able to speak human."
	set name = "Toggle Monkeys Speaking Human"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	monkeysspeakhuman = !( monkeysspeakhuman )
	if (monkeysspeakhuman)
		boutput(world, "<B>Monkeys can now speak to humans.</B>")
	else
		boutput(world, "<B>Monkeys can no longer speak to humans.</B>")
	logTheThing(LOG_ADMIN, usr, "toggled Monkey/Human communication [monkeysspeakhuman ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled Monkey/Human communication [monkeysspeakhuman ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled Monkey/Human communication [monkeysspeakhuman ? "on" : "off"]")

/datum/admins/proc/toggle_antagonists_seeing_each_other()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle all antagonists being able to see each other."
	set name = "Toggle Antagonists Seeing Each Other"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	antagonists_see_each_other = !antagonists_see_each_other

	var/datum/client_image_group/antagonist_image_group = get_image_group(CLIENT_IMAGE_GROUP_ALL_ANTAGONISTS)
	for (var/datum/antagonist/antagonist_role as anything in get_all_antagonists())
		if (antagonists_see_each_other)
			antagonist_image_group.add_mind(antagonist_role.owner)
		else
			antagonist_image_group.remove_mind(antagonist_role.owner)

	if (antagonists_see_each_other)
		boutput(world, "<B>Antagonists can now see each other.</B>")
	else
		boutput(world, "<B>Antagonists can no longer see each other.</B>")

	logTheThing(LOG_ADMIN, usr, "toggled antagonists seeing each other [antagonists_see_each_other ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled antagonists seeing each other [antagonists_see_each_other ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled antagonists seeing each other [antagonists_see_each_other ? "on" : "off"]")

/datum/admins/proc/toggleautoending()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle the round automatically ending in invasive round types."
	set name = "Toggle Automatic Round End"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	no_automatic_ending = !( no_automatic_ending )
	logTheThing(LOG_ADMIN, usr, "toggled Automatic Round End [no_automatic_ending ? "off" : "on"].")
	logTheThing(LOG_DIARY, usr, "toggled Automatic Round End [no_automatic_ending ? "off" : "on"].", "admin")
	message_admins("[key_name(usr)] toggled Automatic Round End [no_automatic_ending ? "off" : "on"]")

/datum/admins/proc/togglelatetraitors()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle late joiners spawning as antagonists if all starting antagonists are dead."
	set name = "Toggle Late Antagonists"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	late_traitors = !( late_traitors )
	logTheThing(LOG_ADMIN, usr, "toggled late antagonists [late_traitors ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled late antagonists [late_traitors ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled late antagonists [late_traitors ? "on" : "off"]")

/datum/admins/proc/togglesoundwaiting()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle admin-played sounds waiting for previous sounds to finish before playing."
	set name = "Toggle Admin Sound Queue"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	sound_waiting = !( sound_waiting )
	logTheThing(LOG_ADMIN, usr, "toggled admin sound queue [sound_waiting ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled admin sound queue [sound_waiting ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled admin sound queue [sound_waiting ? "on" : "off"]")

/datum/admins/proc/adjump()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle admin jumping"
	set name="Toggle Jump"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	config.allow_admin_jump = !(config.allow_admin_jump)
	message_admins(SPAN_INTERNAL("Toggled admin jumping to [config.allow_admin_jump]."))

/datum/admins/proc/togglesimsmode()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Enable sims mode for this round."
	set name = "Toggle Sims Mode"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	global_sims_mode = !global_sims_mode
	simsController.provide_plumbobs = !simsController.provide_plumbobs
	message_admins(SPAN_INTERNAL("[key_name(usr)] toggled sims mode. [global_sims_mode ? "Oh, the humanity!" : "Phew, it's over."]"))
	for (var/mob/M in mobs)
		LAGCHECK(LAG_LOW)
		boutput(M, "<b>Motives have been globally [global_sims_mode ? "enabled" : "disabled"].</b>")
		if (ishuman(M))
			var/mob/living/carbon/human/H = M
			if (global_sims_mode && !H.sims)
#ifdef RP_MODE
				H.sims = new /datum/simsHolder/rp(H)
#else
				H.sims = new /datum/simsHolder/human(H)
#endif
			else if (!global_sims_mode && H.sims)
				qdel(H.sims)
				H.sims = null

/datum/admins/proc/toggle_pull_slowing()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle whether pulling items should slow people down or not."
	set name = "Toggle Pull Slowing"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	pull_slowing = !( pull_slowing )
	logTheThing(LOG_ADMIN, usr, "toggled pull slowing [pull_slowing ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled pull slowing [pull_slowing ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled pull slowing [pull_slowing ? "on" : "off"]")

/datum/admins/proc/toggle_radio_audio()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle whether record players and tape decks can play any audio"
	set name = "Toggle Radio Audio"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF

	var/oview_phrase
	switch (radio_audio_enabled)
		if (FALSE)
			oview_phrase = SPAN_ALERT("A glowing hand appears out of nowhere and rips \"out of order\" sticker on OBJECT_NAME!")
		if (TRUE)
			oview_phrase = SPAN_ALERT("A glowing hand appears out of nowhere and slaps a \"out of order\" sticker on OBJECT_NAME!")

	for(var/obj/submachine/tape_deck/O in by_type[/obj/submachine/tape_deck])
		for(var/mob/living/M in oview(5, O))
			boutput(M, replacetext(oview_phrase, "OBJECT_NAME", "\the [O.name]"))
		O.can_play_tapes = !radio_audio_enabled

	for(var/obj/submachine/record_player/O in by_type[/obj/submachine/record_player])
		for(var/mob/living/M in oview(5, O))
			boutput(M, replacetext(oview_phrase, "OBJECT_NAME", "\the [O.name]"))
		O.can_play_music = !radio_audio_enabled

	radio_audio_enabled = !radio_audio_enabled

	message_admins(SPAN_INTERNAL("[key_name(usr)] [radio_audio_enabled ? "" : "dis"]allowed for radio music/tapes to play."))
	logTheThing(LOG_DIARY, usr, "[radio_audio_enabled ? "" : "dis"]allowed for radio music/tapes to play.")
	logTheThing(LOG_ADMIN, usr, "[radio_audio_enabled ? "" : "dis"]allowed for radio music/tapes to play.")


/datum/admins/proc/toggle_remote_music_announcements()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle whether remotely-played music tracks are announced."
	set name = "Toggle Music Announcements"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	remote_music_announcements = !( remote_music_announcements )
	logTheThing(LOG_ADMIN, usr, "toggled remote music announcements [remote_music_announcements ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled remote music announcements [remote_music_announcements ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled remote music announcements [remote_music_announcements ? "on" : "off"]")


//Dont need this any more? Player controlled now
/*
/client/proc/togglewidescreen()
	set name = "Toggle Widescreen Station"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "SS13, future edition. Toggle widescreen for all clients."
	ADMIN_ONLY
	NOT_IF_TOGGLES_ARE_OFF

	if( view == "21x15" )
		for(var/client/C)
			C.set_widescreen(0)
		message_admins( "[key_name(src)] toggled widescreen off." )
	else
		for(var/client/C)
			C.set_widescreen(1)
		message_admins( "[key_name(src)] toggled widescreen on." )
*/



/datum/admins/proc/togglepowerdebug()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc="Toggle power debugging popups"
	set name="Toggle Power Debug"
	USR_ADMIN_ONLY
	SHOW_VERB_DESC
	NOT_IF_TOGGLES_ARE_OFF
	zamus_dumb_power_popups = !( zamus_dumb_power_popups )
	logTheThing(LOG_ADMIN, usr, "toggled power debug popups.")
	logTheThing(LOG_DIARY, usr, "toggled power debug popups.", "admin")
	message_admins("[key_name(usr)] toggled power debug popups.")


/client/proc/toggle_next_click()
	set name = "Toggle next_click"
	set desc = "Removes most click delay. Don't know what this is? Probably shouldn't touch it."
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	ADMIN_ONLY
	SHOW_VERB_DESC

	disable_next_click = !(disable_next_click)
	logTheThing(LOG_ADMIN, usr, "toggled next_click [disable_next_click ? "off" : "on"].")
	logTheThing(LOG_DIARY, usr, "toggled next_click [disable_next_click ? "off" : "on"].", "admin")
	message_admins("[key_name(usr)] toggled next_click [disable_next_click ? "off" : "on"]")

/client/proc/narrator_mode()
	set name = "Toggle Narrator Mode"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle narrator mode on or off."
	ADMIN_ONLY
	SHOW_VERB_DESC

	narrator_mode = !(narrator_mode)

	logTheThing(LOG_ADMIN, usr, "toggled narrator mode [narrator_mode ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled narrator mode [narrator_mode ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled narrator mode [narrator_mode ? "on" : "off"]")


/client/proc/force_desussification()
	set name = "Force De-Sussification"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle behavior correction."
	ADMIN_ONLY
	SHOW_VERB_DESC

	// Zam note: this is horrible.
	// I could probably get away with !(forced_desussification), but
	// in this case the value is "above 1" or "zero", so it works fine
	forced_desussification = ( forced_desussification ? 0 : 1 )
	var/message = "toggled de-sussification [forced_desussification ? "on" : "off"]"

	if (forced_desussification)
		var/shockLevel = input(usr, "How strong of a zap?", "Shock Collar", 5000) as num
		var/getsWorse = alert(usr, "Does it get worse each time? (They will absolutely get this to instant-gib levels)", "Fun Time", "YES... HA HA HA... YES!", "Nah")

		// remember, any value above 0 = zzzzt
		forced_desussification = shockLevel
		forced_desussification_worse = (getsWorse == "Nah") ? 0 : 1

		message += ", with shock level [shockLevel][forced_desussification_worse ? " (and rising)" : ""]"
		RegisterSignal(GLOBAL_SIGNAL, COMSIG_ATOM_SAY, PROC_REF(desuss_zap))

	logTheThing(LOG_ADMIN, usr, message)
	logTheThing(LOG_DIARY, usr, message, "admin")
	message_admins("[key_name(usr)] [message]")


/client/proc/toggle_station_name_changing()
	set name = "Toggle Station Name Changing"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle station name changing on or off."
	ADMIN_ONLY
	SHOW_VERB_DESC

	station_name_changing = !(station_name_changing)

	logTheThing(LOG_ADMIN, usr, "toggled station name changing [station_name_changing ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled station name changing [station_name_changing ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled station name changing [station_name_changing ? "on" : "off"]")

/client/proc/toggle_map_voting()
	set name = "Toggle Map Voting"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle whether map votes are allowed"
	set popup_menu = 0

	ADMIN_ONLY
	SHOW_VERB_DESC

	var/bustedMapSwitcher = isMapSwitcherBusted()
	if (bustedMapSwitcher)
		return alert(bustedMapSwitcher)

	mapSwitcher.votingAllowed = !mapSwitcher.votingAllowed

	logTheThing(LOG_ADMIN, usr, "toggled map voting [mapSwitcher.votingAllowed ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled map voting [mapSwitcher.votingAllowed ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled map voting [mapSwitcher.votingAllowed ? "on" : "off"]")

/client/proc/waddle_walking()
	set name = "Toggle Waddle Walking"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set desc = "Toggle waddle walking on or off."
	ADMIN_ONLY
	SHOW_VERB_DESC

	waddle_walking = !(waddle_walking)

	logTheThing(LOG_ADMIN, usr, "toggled waddle walking [waddle_walking ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled waddle walking [waddle_walking ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled waddle walking [waddle_walking ? "on" : "off"]")

/client/proc/toggle_respawn_arena()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle Respawn Arena"
	set desc = "Lets ghosts go to the respawn arena to compete for a new life"

	ADMIN_ONLY
	SHOW_VERB_DESC
	respawn_arena_enabled = 1 - respawn_arena_enabled
	logTheThing(LOG_ADMIN, usr, "toggled the respawn arena [respawn_arena_enabled ? "on" : "off"].")
	logTheThing(LOG_DIARY, usr, "toggled the respawn arena [respawn_arena_enabled ? "on" : "off"].", "admin")
	message_admins("[key_name(usr)] toggled the respawn arena [respawn_arena_enabled ? "on" : "off"]")
	if(respawn_arena_enabled)
		boutput(world, "<B>The Respawn Arena has been enabled! Use the go_to_respawn_arena verb as a ghost to compete for a new life!</B>")
	else
		boutput(world, "<B>The Respawn Arena has been disabled.</B>")

/client/proc/toggle_vpn_blacklist()
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	set name = "Toggle VPN Blacklist"
	set desc = "Toggle the ability for new players to connect through a VPN or proxy server"
	ADMIN_ONLY
	SHOW_VERB_DESC
	if(rank_to_level(src.holder.rank) >= LEVEL_PA)
#ifdef DO_VPN_CHECKS
		vpn_blacklist_enabled = !vpn_blacklist_enabled

		logTheThing(LOG_ADMIN, src, "toggled VPN and proxy blacklisting [vpn_blacklist_enabled ? "on" : "off"].")
		logTheThing(LOG_DIARY, src, "toggled VPN and proxy blacklisting [vpn_blacklist_enabled ? "on" : "off"].", "admin")
		message_admins("[key_name(src)] toggled VPN and proxy blacklisting [vpn_blacklist_enabled ? "on" : "off"]")
#else
		boutput(src, "VPN Checks are currently disabled on this server!")
#endif
	else
		boutput(src, "You cannot perform this action. You must be of a higher administrative rank!")

/client/proc/toggle_spooky_light_plane()
	set name = "Toggle Spooky Light Mode"
	set desc = "toggle thresholded lighting plane"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/inp = input(usr, "What lighting threshold to set? 0 - 255", "What lighting threshold to set? 0 - 255. Cancel to disable.", 255 - 24) as num|null
	if(!isnull(inp))
		spooky_light_mode = 255 - inp
	else // turn off
		spooky_light_mode = 0
	for(var/client/C in clients)
		var/atom/plane_parent = C.get_plane(PLANE_LIGHTING)
		animate(plane_parent, time=4 SECONDS, color=spooky_light_mode ? list(255, 0, 0, 0, 255, 0, 0, 0, 255, -spooky_light_mode, -spooky_light_mode - 1, -spooky_light_mode - 2) : null)
		animate(C, time=4 SECONDS, color=spooky_light_mode ? "#AAAAAA" : null)

	logTheThing(LOG_ADMIN, usr, "toggled Spooky Light Mode [spooky_light_mode ? "on at threshold [inp]" : "off"]")
	logTheThing(LOG_DIARY, usr, "toggled Spooky Light Mode [spooky_light_mode ? "on at threshold [inp]" : "off"]")
	message_admins("[key_name(usr)] toggled Spooky Light Mode [spooky_light_mode ? "on at threshold [inp]" : "off"]")

/client/proc/toggle_random_job_selection()
	set name = "Toggle Random Job Selection"
	set desc = "toggles random job rolling at the start of the round; preferences will be ignored. Has no effect on latejoins."
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	ADMIN_ONLY
	SHOW_VERB_DESC

	global.totally_random_jobs = !global.totally_random_jobs
	logTheThing(LOG_ADMIN, usr, "toggled random job selection [global.totally_random_jobs ? "on" : "off"]")
	logTheThing(LOG_DIARY, usr, "toggled random job selection [global.totally_random_jobs ? "on" : "off"]")
	message_admins("[key_name(usr)] toggled random job selection [global.totally_random_jobs ? "on" : "off"]")

/client/proc/toggle_tracy_profiling()
	set name = "Toggle Tracy Profiling"
	set desc = "Toggle Tracy profiling on the next round"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	ADMIN_ONLY
	SHOW_VERB_DESC

	var/enabled = toggle_tracy_profiling_file()
	logTheThing(LOG_ADMIN, usr, "[enabled ? "enabled" : "disabled"] Tracy profiling for the next round.")
	logTheThing(LOG_DIARY, usr, "[enabled ? "enabled" : "disabled"] Tracy profiling for the next round.", "admin")
	message_admins("[key_name(usr)] [enabled ? "enabled" : "disabled"] Tracy profiling for the next round.")

/client/proc/toggle_ghost_invisibility()
	set name = "Toggle Ghost Invisibility"
	set desc = "Toggle whether ghosts are invisible or not mid-round"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	ADMIN_ONLY
	SHOW_VERB_DESC

	if (ghost_invisibility == INVIS_GHOST)
		change_ghost_invisibility(INVIS_NONE)
		message_admins("[key_name(usr)] made ghosts visible.")
	else
		change_ghost_invisibility(INVIS_GHOST)
		message_admins("[key_name(usr)] made ghosts invisible.")
	logTheThing(LOG_ADMIN, usr, "toggled ghost (in)visibility")

/client/proc/toggle_tutorial_enabled()
	set name = "Toggle Tutorial Enabled"
	set desc = "Toggle whether people can start the tutorial"
	SET_ADMIN_CAT(ADMIN_CAT_SERVER_TOGGLES)
	ADMIN_ONLY
	SHOW_VERB_DESC

	global.newbee_tutorial_enabled = !global.newbee_tutorial_enabled

	logTheThing(LOG_ADMIN, usr, "[global.newbee_tutorial_enabled ? "enabled" : "disabled"] the tutorial.")
	message_admins("[key_name(usr)] [global.newbee_tutorial_enabled ? "enabled" : "disabled"] the tutorial.")

	for (var/mob/new_player/player in mobs)
		if (!global.newbee_tutorial_enabled)
			if (player.ready_tutorial == TRUE)
				boutput(player, SPAN_ALERT("An administrator has disabled the tutorial for this round!"))
			player.ready_tutorial = FALSE
		player.update_joinmenu()
