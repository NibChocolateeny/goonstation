#define MINING_OUTPOST_NAME "Old Mining Station"

/obj/machinery/computer/shuttle
	name = "Shuttle"
	icon_state = "shuttle"
	var/auth_need = 3
	var/list/authorized = list(  )
	desc = "A computer that controls the movement of the nearby shuttle."

	light_r =0.6
	light_g = 1
	light_b = 0.1

/obj/machinery/computer/shuttle/embedded
	icon_state = "shuttle-embed"
	density = 0
	layer = EFFECTS_LAYER_1 // Must appear over cockpit shuttle wall thingy.
	plane = PLANE_DEFAULT

	north
		dir = NORTH
		pixel_y = 25

	east
		dir = EAST
		pixel_x = 25

	south
		dir = SOUTH
		pixel_y = -25

	west
		dir = WEST
		pixel_x = -25

ABSTRACT_TYPE(/obj/machinery/computer/transit_shuttle)
/obj/machinery/computer/transit_shuttle // this is the new shuttle console for travelling
	name = "You shouldnt see this Shuttle Computer"
	icon_state = "shuttle"
	desc = "A computer that controls the movement of the imcoder."
	flags = TGUI_INTERACTIVE
	machine_registry_idx = MACHINES_SHUTTLECOMPS

	var/active =  FALSE
	var/shuttlename = "imcoder"
	var/list/destinations // list of the area paths

	var/area/currentlocation
	var/area/endlocation
	var/ejectdir = NORTH
	var/shuttle_locked = FALSE// prevents shuttle console from calling
	var/embed = FALSE // embeds the console on creation

	var/transit_delay = 10 SECONDS

/obj/machinery/computer/transit_shuttle/New()
	..()
	name = "[src.shuttlename] Shuttle Computer"
	desc = "A computer that controls the movement of the [src.shuttlename]."
	if(src.embed)
		src.icon_state = "shuttle-embed"
		src.layer = EFFECTS_LAYER_1 // Must appear over cockpit shuttle wall thingy.
		src.plane = PLANE_DEFAULT
		src.density = 0
		switch(src.dir)
			if (NORTH)
				pixel_y = 25
			if (EAST)
				pixel_x = 25
			if (SOUTH)
				pixel_y = -25
			if (WEST)
				pixel_x = -25

/obj/machinery/computer/transit_shuttle/power_change()  // fuck you parent code
	if(powered() && embed)
		icon_state = "shuttle-embed"
		status &= ~NOPOWER
		light.enable()
		if(glow_in_dark_screen)
			screen_image.plane = PLANE_LIGHTING
			screen_image.blend_mode = BLEND_ADD
			screen_image.layer = LIGHTING_LAYER_BASE
			screen_image.color = list(0.33,0.33,0.33, 0.33,0.33,0.33, 0.33,0.33,0.33)
			src.UpdateOverlays(screen_image, "screen_image")
	else
		. = ..()

/obj/machinery/computer/transit_shuttle/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TransitShuttle")
		ui.open()

/obj/machinery/computer/transit_shuttle/attack_hand(mob/user)
	if(..())
		return
	src.ui_interact(user)

/obj/machinery/computer/transit_shuttle/ui_static_data(mob/user)
	. = ..()
	. = list("shuttlename" = src.shuttlename)
	for(var/path in destinations)
		var/area/A = locate(path)
		.["destinations"] +=  list(list("type" = A?.type,"name" = A?.name))

/obj/machinery/computer/transit_shuttle/ui_data(mob/user)
	. = ..()
	. = list(
		"moving" = src.active,
		"locked" = src.shuttle_locked,
		)
	if(src.currentlocation)
		.["currentlocation"] = list("type" = src.currentlocation.type,"name" = src.currentlocation.name)
	if(src.endlocation && src.endlocation != src.currentlocation && src.active)
		.["endlocation"] = list("type" = src.endlocation.type,"name" = src.endlocation.name)

/obj/machinery/computer/transit_shuttle/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.) return
	switch(action)
		if ("callto")
			if (active || shuttle_locked)
				return
			if (params["dest"])
				src.endlocation = locate(text2path(params["dest"]))
				if(src.announce_move(endlocation))
					src.active = TRUE
					SPAWN(src.transit_delay)
						src.call_shuttle(endlocation)

