// hack of the century
/obj/smes_spawner
	name = "power storage unit"
	icon = 'icons/obj/power.dmi'
	icon_state = "smes"
	density = 1
	anchored = ANCHORED
	New()
		..()
		SPAWN(1 SECOND)
			var/obj/term = new /obj/machinery/power/terminal(get_step(get_turf(src), dir))
			term.set_dir(get_dir(get_turf(term), src))
			new /obj/machinery/power/smes(get_turf(src))
			qdel(src)

/obj/ai_frame
	name = "\improper Asimov 5 Artifical Intelligence"
	desc = "An artificial intelligence unit which requires the brain of a living organism to function as a neural processor."
	icon = 'icons/mob/ai.dmi'
	icon_state = "ai"
	anchored = UNANCHORED
	density = 1
	opacity = 0

	var/processing = 0

	New()
		..()
		src.overlays += image('icons/mob/ai.dmi', "topopen")
		src.overlays += image('icons/mob/ai.dmi', "batterymode")

	attackby(var/obj/item/I, user)
		if (istype(I, /obj/item/organ/brain) && !processing)
			processing = 1
			var/valid = 0
			var/obj/item/organ/brain/B = I
			if(B.owner)
				if(B.owner.current)
					if(B.owner.current.client)
						valid = 1
			if (!valid)
				boutput(user, SPAN_ALERT("This brain doesn't look any good to use!"))
				processing = 0
				return
			var/mob/M = B.owner.current
			M.set_loc(get_turf(src))
			var/mob/living/silicon/ai/TheAI = M.AIize(0, 1)
			TheAI.set_loc(src)
			B.set_loc(TheAI)
			TheAI.brain = B
			TheAI.anchored = UNANCHORED
			TheAI.dismantle_stage = 3
			TheAI.update_appearance()
			qdel(src)
		else
			..()

/obj/machinery/turret/construction
	power_usage = 250
	var/obj/machinery/turretid/computer/control = null
	var/firesat = "humanoids"
	override_area_bullshit = 1

	process()
		if(status & BROKEN)
			return
		..()
		if(status & NOPOWER)
			return
		if(lastfired && world.time - lastfired < shot_delay)
			return
		lastfired = world.time
		if (src.cover==null)
			src.cover = new /obj/machinery/turretcover(src.loc)
		power_usage = 250
		var/list/targets = list()
		if (firesat == "humanoids")
			for (var/mob/living/carbon/M in view(5, src))
				if (!isdead(M))
					targets += M
		else if (firesat == "critters")
			for (var/obj/critter/C in view(5, src))
				if (C.alive)
					targets += C
		if (length(targets) > 0)
			if (!isPopping())
				if (isDown())
					popUp()
					power_usage = 750
				else
					var/target = pick(targets)
					src.set_dir(get_dir(src, target))
					if (src.enabled)
						power_usage = 750
						src.shootAt(target)

