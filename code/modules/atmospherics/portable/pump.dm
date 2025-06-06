TYPEINFO(/obj/machinery/portable_atmospherics/pump)
	mats = 12

/obj/machinery/portable_atmospherics/pump
	name = "Portable Air Pump"

	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "psiphon-off"
	dir = NORTH //so it spawns with the fan side showing
	density = 1
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH | DECON_WELDER
	var/on = FALSE
	var/direction_out = 0 //0 = siphoning, 1 = releasing
	var/target_pressure = 100
	var/image/tank_hatch
	var/absorbing_bubble = FALSE

	desc = "A device which can siphon or release gasses."
	custom_suicide = 1

	volume = 750

	New()
		..()
		tank_hatch = image('icons/obj/atmospherics/atmos.dmi', "")

/obj/machinery/portable_atmospherics/pump/update_icon()
	if(on)
		icon_state = "psiphon-on"

		animate(src, pixel_x = 2, easing = SINE_EASING, loop=-1, time = 0.5 SECONDS)
		animate(pixel_x = -2, easing = SINE_EASING, loop=-1, time = 0.5 SECONDS)
	else
		icon_state = "psiphon-off"
		animate(src)
		pixel_x = 0

	if (holding)
		tank_hatch.icon_state = "psiphon-T-overlay"
	else
		tank_hatch.icon_state = ""
	src.AddOverlays(tank_hatch, "tankhatch")


/obj/machinery/portable_atmospherics/pump/process()
	..()
	if (!loc) return
	if (src.contained) return
	if (src.absorbing_bubble)
		return

	var/datum/gas_mixture/environment
	if(holding)
		environment = holding.air_contents
	else
		environment = loc.return_air()


	if(on)
		if(direction_out)
			var/pressure_delta = target_pressure - MIXTURE_PRESSURE(environment)
			//Can not have a pressure delta that would cause environment pressure > tank pressure

			var/transfer_moles = 0
			if(air_contents.temperature > 0)
				transfer_moles = pressure_delta*environment.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)

				//Actually transfer the gas
				var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

				if(holding)
					environment.merge(removed)
				else
					loc.assume_air(removed)
		else
			var/pressure_delta = target_pressure - MIXTURE_PRESSURE(air_contents)
			//Can not have a pressure delta that would cause environment pressure > tank pressure

			var/transfer_moles = 0
			if(environment.temperature > 0)
				transfer_moles = pressure_delta*air_contents.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

				//Actually transfer the gas
				var/datum/gas_mixture/removed
				if(holding)
					removed = environment.remove(transfer_moles)
				else
					removed = loc.remove_air(transfer_moles)

				air_contents.merge(removed)

		src.updateDialog()
	src.UpdateIcon()
	return

/obj/machinery/portable_atmospherics/pump/return_air(direct = FALSE)
	return air_contents

/obj/machinery/portable_atmospherics/pump/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/atmosporter))
		var/obj/item/atmosporter/porter = W
		if (length(porter.contents) >= porter.capacity) boutput(user, SPAN_ALERT("Your [W] is full!"))
		else if (src.anchored) boutput(user, SPAN_ALERT("\The [src] is attached!"))
		else
			user.visible_message(SPAN_NOTICE("[user] collects the [src]."), SPAN_NOTICE("You collect the [src]."))
			src.contained = 1
			src.set_loc(W)
			elecflash(user)
	..()

/obj/machinery/portable_atmospherics/pump/attack_ai(var/mob/user as mob)
	if(!src.connected_port && GET_DIST(src, user) > 7)
		return
	return src.Attackhand(user)

/obj/machinery/portable_atmospherics/pump/proc/turn_on()
	src.on = TRUE
	src.AddComponent(/datum/component/bubble_absorb, src.air_contents)
	src.UpdateIcon()

/obj/machinery/portable_atmospherics/pump/proc/turn_off()
	src.on = FALSE
	src.RemoveComponentsOfType(/datum/component/bubble_absorb)
	src.UpdateIcon()

/obj/machinery/portable_atmospherics/pump/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "PortablePump", name)
		ui.open()

/obj/machinery/portable_atmospherics/pump/ui_data(mob/user)
	. = list(
		"pressure" = MIXTURE_PRESSURE(src.air_contents),
		"on" = src.on,
		"connected" = !!src.connected_port,
		"targetPressure" = src.target_pressure,
		"direction_out" = src.direction_out
	)

	.["holding"] = src.holding?.ui_describe()

/obj/machinery/portable_atmospherics/pump/ui_static_data(mob/user)
	. = list(
		"minRelease" = 0,
		"maxRelease" = 10 * ONE_ATMOSPHERE,
		"maxPressure" = src.maximum_pressure
	)

/obj/machinery/portable_atmospherics/pump/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle-power")
			if (src.on)
				src.turn_off()
			else
				src.turn_on()
			. = TRUE
		if("toggle-pump")
			src.direction_out = !src.direction_out
			. = TRUE
		if("set-pressure")
			var/new_target_pressure = params["targetPressure"]
			if(isnum(new_target_pressure))
				src.target_pressure = clamp(new_target_pressure, 0, 10*ONE_ATMOSPHERE)
				. = TRUE
		if("eject-tank")
			src.eject_tank()
			src.turn_off()
			. = TRUE

/obj/machinery/portable_atmospherics/pump/suicide(var/mob/living/carbon/human/user)
	if (!istype(user) || !src.user_can_suicide(user))
		return 0

	if (!on) //Can't chop your head off if the fan's not spinning
		src.turn_on()

	user.visible_message(SPAN_ALERT("<b>[user] forces [his_or_her(user)] head into [src]'s unprotected fan, mangling it in a horrific and violent display!</b>"))
	var/obj/head = user.organHolder.drop_organ("head")
	qdel(head)
	playsound(src.loc, 'sound/impact_sounds/Flesh_Tear_2.ogg', 50, 1)
	var/turf/T = get_turf(user.loc)
	if (user.blood_id)
		T.fluid_react_single(user.blood_id, 20, airborne = 1)
	else
		T.fluid_react_single("blood", 20, airborne = 1)

	for (var/mob/living/carbon/human/V in oviewers(user, null))
		if (prob(50))
			V.show_message(SPAN_ALERT("Oh fuck, that's going to leave a mark on your psyche."), 1)
			V.nauseate(rand(7,10))
	if (user) //ZeWaka: Fix for null.loc
		health_update_queue |= user
	SPAWN(50 SECONDS)
		if (user && !isdead(user))
			user.suiciding = 0
	return 1