/obj/machinery/computer/transit_shuttle/proc/announce_move(area/end_location)
	for(var/obj/machinery/computer/transit_shuttle/Console in machine_registry[MACHINES_SHUTTLECOMPS])
		if (Console.shuttlename != src.shuttlename) continue
		if(!currentlocation || !end_location)
			if (src.transit_delay)
				Console.visible_message(SPAN_ALERT("[src.shuttlename] cant seem to move! Uh Oh."))
		else
			Console.active = TRUE
			if (src.transit_delay)
				Console.visible_message(SPAN_ALERT("[src.shuttlename] is moving to [end_location]!"))
				playsound(Console.loc, 'sound/machines/transport_move.ogg', 75, 0)
	return (currentlocation && end_location)

/obj/machinery/computer/transit_shuttle/proc/call_shuttle(area/end_location)
	// shuttle crush stuff stolen from shuttle_controller.dm
	if (currentlocation && end_location)

		var/list/dstturfs = list()
		var/northBound = 1
		var/southBound = world.maxy
		var/westBound = world.maxx
		var/eastBound = 1

		for (var/atom/A as obj|mob in end_location)
			SPAWN(0)
				if (isliving(A) && !isintangible(A))
					var/mob/living/M = A
					logTheThing(LOG_COMBAT, M, "was hit by an arriving shuttle at [log_loc(M)].")
				A.ex_act(1)
		for (var/turf/T in end_location) // figure out the edge of the shuttle
			dstturfs += T
			if (T.y > northBound) northBound = T.y
			if (T.y < southBound) southBound = T.y
			if (T.x < westBound) westBound = T.x
			if (T.x > eastBound) eastBound = T.x

		for (var/turf/T in dstturfs)
			for (var/atom/movable/AM as mob|obj in T)
				if (isobserver(AM))
					continue // skip ghosties
				if (istype(AM, /obj/overlay/tile_effect))
					continue
				if (istype(AM, /obj/effects/precipitation))
					continue
				var/turf/ejectT
				switch(ejectdir) // find the spot to push everything
					if (NORTH)
						ejectT = locate(T.x,northBound + 1,T.z)
					if (EAST)
						ejectT = locate(eastBound + 1,T.y,T.z)
					if (SOUTH)
						ejectT = locate(T.x,southBound - 1,T.z)
					if (WEST)
						ejectT = locate(westBound - 1,T.y,T.z)
				if (istype(AM, /atom/movable/buried_storage))
					var/atom/movable/buried_storage/buried_storage = AM
					for (var/atom/movable/buried as anything in buried_storage)
						buried.set_loc(ejectT)
					buried_storage.has_buried_mob = FALSE
					buried_storage.number_of_objects = 0
					continue
				AM.set_loc(ejectT)

		currentlocation.move_contents_to(end_location, turf_to_skip=list(/turf/space, global.map_settings.shuttle_map_turf))

		// cant figure out why the walls arent behaving when moved so
		for (var/turf/unsimulated/wall/auto/wall in end_location)
			wall.UpdateIcon()
		for (var/turf/simulated/wall/auto/wall in end_location)
			wall.UpdateIcon()

		if (currentlocation.z == Z_LEVEL_STATION && station_repair.station_generator)
			var/list/turf/turfs_to_fix = get_area_turfs(currentlocation)
			if(length(turfs_to_fix))
				station_repair.repair_turfs(turfs_to_fix, force_floor=TRUE)

	for(var/obj/machinery/computer/transit_shuttle/Console in machine_registry[MACHINES_SHUTTLECOMPS])
		if (Console.shuttlename != src.shuttlename) continue
		Console.visible_message(SPAN_ALERT("[src.shuttlename] has Moved!"))
		Console.currentlocation = end_location
		Console.active = FALSE

// non escape Shuttle types below

// mining shuttle
/obj/machinery/computer/transit_shuttle/mining
	shuttlename = "Mining Shuttle"
	ejectdir = SOUTH
/obj/machinery/computer/transit_shuttle/mining/New()
	..()
	destinations = list(/area/shuttle/mining/station,
	/area/shuttle/mining/diner,
	/area/shuttle/mining/outpost)
	currentlocation = locate(/area/shuttle/mining/diner)

/obj/machinery/computer/transit_shuttle/mining/