/obj/machinery/turretid/computer
	var/list/turrets = list()
	icon = 'icons/obj/computer.dmi'
	icon_state = "turret3"
	density = 1
	var/firesat = "humanoids"

	New()
		..()
		scan()

	proc/scan()
		for (var/obj/machinery/turret/construction/T in range(src, 7))
			if (!T.control && !(T in turrets))
				turrets += T
				T.control = src

	attack_hand(var/mob/user)
		if (!in_interact_range(src,user))
			boutput(user, text("Too far away."))
			src.remove_dialog(user)
			user.Browse(null, "window=turretid")
			return

		src.add_dialog(user)
		var/t = "<TT><B>Turret Control Panel</B><BR><B>Controlled turrets:</B> [turrets.len] (<A href='byond://?src=\ref[src];rescan=1'>Rescan</a>)<HR>"

		if(src.locked && !can_access_remotely(user))
			t += "<I>(Swipe ID card to unlock control panel.)</I><BR>"
		else
			t += text("Turrets [] - <A href='byond://?src=\ref[];toggleOn=1'>[]?</a><br><br>", src.enabled?"activated":"deactivated", src, src.enabled?"Disable":"Enable")
			t += text("Currently firing at <A href='byond://?src=\ref[];firesAt=1'>[]</a><br><br>", src, firesat)
			t += text("Currently set for [] - <A href='byond://?src=\ref[];toggleLethal=1'>Change to []?</a><br><br>", src.lethal?"lethal":"stun repeatedly", src,  src.lethal?"Stun repeatedly":"Lethal")

		user.Browse(t, "window=turretid")
		onclose(user, "turretid")


	Topic(href, href_list)
		if (src.locked)
			if (!can_access_remotely(usr))
				boutput(usr, "Control panel is locked!")
				return
		if (href_list["rescan"])
			scan()
		if (href_list["firesAt"])
			cycleFiresAt()
			updateFiresAt()
		..()

	proc/cycleFiresAt()
		if (!src.locked)
			switch (firesat)
				if ("humanoids")
					firesat = "critters"
				if ("critters")
					firesat = "humanoids"

	proc/updateFiresAt()
		for (var/obj/machinery/turret/construction/aTurret in turrets)
			aTurret.firesat = firesat

	updateTurrets()
		if (src.enabled)
			if (src.lethal)
				icon_state = "turret2"
			else
				icon_state = "turret3"
		else
			icon_state = "turret1"

		for (var/obj/machinery/turret/construction/aTurret in turrets)
			aTurret.setState(enabled, lethal)

TYPEINFO(/obj/item/room_marker)
	mats = 6

/obj/item/room_marker
	name = "\improper Room Designator"
	icon = 'icons/obj/construction.dmi'
	icon_state = "room"
	item_state = "gun"
	w_class = W_CLASS_SMALL

	var/using = 0

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob)
		var/area/A = get_area(target)
		if (!isturf(target))
			return
		if(!istype(A,/area/built_zone))
			boutput(user, SPAN_ALERT("This tool will only work on built zones!"))
			return
		if (using)
			boutput(user, SPAN_ALERT("Already validating a room. Please wait."))
			return
		using = 1
		boutput(user, SPAN_NOTICE("Validating room..."))
		SPAWN(0)
			var/list/tiles = identify_room(target)
			if (tiles)
				combine_areas(tiles)
				boutput(user, SPAN_NOTICE("Validation successful! Room designated."))
			else
				boutput(user, SPAN_ALERT("Validation failed!"))
			using = 0

	proc/combine_areas(var/list/room)
		var/area/TargA = new /area/built_zone()
		for (var/turf/T in room)
			var/area/A = get_area(T)
			if (A != TargA)
				if (istype(A,/area/built_zone))
					TargA.contents += T // steal the turf from the old

			if (A.area_apc) // steal the APCs
				var/obj/machinery/power/apc/Aapc = A.area_apc
				Aapc.area = TargA
				Aapc.name = "[TargA.name] APC"
				if (!TargA.area_apc)
					TargA.area_apc = Aapc

			for (var/obj/machinery/M in A.machines) // steal all the machines too
				A.machines -= M
				TargA.machines += M
				if (istype(M,/obj/machinery/light)) // steal all the lights
					A.remove_light(M)
					TargA.add_light(M)

			SPAWN(0.5 SECONDS) // apc code does this too
				if (TargA.area_apc)
					TargA.area_apc.update()

	proc/identify_room(var/turf/T) // stolen from what this was using before
		var/list/affected = list()
		var/list/next = list()
		var/list/processed = list()
		next += T
		processed += T
		while (next.len)
			var/turf/C = next[1]
			next -= C

			affected += C

			if (C.density)
				continue

			var/dense = 0
			for (var/obj/O in C)
				if (istype(O, /obj/machinery/door) || istype(O, /obj/mesh/grille) || istype(O, /obj/window) || istype(O, /obj/table))
					dense = 1
					break
			if (dense)
				continue

			if (istype(C, /turf/space) || istype(C, /turf/unsimulated)) // terrainify uses unsimmed turfs as space
				return null

			var/turf/N = get_step(C, NORTH)
			if (N && !(N in processed))
				next += N
				processed += N

			N = get_step(C, SOUTH)
			if (N && !(N in processed))
				next += N
				processed += N

			N = get_step(C, WEST)
			if (N && !(N in processed))
				next += N
				processed += N

			N = get_step(C, EAST)
			if (N && !(N in processed))
				next += N
				processed += N

		return affected