/obj/machinery/computer/transit_shuttle/mining/announce_move(area/end_location)
	. = ..()
	if(istype(src.currentlocation, /area/shuttle/mining/station))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MINING_STATION, DOCK_EVENT_OUTGOING)
	else if(istype(src.currentlocation, /area/shuttle/mining/diner))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MINING_DINER, DOCK_EVENT_OUTGOING)
	else if(istype(src.currentlocation, /area/shuttle/mining/outpost))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MINING_OUTPOST, DOCK_EVENT_OUTGOING)

	if(istype(end_location, /area/shuttle/mining/station))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MINING_STATION, DOCK_EVENT_INCOMING)
	else if(istype(end_location, /area/shuttle/mining/diner))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MINING_DINER, DOCK_EVENT_INCOMING)
	else if(istype(end_location, /area/shuttle/mining/outpost))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MINING_OUTPOST, DOCK_EVENT_INCOMING)

/obj/machinery/computer/transit_shuttle/mining/call_shuttle(area/end_location)
	if(istype(src.currentlocation, /area/shuttle/mining/station))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MINING_STATION, DOCK_EVENT_DEPARTED)
	else if(istype(src.currentlocation, /area/shuttle/mining/diner))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MINING_DINER, DOCK_EVENT_DEPARTED)
	else if(istype(src.currentlocation, /area/shuttle/mining/outpost))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MINING_OUTPOST, DOCK_EVENT_DEPARTED)

	if(istype(end_location, /area/shuttle/mining/station))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MINING_STATION, DOCK_EVENT_ARRIVED)
	else if(istype(end_location, /area/shuttle/mining/diner))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MINING_DINER, DOCK_EVENT_ARRIVED)
	else if(istype(end_location, /area/shuttle/mining/outpost))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MINING_OUTPOST, DOCK_EVENT_ARRIVED)
	. = ..()

// asylum shuttle
/obj/machinery/computer/transit_shuttle/asylum
	shuttlename = "Asylum Shuttle"
/obj/machinery/computer/transit_shuttle/asylum/New()
	..()
	destinations = list(/area/shuttle/asylum/observation,
	/area/shuttle/asylum/medbay,
	/area/shuttle/asylum/pathology)
	currentlocation = locate(/area/shuttle/asylum/medbay)

/obj/machinery/computer/transit_shuttle/asylum/announce_move(area/end_location)
	. = ..()
	if(istype(src.currentlocation, /area/shuttle/asylum/medbay))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MEDICAL_MEDBAY, DOCK_EVENT_OUTGOING)
	else if(istype(src.currentlocation, /area/shuttle/asylum/observation))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MEDICAL_ASYLUM, DOCK_EVENT_OUTGOING)
	else if(istype(src.currentlocation, /area/shuttle/asylum/pathology))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MEDICAL_PATHOLOGY, DOCK_EVENT_OUTGOING)

	if(istype(end_location, /area/shuttle/asylum/medbay))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MEDICAL_MEDBAY, DOCK_EVENT_INCOMING)
	else if(istype(end_location, /area/shuttle/asylum/observation))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MEDICAL_ASYLUM, DOCK_EVENT_INCOMING)
	else if(istype(end_location, /area/shuttle/asylum/pathology))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MEDICAL_PATHOLOGY, DOCK_EVENT_INCOMING)


/obj/machinery/computer/transit_shuttle/asylum/call_shuttle(area/end_location)
	if(istype(src.currentlocation, /area/shuttle/asylum/medbay))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MEDICAL_MEDBAY, DOCK_EVENT_DEPARTED)
	else if(istype(src.currentlocation, /area/shuttle/asylum/observation))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MEDICAL_ASYLUM, DOCK_EVENT_DEPARTED)
	else if(istype(src.currentlocation, /area/shuttle/asylum/pathology))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MEDICAL_PATHOLOGY, DOCK_EVENT_DEPARTED)

	if(istype(end_location, /area/shuttle/asylum/medbay))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MEDICAL_MEDBAY, DOCK_EVENT_ARRIVED)
	else if(istype(end_location, /area/shuttle/asylum/observation))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MEDICAL_ASYLUM, DOCK_EVENT_ARRIVED)
	else if(istype(end_location, /area/shuttle/asylum/pathology))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_MEDICAL_PATHOLOGY, DOCK_EVENT_ARRIVED)
	. = ..()

// research shuttle
/obj/machinery/computer/transit_shuttle/research
	shuttlename = "Research Shuttle"
/obj/machinery/computer/transit_shuttle/research/New()
	..()
	destinations = list(/area/shuttle/research/station,
	/area/shuttle/research/outpost)
	currentlocation = locate(/area/shuttle/research/outpost)

/obj/machinery/computer/transit_shuttle/research/announce_move(area/end_location)
	. = ..()
	if(istype(src.currentlocation, /area/shuttle/research/station))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_RESEARCH_STATION, DOCK_EVENT_OUTGOING)
	else if(istype(src.currentlocation, /area/shuttle/research/outpost))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_RESEARCH_OUTPOST, DOCK_EVENT_OUTGOING)

	if(istype(end_location, /area/shuttle/research/station))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_RESEARCH_STATION, DOCK_EVENT_INCOMING)
	else if(istype(end_location, /area/shuttle/research/outpost))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_RESEARCH_OUTPOST, DOCK_EVENT_INCOMING)

/obj/machinery/computer/transit_shuttle/research/call_shuttle(area/end_location)
	if(istype(src.currentlocation, /area/shuttle/research/station))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_RESEARCH_STATION, DOCK_EVENT_DEPARTED)
	else if(istype(src.currentlocation, /area/shuttle/research/outpost))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_RESEARCH_OUTPOST, DOCK_EVENT_DEPARTED)

	if(istype(end_location, /area/shuttle/research/station))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_RESEARCH_STATION, DOCK_EVENT_ARRIVED)
	else if(istype(end_location, /area/shuttle/research/outpost))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_RESEARCH_OUTPOST, DOCK_EVENT_ARRIVED)
	. = ..()

/obj/machinery/computer/transit_shuttle/research/embedded
	icon_state = "shuttle-embed";
	pixel_y = -25
	ejectdir = SOUTH
	embed = 1

// JOHN BILL'S JUICIN' BUS
// This is used for a secondary reliable transport between Z3 and Z5
// And also for certain adventure zones!
// You can ask warc for details but c'mon it's just copypasted prison shuttle code (for now)
var/bombini_saved
/obj/machinery/computer/transit_shuttle/johnbus // moved onto the new parent object
	shuttlename = "John's Juicin' Bus"
	transit_delay = 0 SECONDS // handled elsewhere
	ejectdir = SOUTH
/obj/machinery/computer/transit_shuttle/johnbus/New()
	..()
	destinations = list(/area/shuttle/john/owlery,/area/shuttle/john/diner)
	currentlocation = locate(/area/shuttle/john/owlery)
#ifndef UNDERWATER_MAP
	destinations += /area/shuttle/john/mining
#endif

/obj/machinery/computer/transit_shuttle/johnbus/ui_static_data(mob/user)
	. = ..()
	var/area/A
	if(johnbill_shuttle_fartnasium_active)
		A = locate(/area/shuttle/john/grillnasium)
		.["destinations"] += list(list("type" = A?.type,"name" = A?.name))

/obj/machinery/computer/transit_shuttle/johnbus/announce_move(area/end_location)
	. = ..()

	if(istype(src.currentlocation, /area/shuttle/john/owlery))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_OWLERY, DOCK_EVENT_OUTGOING)
	else if(istype(src.currentlocation, /area/shuttle/john/diner))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_DINER, DOCK_EVENT_OUTGOING)
	else if(istype(src.currentlocation, /area/shuttle/john/mining))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_OUTPOST, DOCK_EVENT_OUTGOING)
	else if (istype(src.currentlocation, /area/shuttle/john/grillnasium))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_GRILLNASIUM, DOCK_EVENT_OUTGOING)

	if(istype(end_location, /area/shuttle/john/owlery))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_OWLERY, DOCK_EVENT_INCOMING)
	else if(istype(end_location, /area/shuttle/john/diner))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_DINER, DOCK_EVENT_INCOMING)
	else if(istype(end_location, /area/shuttle/john/mining))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_OUTPOST, DOCK_EVENT_INCOMING)
	else if(istype(end_location, /area/shuttle/john/grillnasium))
		SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_GRILLNASIUM, DOCK_EVENT_INCOMING)