TYPEINFO(/obj/item/clothing/glasses/construction)
	mats = 6

/obj/item/clothing/glasses/construction
	name = "\improper Construction Visualizer"
	icon_state = "construction"
	item_state = "construction"
	desc = "The latest technology in viewing live blueprints."

/obj/item/lamp_manufacturer/organic
	icon = 'icons/obj/items/tools/lampman.dmi'
	desc = "A small manufacturing unit to produce and (re)place lamps in existing fittings. Load metal sheets before using."
	icon_state = "bio-white"
	flags = TABLEPASS | EXTRADELAY
	w_class = W_CLASS_SMALL
	click_delay = 1
	prefix = "bio"
	metal_ammo = 20
	inventory_counter_enabled = 1
	New()
		..()
		inventory_counter.update_number(metal_ammo)

TYPEINFO(/obj/item/material_shaper)
	mats = 6

/obj/item/material_shaper
	name = "\improper Window Planner"
	icon = 'icons/obj/construction.dmi'
	icon_state = "shaper"
	item_state = "gun"
	flags = TABLEPASS | EXTRADELAY
	click_delay = 1

	var/mode = 0
	var/datum/material/metal = null
	var/metal_count = 0
	var/datum/material/glass = null
	var/glass_count = 0

	var/processing = 0

	w_class = W_CLASS_SMALL

	var/sound/sound_process = sound('sound/effects/pop.ogg')
	var/sound/sound_grump = sound('sound/machines/buzz-two.ogg')

	proc/determine_material(var/obj/item/material_piece/D, mob/user as mob)
		var/datum/material/DM = D.material
		var/which = null
		if ((DM.getMaterialFlags() & MATERIAL_METAL) && (DM.getMaterialFlags() & MATERIAL_CRYSTAL))
			var/be_metal = 0
			var/be_glass = 0
			if (!metal)
				be_metal = 1
			else if (metal.isSameMaterial(DM))
				be_metal = 1
			if (!glass)
				be_glass = 1
			else if (glass.isSameMaterial(DM))
				be_glass = 1
			if (be_metal && be_glass)
				which = input("Use [D] as?", "Pick", null) in list("metal", "glass")
			else if (be_metal)
				which = "metal"
			else if (be_glass)
				which = "glass"
			else
				playsound(src.loc, sound_grump, 40, 1)
				boutput(user, SPAN_ALERT("[D] incompatible with current metal or glass."))
				return null
		else if (DM.getMaterialFlags() & MATERIAL_METAL)
			if (!metal)
				which = "metal"
			else if (metal.isSameMaterial(DM))
				which = "metal"
			else
				playsound(src.loc, sound_grump, 40, 1)
				boutput(user, SPAN_ALERT("[D] incompatible with current metal."))
				return null
		else if (DM.getMaterialFlags() & MATERIAL_CRYSTAL)
			if (!glass)
				which = "glass"
			else if (glass.isSameMaterial(DM))
				which = "glass"
			else
				playsound(src.loc, sound_grump, 40, 1)
				boutput(user, SPAN_ALERT("[D] incompatible with current glass."))
				return null
		else
			playsound(src.loc, sound_grump, 40, 1)
			boutput(user, SPAN_ALERT("[D] is not a metal or glass material."))
		if (!which)
			playsound(src.loc, sound_grump, 40, 1)
			boutput(user, SPAN_ALERT("[D] is not a metal or glass material."))

		if (which == "metal" && !metal)
			metal = DM
		else if (which == "glass" && !glass)
			glass = DM

		return which

	proc/has_materials(var/metalc, var/glassc)
		if (metal_count < metalc || glass_count < glassc)
			return 0
		return 1

	proc/use_materials(var/metalc, var/glassc)
		metal_count -= metalc
		glass_count -= glassc
		if (metal_count <= 0)
			metal = null
		if (glass_count <= 0)
			glass = null
		boutput(usr, SPAN_NOTICE("The shaper has [metal_count] units of metal and [glass_count] units of glass left."))

	examine()
		. = ..()
		if (metal)
			. += SPAN_NOTICE("Metal: [metal_count] units of [metal.getName()].")
		else
			. += SPAN_ALERT("Metal: 0 units.")

		if (glass)
			. += SPAN_NOTICE("Glass: [glass_count] units of [glass.getName()].")
		else
			. += SPAN_ALERT("Glass: 0 units")

	attack_self(mob/user as mob)
		mode = !mode
		if (!mode)
			boutput(user, SPAN_NOTICE("Mode: marking/unmarking plans for grille and glass structures."))
		else
			boutput(user, SPAN_NOTICE("Mode: constructing planned grille and glass structures."))

	attackby(var/obj/item/W, mob/user as mob)
		if (W.disposed)
			return
		if (istype(W, /obj/item/material_piece))
			var/obj/item/material_piece/D = W
			var/which = determine_material(D, user)
			if (which == "metal")
				qdel(W)
				metal_count += 10
			else if (which == "glass")
				qdel(W)
				glass_count += 10
			else
				return

	pixelaction(atom/target, params, mob/user)
		if (mode)
			return 0
		var/turf/T = target
		if (!istype(T))
			T = get_turf(T)
		if (!T)
			return 0

		var/obj/plan_marker/glass_shaper/old = locate() in T
		if (old)
			old.cancelled()
		else
			new /obj/plan_marker/glass_shaper(T)

		boutput(user, SPAN_NOTICE("Done."))
		return 1

	MouseDrop_T(var/obj/over_object, mob/user as mob)
		if (processing)
			return
		processing = 1
		var/procloc = user.loc
		if (!istype(over_object))
			processing = 0
			return
		if (!istype(over_object.loc, /turf))
			processing = 0
			return
		if (istype(over_object, /obj/item/material_piece))
			var/obj/item/material_piece/D = over_object
			if (!D.material)
				playsound(src.loc, sound_grump, 40, 1)
				boutput(user, SPAN_ALERT("That does not have a usable material."))
				return

			var/which = determine_material(D, user)
			if (!which)
				processing = 0
				return
			var/datum/material/DM = null
			if (which == "metal")
				DM = metal
			else if (which == "glass")
				DM = glass
			else
				processing = 0
				return

			user.visible_message(SPAN_NOTICE("[user] begins stuffing materials into [src]."))

			for (var/obj/item/material_piece/M in over_object.loc)
				if (user.loc != procloc)
					break
				var/datum/material/MT = M.material
				if (!MT)
					continue
				if (MT.isSameMaterial(DM))
					playsound(src.loc, sound_process, 40, 1)
					if (which == "metal")
						metal_count += 10
					else
						glass_count += 10
					qdel(M)
					sleep(0.1 SECONDS)
			processing = 0
			user.visible_message(SPAN_NOTICE("[user] finishes stuffing materials into [src]."))

#define ROOM_PLANNER_FLOORS "floors"
#define ROOM_PLANNER_WALLS "walls"
#define ROOM_PLANNER_RESTORE "restore original"
#define ROOM_PLANNER_CHARGES_PER_MATERIAL 20

TYPEINFO(/obj/item/room_planner)
	mats = 6

/obj/item/room_planner
	name = "\improper Floor and Wall Designer"
	icon = 'icons/obj/construction.dmi'
	icon_state = "plan"
	item_state = "gun"
	flags = TABLEPASS | EXTRADELAY
	w_class = W_CLASS_SMALL
	click_delay = 1
	inventory_counter_enabled = TRUE

	var/selecting = 0
	var/mode = null
	var/icons = list(ROOM_PLANNER_FLOORS, ROOM_PLANNER_WALLS, ROOM_PLANNER_RESTORE)
	var/marker_class = list(ROOM_PLANNER_FLOORS = /obj/plan_marker/floor, ROOM_PLANNER_WALLS = /obj/plan_marker/wall)
	/// icon file selected
	var/selectedicon
	/// iconstate selected
	var/selectedtype
	/// mod to use for generating smoothwalls
	var/selectedmod
	// var/pod_turf = 0
	var/turf_op = 0
	/// how many tiles it can convert
	var/charges = 100
	/// maximum amount of stored "ammo"
	var/max_charges = 1000

	var/list/wallicons = list(
		"diner" = 'icons/turf/walls/derelict.dmi',
		"martian" = 'icons/turf/walls/martian.dmi',
		"shuttle blue" = 'icons/turf/walls/shuttle/blue.dmi',
		"shuttle white" = 'icons/turf/walls/shuttle/white.dmi',
		"shuttle dark" = 'icons/turf/walls/shuttle/dark.dmi',
		"overgrown" = 'icons/turf/walls/overgrown.dmi',
		"meat" = 'icons/turf/walls/meat/meatier.dmi',
		"ancient" = 'icons/turf/walls/ancient.dmi',
		"cave" = 'icons/turf/walls/cave.dmi',
		"lead blue" = 'icons/turf/walls/lead/blue.dmi',
		"lead gray" = 'icons/turf/walls/lead/gray.dmi',
		"lead white" = 'icons/turf/walls/lead/white.dmi',
		"ancient smooth" = 'icons/turf/walls/ancient_smooth.dmi',
		"tempus green" = 'icons/turf/walls/unused/walls_tempus-green.dmi',
		"tempus white" = 'icons/turf/walls/unused/walls_tempus-white.dmi',
		"black red" = 'icons/turf/walls/supernorn/blackred.dmi',
		"orange" = 'icons/turf/walls/supernorn/orange.dmi',
		"yellow" = 'icons/turf/walls/supernorn/yellow.dmi',
		"beehive" = 'icons/turf/walls/beehive.dmi',
		"hedge" = 'icons/turf/walls/hedge.dmi',
		"ice" = 'icons/turf/walls/ice.dmi',
		"mossy rock" = 'icons/turf/walls/mossy_rock.dmi',
		"panel" = 'icons/turf/walls/panel.dmi',
		"marsoutpost" = 'icons/turf/walls/marsoutpost.dmi',
		"precursor" = 'icons/turf/walls/precursor.dmi',

	)
	var/list/wallmods = list(
		"diner" = "oldr-",
		"martian" = "martian-",
		"shuttle blue" = "",
		"shuttle white" = "shuttle-",
		"shuttle dark" = "dshuttle-",
		"overgrown" = "root-",
		"meat" = "meatier-",
		"ancient" = "ancient-",
		"cave" = "cave-",
		"lead blue" = "leadb-",
		"lead gray" = "leadg-",
		"lead white" = "leadw-",
		"ancient smooth" = "interior-",
		"tempus green" = "",
		"tempus white" = "",
		"black red" = "norn-BR-",
		"orange" = "norn-O-",
		"yellow" = "norn-Y-",
		"beehive" = "bee-",
		"hedge" = "hedge-",
		"ice" = "ice-",
		"mossy rock" = "rock-",
		"panel" = "interior-",
		"marsoutpost" = "interior-",
		"precursor" = "interior-",

	)

	HELP_MESSAGE_OVERRIDE("You can recharge the Floor and Wall Designer with processed cloth materials.")

	New()
		. = ..()
		src.inventory_counter.update_number(src.charges)

	attackby(obj/item/I, mob/user, params)
		if (istype(I, /obj/item/material_piece) && (I.material.getMaterialFlags() & MATERIAL_CLOTH))
			if(src.charges + ROOM_PLANNER_CHARGES_PER_MATERIAL > src.max_charges)
				boutput(user, SPAN_NOTICE("\The [src] refuses \the [I.material.getName()] as it is too full."))
				return
			src.charges += ROOM_PLANNER_CHARGES_PER_MATERIAL
			src.inventory_counter.update_number(src.charges)
			boutput(user, SPAN_NOTICE("You load \an [I.material.getName()] into \the [src]. It has [src.charges] remaining charges."), "designer-reload")
			I.change_stack_amount(-1)
			user.playsound_local(loc, 'sound/machines/paper_shredder.ogg', 30, 1)
			return
		. = ..()

	attack_self(mob/user as mob)
		// This seems to not actually stop anything from working so just axing it.
		//if (!(ticker?.mode && istype(ticker.mode, /datum/game_mode/construction)))
		//	boutput(user, SPAN_ALERT("You can only use this tool in construction mode."))

		if (selecting)
			return

		selecting = 1

		// mode selection for floor planner
		mode = tgui_input_list(message="What to mark?", title="Marking", items=icons)
		if(!mode)
			mode = ROOM_PLANNER_FLOORS
		var/states = list()
		if (mode == ROOM_PLANNER_RESTORE)
			boutput(user, SPAN_NOTICE("Now set for restoring appearance."))
			selecting = 0
			return

		// icon selection
		// selectedicon is the file we selected
		// selectedtype gets used as our iconstate for floors or the key to the lists for walls
		if (mode == ROOM_PLANNER_FLOORS)
			selectedtype = null
			states += (get_icon_states('icons/turf/construction_floors.dmi') - list("engine", "catwalk", "catwalk_narrow", "catwalk_cross"))
			selectedicon = 'icons/turf/construction_floors.dmi'
			var/newtype = tgui_input_list(message="What kind?", title="Marking", items=states)
			if(newtype)
				selectedtype = newtype

		if (mode == ROOM_PLANNER_WALLS)
			selectedtype = null
			selectedicon = null
			selectedmod = null
			states += wallicons
			var/newtype = tgui_input_list(message="What kind?", title="Marking", items=states)
			if(newtype)
				selectedtype = newtype
				selectedicon = wallicons[selectedtype]
				selectedmod = wallmods[selectedtype]

		if (isnull(selectedtype))
			selecting = 0
			return

		if (mode == ROOM_PLANNER_FLOORS || (mode == ROOM_PLANNER_WALLS && findtext(selectedtype, "window") != 0))
			turf_op = 0
		else
			turf_op = 1

		boutput(user, SPAN_NOTICE("Now marking plan for [mode] of type '[selectedtype]'."))
		selecting = 0

	pixelaction(atom/target, params, mob/user)
		var/turf/T = target
		if (!istype(T))
			T = get_turf(T)
		if (!T || !mode)
			return 0
		if (GET_DIST(T, user) > 3)
			return 0

		if (mode == ROOM_PLANNER_RESTORE) //For those who want to undo the carnage
			if (istype(T, /turf/simulated/floor))
				if (!T.intact)
					return
				var/turf/simulated/floor/F = T
				F.icon = initial(F.icon)
				F.icon_state = F.roundstart_icon_state
				F.set_dir(F.roundstart_dir)
			else if (istype(T, /turf/simulated/wall))
				T.icon = initial(T.icon)
				//T.icon_state = initial(T.icon_state)
				if (istype(T, /turf/simulated/wall/auto))
					var/turf/simulated/wall/auto/W = T
					W.mod = W::mod
					W.UpdateIcon()
					W.update_neighbors()
			return

		if (src.charges <= 0)
			boutput(user, SPAN_ALERT("\The [src] requires more cloth to continue decorating!"))
			user.playsound_local(src, 'sound/machines/buzz-sigh.ogg', 40, 1)
			return

		var/obj/plan_marker/old = null
		for (var/obj/plan_marker/K in T)
			if (istype(K, /obj/plan_marker/floor) || istype(K, /obj/plan_marker/wall))
				old = K
				break
		if (old)
			old.Attackby(src, user)
			src.charges -= 1
		else if (!isnull(selectedtype))
			if (iswall(T) && mode != ROOM_PLANNER_WALLS)
				boutput(user, SPAN_NOTICE("Currently in [mode] mode, cannot change walls."))
				return
			if (isfloor(T) && mode != ROOM_PLANNER_FLOORS)
				boutput(user, SPAN_NOTICE("Currently in [mode] mode, cannot change floors."))
				return
			var/class = marker_class[mode]
			src.charges -= 1
			old = new class(T, selectedicon, selectedtype, mode)
			old.set_dir(get_dir(user, T))
			old.turf_op = turf_op
			old:check(selectedmod)
		else
			boutput(user, SPAN_ALERT("No type selected for current mode!"))
			return 0
		src.inventory_counter.update_number(src.charges)
		return 1