/obj/machinery/computer/transit_shuttle/johnbus/call_shuttle(area/end_location)
	var/turf/T = get_turf(src)
	if(bombini_saved && istype(currentlocation,/area/shuttle/john/owlery))
		for(var/obj/npc/trader/bee/b in currentlocation)
			bombini_saved = TRUE
			for(var/mob/M in currentlocation)
				boutput(M, SPAN_NOTICE("It would be great if things worked that way, but they don't. You'll need to find what <b>Bombini</b> is missing, now."))

	for(var/obj/machinery/computer/transit_shuttle/Console in machine_registry[MACHINES_SHUTTLECOMPS])
		if (Console.shuttlename != src.shuttlename) continue
		Console.visible_message(SPAN_ALERT("John is starting up the engines, this could take a minute!"))
		if(!Console.embed) continue
		T = get_turf(Console)
		SPAWN(1 DECI SECOND)
			playsound(T, 'sound/effects/ship_charge.ogg', 60, TRUE)
			sleep(3 SECONDS)
			playsound(T, 'sound/machines/weaponoverload.ogg', 60, TRUE)
			Console.visible_message(SPAN_ALERT("The shuttle is making a hell of a racket!"))
			sleep(5 SECONDS)
			playsound(T, 'sound/impact_sounds/Machinery_Break_1.ogg', 60, TRUE)
			for(var/mob/living/M in range(Console.loc, 10))
				shake_camera(M, 5, 8)
				M.add_karma(0.1)

			sleep(2 SECONDS)
			playsound(T, 'sound/effects/creaking_metal2.ogg', 70, TRUE)
			sleep(3 SECONDS)
			Console.visible_message(SPAN_ALERT("The shuttle engine alarms start blaring!"))
			playsound(T, 'sound/machines/pod_alarm.ogg', 60, TRUE)
			var/obj/fakeobject/shuttleengine/smokyEngine = locate() in get_area(Console)
			var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
			smoke.set_up(5, 0, smokyEngine)
			smoke.start()
			sleep(4 SECONDS)
			playsound(T, 'sound/machines/boost.ogg', 60, TRUE)
			for(var/mob/living/M in range(Console.loc, 10))
				shake_camera(M, 10, 16)

	T = get_turf(src)
	SPAWN(25 SECONDS)
		playsound(T, 'sound/effects/flameswoosh.ogg', 70, TRUE)
		if(istype(src.currentlocation, /area/shuttle/john/owlery))
			SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_OWLERY, DOCK_EVENT_DEPARTED)
		else if(istype(src.currentlocation, /area/shuttle/john/diner))
			SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_DINER, DOCK_EVENT_DEPARTED)
		else if(istype(src.currentlocation, /area/shuttle/john/mining))
			SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_OUTPOST, DOCK_EVENT_DEPARTED)
		else if (istype(src.currentlocation, /area/shuttle/john/grillnasium))
			SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_GRILLNASIUM, DOCK_EVENT_DEPARTED)

		if(istype(end_location, /area/shuttle/john/owlery))
			SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_OWLERY, DOCK_EVENT_ARRIVED)
		else if(istype(end_location, /area/shuttle/john/diner))
			SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_DINER, DOCK_EVENT_ARRIVED)
		else if(istype(end_location, /area/shuttle/john/mining))
			SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_OUTPOST, DOCK_EVENT_ARRIVED)
		else if(istype(end_location, /area/shuttle/john/grillnasium))
			SEND_GLOBAL_SIGNAL(COMSIG_DOCK_JOHN_GRILLNASIUM, DOCK_EVENT_ARRIVED)

		..()

/obj/machinery/computer/shuttle/embedded/syndieshuttle
	name = "Shuttle Computer"
	icon = 'icons/obj/decoration.dmi'
	icon_state = "syndiepc4"

/obj/machinery/computer/shuttle/attackby(var/obj/item/W, var/mob/user)
	if(!(istype(W, /obj/item/disk/data/floppy/read_only/authentication) || istype(W, /obj/item/card/id)) || (status & (BROKEN|NOPOWER)))
		return ..()

	if (istype(W, /obj/item/disk/data/floppy/read_only/authentication))
		if(emergency_shuttle.location != SHUTTLE_LOC_STATION)
			return
		for (var/datum/flock/flock in flocks)
			if (flock.relay_in_progress)
				boutput(user, SPAN_ALERT("[src] emits a pained burst of static, but nothing happens!"))
				return

		if (user)
			var/choice = tgui_alert(user, "Would you like to launch the escape shuttle early?", "Shuttle control", list("Launch", "Cancel"))

			if (BOUNDS_DIST(user, src) > 0 || emergency_shuttle.location != SHUTTLE_LOC_STATION) return

			if (choice == "Launch")
				boutput(world, SPAN_NOTICE("<B>Alert: Shuttle launch time shortened to 10 seconds!</B>"))
				emergency_shuttle.settimeleft( 10 )
				logTheThing(LOG_ADMIN, user, "shortens Emergency Shuttle launch time to 10 seconds.")


	var/obj/item/card/id/id_card = get_id_card(W)
	if (istype(id_card))
		W = id_card

	if ((!( istype(W, /obj/item/card) ) || !( ticker ) || emergency_shuttle.location != SHUTTLE_LOC_STATION || !( user )))
		return


	if (istype(W, /obj/item/card/id))

		if (!W:access) //no access
			boutput(user, "The access level of [W:registered]\'s card is not high enough. ")
			return

		var/list/cardaccess = W:access
		if(!istype(cardaccess, /list) || !length(cardaccess)) //no access
			boutput(user, "The access level of [W:registered]\'s card is not high enough. ")
			return

		if(!(access_heads in W:access)) //doesn't have this access
			boutput(user, "The access level of [W:registered]\'s card is not high enough. ")
			return 0

		var/choice = tgui_alert(user, "Would you like to (un)authorize a shortened launch time? [src.auth_need - length(src.authorized)] authorization\s are still needed. Use abort to cancel all authorizations.", "Shuttle Launch", list("Authorize", "Repeal", "Abort"))
		if(!choice || emergency_shuttle.location != SHUTTLE_LOC_STATION || BOUNDS_DIST(user, src) > 0) return
		switch(choice)
			if("Authorize")
				for (var/flockname in flocks)
					var/datum/flock/flock = flocks[flockname]
					if (flock.relay_in_progress)
						boutput(user, "Unable to contact central command, authorization rejected.")
						return
				if(emergency_shuttle.timeleft() < 60)
					boutput(user, "The shuttle is already leaving in less than 60 seconds!")
					return
				src.authorized |= W:registered
				if (src.auth_need - length(src.authorized) > 0)
					boutput(world, SPAN_NOTICE("<B>Alert: [src.auth_need - length(src.authorized)] authorizations needed until shuttle is launched early</B>"))
				else
					boutput(world, SPAN_NOTICE("<B>Alert: Shuttle launch time shortened to 60 seconds!</B>"))
					emergency_shuttle.settimeleft(60)
					qdel(src.authorized)
					src.authorized = list(  )

			if("Repeal")
				src.authorized -= W:registered
				boutput(world, SPAN_NOTICE("<B>Alert: [src.auth_need - length(src.authorized)] authorizations needed until shuttle is launched early</B>"))

			if("Abort")
				boutput(world, SPAN_NOTICE("<B>All authorizations to shorting time for shuttle launch have been revoked!</B>"))
				src.authorized.len = 0
				src.authorized = list(  )


ABSTRACT_TYPE(/obj/machinery/computer/elevator)
/obj/machinery/computer/elevator
	name = "Elevator Control"
	icon_state = "shuttle"
	var/active = 0
	var/location = 1 // 0 for bottom, 1 for top

	var/areaLower
	var/areaUpper
	var/startTurfToLeave = /turf/simulated/floor/plating
	var/endTurfToLeave = /turf/simulated/floor/plating
	var/logBioeleAccident = FALSE
	var/adminOnly = FALSE


/obj/machinery/computer/elevator/icebase
	machine_registry_idx = MACHINES_ELEVATORICEBASE
	areaLower = /area/shuttle/icebase_elevator/lower
	areaUpper = /area/shuttle/icebase_elevator/upper
	endTurfToLeave = /turf/simulated/floor/arctic_elevator_shaft

/obj/machinery/computer/elevator/biodome
	machine_registry_idx = MACHINES_ELEVATORBIODOME
	areaLower = /area/shuttle/biodome_elevator/lower
	areaUpper = /area/shuttle/biodome_elevator/upper
	endTurfToLeave = /turf/simulated/floor/auto/elevator_shaft/biodome
	logBioeleAccident = TRUE

/obj/machinery/computer/elevator/sea
	machine_registry_idx = MACHINES_ELEVATORSEA
	areaLower = /area/shuttle/sea_elevator/lower
	areaUpper = /area/shuttle/sea_elevator/upper
	endTurfToLeave = /turf/simulated/floor/auto/elevator_shaft/sea
	circuit_type = /obj/item/circuitboard/sea_elevator

	New()
		..()
		var/area/top = locate(areaUpper)
		var/turf/topshaft = top.find_middle()
		if(topshaft && topshaft?.type == endTurfToLeave)
			location = 0
		else
			location = 1