#undef ROOM_PLANNER_FLOORS
#undef ROOM_PLANNER_WALLS
#undef ROOM_PLANNER_RESTORE
#undef ROOM_PLANNER_CHARGES_PER_MATERIAL

/obj/plan_marker
	name = "\improper Plan Marker"
	icon = 'icons/turf/construction_walls.dmi'
	icon_state = null
	anchored = ANCHORED
	density = 0
	opacity = 0
	invisibility = INVIS_CONSTRUCTION
	var/allows_vehicles = 0
	var/turf_op = 1

	alpha = 128

	New(var/initial_loc, var/initial_icon, var/selectedtype, var/mode)
		..()
		color = rgb(0, 255, 0)
		icon = initial_icon
		if(mode == "floors")
			icon_state = selectedtype

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/room_planner))
			qdel(src)
			return
		var/turf/T = get_turf(src)
		if (T)
			T.Attackby(W, user)
			W.AfterAttack(T, user)

/obj/plan_marker/glass_shaper
	name = "\improper Window Plan Marker"
	icon = 'icons/obj/grille.dmi'
	icon_state = "grille-0"
	anchored = ANCHORED
	density = 0
	opacity = 0
	invisibility = INVIS_CONSTRUCTION

	var/static/image/wE = null
	var/static/image/wW = null
	var/static/image/wN = null
	var/static/image/wS = null

	var/bmask = 15
	var/borders = 4

	var/filling = 0

	alpha = 128

	New(var/initial_loc)
		..()
		color = rgb(255, 0, 0)
		calculate_orientation(1)

		if (!wE)
			wE = image('icons/obj/construction.dmi', "plan_window_e")
		if (!wW)
			wW = image('icons/obj/construction.dmi', "plan_window_w")
		if (!wN)
			wN = image('icons/obj/construction.dmi', "plan_window_n")
		if (!wS)
			wS = image('icons/obj/construction.dmi', "plan_window_s")

		icon_state = "grille-0"

	proc/calculate_orientation(var/recurse = 0)
		var/borders_mask = 15
		var/gcount = 4
		var/turf/N = locate(x, y + 1, 1)
		var/turf/S = locate(x, y - 1, 1)
		var/turf/W = locate(x - 1, y, 1)
		var/turf/E = locate(x + 1, y, 1)
		if (N)
			var/obj/plan_marker/glass_shaper/G = locate() in N
			if (G)
				borders_mask -= 1
				gcount--
				if (recurse)
					G.calculate_orientation(0)
			else
				var/obj/mesh/grille/Gr = locate() in N
				if (Gr)
					borders_mask -= 1
					gcount--
		if (S)
			var/obj/plan_marker/glass_shaper/G = locate() in S
			if (G)
				borders_mask -= 2
				gcount--
				if (recurse)
					G.calculate_orientation(0)
			else
				var/obj/mesh/grille/Gr = locate() in S
				if (Gr)
					borders_mask -= 2
					gcount--
		if (E)
			var/obj/plan_marker/glass_shaper/G = locate() in E
			if (G)
				borders_mask -= 4
				gcount--
				if (recurse)
					G.calculate_orientation(0)
			else
				var/obj/mesh/grille/Gr = locate() in E
				if (Gr)
					borders_mask -= 4
					gcount--
		if (W)
			var/obj/plan_marker/glass_shaper/G = locate() in W
			if (G)
				borders_mask -= 8
				gcount--
				if (recurse)
					G.calculate_orientation(0)
			else
				var/obj/mesh/grille/Gr = locate() in W
				if (Gr)
					borders_mask -= 8
					gcount--

		bmask = borders_mask
		borders = gcount
		overlays.len = 0
		if (borders_mask & 1)
			overlays += wN
		if (borders_mask & 2)
			overlays += wS
		if (borders_mask & 4)
			overlays += wE
		if (borders_mask & 8)
			overlays += wW

	proc/spawn_in(var/obj/item/material_shaper/origin)
		if (filling)
			return
		filling = 1
		if (!isturf(src.loc))
			filling = 0
			return
		var/turf/T = src.loc
		if (T.density)
			boutput(usr, SPAN_ALERT("Cannot complete material shaping: plan inside dense turf."))
			filling = 0
			return
		else
			for (var/atom/movable/O in T)
				if ((istype(O, /obj) && O.density) || isliving(O))
					boutput(usr, SPAN_ALERT("Cannot complete material shaping: [O] blocking construction."))
					filling = 0
					return
		var/datum/material/metal = origin.metal
		var/datum/material/glass = origin.glass
		var/turf/L = get_turf(src)
		if (!metal)
			metal = getMaterial("steel")
		if (!glass)
			glass = getMaterial("glass")

		origin.use_materials(2, borders)

		var/obj/mesh/grille/G = new /obj/mesh/grille(L)
		G.setMaterial(metal)

		var/mask = bmask
		if (mask & NORTH)
			var/obj/window/reinforced/W = new /obj/window/reinforced(L)
			W.set_dir(NORTH)
			W.setMaterial(glass)

		if (mask & SOUTH)
			var/obj/window/reinforced/W = new /obj/window/reinforced(L)
			W.set_dir(SOUTH)
			W.setMaterial(glass)

		if (mask & EAST)
			var/obj/window/reinforced/W = new /obj/window/reinforced(L)
			W.set_dir(EAST)
			W.setMaterial(glass)

		if (mask & WEST)
			var/obj/window/reinforced/W = new /obj/window/reinforced(L)
			W.set_dir(WEST)
			W.setMaterial(glass)
		qdel(src)

	proc/cancelled()
		var/turf/N = locate(x, y + 1, 1)
		var/turf/S = locate(x, y - 1, 1)
		var/turf/W = locate(x - 1, y, 1)
		var/turf/E = locate(x + 1, y, 1)
		if (N)
			var/obj/plan_marker/glass_shaper/G = locate() in N
			if (G)
				G.calculate_orientation(0)
		if (S)
			var/obj/plan_marker/glass_shaper/G = locate() in S
			if (G)
				G.calculate_orientation(0)
		if (E)
			var/obj/plan_marker/glass_shaper/G = locate() in E
			if (G)
				G.calculate_orientation(0)
		if (W)
			var/obj/plan_marker/glass_shaper/G = locate() in W
			if (G)
				G.calculate_orientation(0)

		qdel(src)

	proc/handle_shaper(var/obj/item/material_shaper/W)
		if (!W:mode)
			cancelled()
		else
			if (W:has_materials(2, borders))
				spawn_in(W)
			else
				boutput(usr, SPAN_ALERT("Insufficient materials -- requires 2 metal and [borders] glass."))

	attackby(obj/item/W, mob/user)
		if (istype(W, /obj/item/material_shaper))
			handle_shaper(W)
		else
			..()