/obj/machinery/computer/elevator/centcomm
	machine_registry_idx = MACHINES_ELEVATORCENTCOM
	areaLower = /area/shuttle/centcom_elevator/lower
	areaUpper = /area/shuttle/centcom_elevator/upper
	endTurfToLeave = /turf/unsimulated/floor/glassblock/transparent_cyan
	location = 0
	adminOnly = TRUE

/obj/machinery/computer/elevator/centcomm/hidden
	name = "toilet paper holder";
	desc = "a not at all suspicious toilet paper holder.";
	icon = 'icons/obj/decoration.dmi';
	icon_state = "toiletholder";

/obj/machinery/computer/elevator/ui_interact(mob/user, datum/tgui/ui)
	if (adminOnly && !isadmin(user))
		return

	ui = tgui_process.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Elevator", name)
		ui.open()

/obj/machinery/computer/elevator/ui_data(mob/user)
	. = list()
	.["location"] = location ? "Upper level" : "Lower Level"
	.["active"] = active

/obj/machinery/computer/elevator/attack_hand(mob/user)
	if (adminOnly && !isadmin(user))
		return
	if(..())
		return

	ui_interact(user)

/obj/machinery/computer/elevator/ui_act(action, params)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_interact_range(src, usr) && istype(src.loc, /turf))) || (issilicon(usr)))
		switch(action)
			if ("send")
				if (adminOnly)
					USR_ADMIN_ONLY
				if(!active)
					for(var/obj/machinery/computer/elevator/C in machine_registry[machine_registry_idx])
						C.active = 1
						C.visible_message(SPAN_ALERT("The elevator begins to move!"))
						playsound(C.loc, 'sound/machines/elevator_move.ogg', 100, 0)
						tgui_process.update_uis(C)
					SPAWN(5 SECONDS)
						call_shuttle()
					. = TRUE


/obj/machinery/computer/elevator/proc/call_shuttle()

	if(location == 0) // at bottom
		var/area/start_location = locate(areaLower)
		var/area/end_location = locate(areaUpper)
		start_location.move_contents_to(end_location, startTurfToLeave, ignore_fluid = TRUE)
		location = 1
	else // at top
		var/area/start_location = locate(areaUpper)
		var/area/end_location = locate(areaLower)
		for(var/mob/living/L in end_location) // oh dear, stay behind the yellow line kids
			if(!isintangible(L))
				SPAWN(1 DECI SECOND)
					logTheThing(LOG_COMBAT, L, "was gibbed by an elevator at [log_loc(L)].")
					L.gib()
				if (logBioeleAccident)
					bioele_accident()
		start_location.move_contents_to(end_location, endTurfToLeave, ignore_fluid = TRUE)
		location = 0

	for(var/obj/machinery/computer/elevator/C in machine_registry[machine_registry_idx])
		C.active = 0
		C.visible_message(SPAN_ALERT("The elevator has moved."))
		C.location = src.location
		tgui_process.update_uis(C)

/obj/sign_accidents
	name = "Elevator Safety Sign"
	icon = 'icons/obj/decals/wallsigns.dmi'
	icon_state = "accidents_sign"
	density = 0
	anchored = ANCHORED

	get_desc()
		return "It says \"[bioele_shifts_since_accident] shifts since the last elevator accident. ([bioele_accidents] accidents in total.)\"."

	attack_hand(mob/user)
		boutput(user, "The sign says \"[bioele_shifts_since_accident] shifts since the last elevator accident. ([bioele_accidents] accidents in total.)\".")

proc/bioele_load_stats()
	var/savefile/S = LoadSavefile("data/ElevatorStats.sav")
	if(!S)
		return
	var/accidents
	S["accidents"] >> accidents
	if(accidents)
		bioele_accidents = accidents
	var/shifts_since_accident
	S["shifts_since_accident"] >> shifts_since_accident
	if(shifts_since_accident)
		bioele_shifts_since_accident = shifts_since_accident

proc/bioele_save_stats()
	var/savefile/S = LoadSavefile("data/ElevatorStats.sav")
	if(!S)
		return
	S["accidents"] << bioele_accidents
	S["shifts_since_accident"] << bioele_shifts_since_accident

proc/bioele_accident()
	bioele_load_stats()
	bioele_accidents++
	bioele_shifts_since_accident = 0
	bioele_save_stats()

#undef MINING_OUTPOST_NAME