/obj/plan_marker/wall
	name = "\improper Wall Plan Marker"
	desc = "Build a wall here to complete the plan."

	proc/check(var/selectedmod)
		var/turf/T = get_turf(src)
		// Originally worked only on this type specifically.
		// Which meant it didn't work with the fancy new auto-walls

		// this has been reworked to use auto walls that i resprited a while back.
		if (istype(T, /turf/simulated/wall/auto))
			var/typeinfo/turf/simulated/wall/auto/typinfo = get_type_typeinfo(T.type)
			var/connectdir = get_connected_directions_bitflag(typinfo.connects_to, typinfo.connects_to_exceptions, TRUE, typinfo.connect_diagonal)
			var/turf/simulated/wall/auto/AT = T
			AT.icon = src.icon
			AT.icon_state = "[selectedmod][connectdir]"
			AT.mod = selectedmod

			qdel(src)

/obj/plan_marker/floor
	name = "\improper Floor Plan Marker"
	desc = "Build a floor here to complete the plan."
	icon = 'icons/turf/construction_floors.dmi'

	proc/check()
		var/turf/T = get_turf(src)
		if (istype(T, /turf/simulated/floor) && T.intact)
			// Same deal as above, only checked for that specific type of floor
			// so the various alternate designs weren't able to be converted
			T.icon = src.icon
			T.icon_state = src.icon_state
			T.set_dir(src.dir)
			// T:allows_vehicles = src.allows_vehicles
		qdel(src)
