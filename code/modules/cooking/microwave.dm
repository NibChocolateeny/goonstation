#define MW_COOK_VALID_RECIPE 1
#define MW_COOK_BREAK 2
#define MW_COOK_EGG 3
#define MW_COOK_DIRTY 4
#define MW_COOK_EMPTY 5
#define MW_COOK_WARM 6

#define MW_STATE_WORKING 0
#define MW_STATE_BROKEN_1 1
#define MW_STATE_BROKEN_2 2

TYPEINFO(/obj/machinery/microwave)
	mats = 12

/obj/machinery/microwave
	name = "Microwave"
	icon = 'icons/obj/kitchen.dmi'
	desc = "The automatic chef of the future!"
	icon_state = "mw"
	density = 1
	anchored = ANCHORED
	/// Current number of eggs inside the microwave
	var/egg_amount = 0
	/// Current amount of flour inside the microwave
	var/flour_amount = 0
	/// Current amount of water inside the microwave
	var/water_amount = 0
	/// Current total of monkey meat inside the microwave
	var/monkeymeat_amount = 0
	/// Current total of synth meat inside the microwave
	var/synthmeat_amount = 0
	/// Current total of human meat inside the microwave
	var/humanmeat_amount = 0
	/// Current total of donk pockets inside the microwave
	var/donkpocket_amount = 0
	/// Stored name of human meat for cooked recipe
	var/humanmeat_name = ""
	/// Stored job of human meat for cooked recipe
	var/humanmeat_job = ""
	/// Microwave is currently running
	var/operating = FALSE
	/// If dirty the microwave cannot be used until cleaned
	var/dirty = FALSE
	/// Microwave damage, cannot be used until repaired
	var/microwave_state = MW_STATE_WORKING
	/// The time to wait before spawning the item
	var/cook_time = 20 SECONDS
	/// List of the recipes the microwave will check
	var/list/available_recipes = list()
	/// The current recipe being cooked
	var/datum/recipe/cooked_recipe = null
	/// The item to create when finished cooking
	var/obj/item/reagent_containers/food/snacks/being_cooked = null
	/// Single non food item that can be added to the microwave
	var/obj/item/extra_item
	object_flags = NO_BLOCK_TABLE
	deconstruct_flags = DECON_SCREWDRIVER | DECON_WRENCH
	var/emagged = FALSE

	HELP_MESSAGE_OVERRIDE("Place items inside by clicking, then click the microwave with an open hand to open cooking menu.")

	emag_act(var/mob/user, var/obj/item/card/emag/E)
		if (!src.emagged)
			if (user)
				user.show_text("You use the card to change the internal radiation setting to \"IONIZING\"", "blue")
			src.emagged = TRUE
			return TRUE
		else
			if (user)
				user.show_text("The [src] has already been tampered with", "red")

	demag(var/mob/user)
		if (!src.emagged)
			return 0
		if (user)
			user.show_text("You reset the radiation levels to a more food-safe setting.", "blue")
		src.emagged = FALSE
		return TRUE

/obj/machinery/microwave/get_help_message(dist, mob/user)
	if(src.status & BROKEN)
		if(src.microwave_state == MW_STATE_BROKEN_2)
			return "The microwave is broken! Use a <b>screwing tool</b> to begin repairing."
		if(src.microwave_state == MW_STATE_BROKEN_1)
			return "The microwave is broken! Use a <b>wrenching tool</b> to finish repairing."
	if (src.dirty)
		return "The microwave is dirty! Use a <b>sponge</b> or <b>spray bottle</b> to clean it up."
	return "Place items inside, then click the microwave with an open hand to open the cooking controls."

/// After making the recipe in datums\recipes.dm, add it in here!
/obj/machinery/microwave/New()
	..()
	src.available_recipes += new /datum/recipe/donut(src)
	src.available_recipes += new /datum/recipe/synthburger(src)
	src.available_recipes += new /datum/recipe/monkeyburger(src)
	src.available_recipes += new /datum/recipe/humanburger(src)
	src.available_recipes += new /datum/recipe/waffles(src)
	src.available_recipes += new /datum/recipe/brainburger(src)
	src.available_recipes += new /datum/recipe/meatball(src)
	src.available_recipes += new /datum/recipe/buttburger(src)
	src.available_recipes += new /datum/recipe/roburger(src)
	src.available_recipes += new /datum/recipe/heartburger(src)
	src.available_recipes += new /datum/recipe/donkpocket(src)
	src.available_recipes += new /datum/recipe/donkpocket_warm(src)
	src.available_recipes += new /datum/recipe/pie(src)
	src.available_recipes += new /datum/recipe/popcorn(src)
	UnsubscribeProcess()

/**
	*  Item Adding
	*/

/obj/machinery/microwave/attackby(var/obj/item/O, var/mob/user)
	if(src.operating)
		return
	if(src.microwave_state > 0)
		if (isscrewingtool(O) && src.microwave_state == MW_STATE_BROKEN_2)
			src.visible_message(SPAN_NOTICE("[user] starts to fix part of the microwave."))
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/repair, list(user), 'icons/obj/items/tools/screwdriver.dmi', "screwdriver", "", null)
		else if (src.microwave_state == MW_STATE_BROKEN_1 && iswrenchingtool(O))
			src.visible_message(SPAN_NOTICE("[user] starts to fix part of the microwave."))
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/repair, list(user), 'icons/obj/items/tools/wrench.dmi', "wrench", "", null)
		else
			boutput(user, "It's broken! It could be fixed with some common tools.")
			return
	else if(src.dirty) // The microwave is all dirty so can't be used!
		if(istype(O, /obj/item/spraybottle))
			src.visible_message(SPAN_NOTICE("[user] starts to clean the microwave."))
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/clean, list(user), 'icons/obj/janitor.dmi', "cleaner", "", null)

		else if(istype(O, /obj/item/sponge))
			SETUP_GENERIC_ACTIONBAR(user, src, 2 SECONDS, /obj/machinery/microwave/proc/clean, list(user), 'icons/obj/janitor.dmi', "sponge", "", null)

		else //Otherwise bad luck!!
			boutput(user, "It's dirty! It could be cleaned with a sponge or spray bottle")
			return
	else if (O.cant_drop) //For borg held items, if the microwave is clean and functioning
		boutput(user, SPAN_ALERT("You can't put that in [src] when it's attached to you!"))
	else if (isghostdrone(user))
		boutput(user, SPAN_ALERT("\The [src] refuses to interface with you, as you are not a properly trained chef!"))
		return
	else if(istype(O, /obj/item/card/emag))
		return
	else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/egg)) // If an egg is used, add it
		if(src.egg_amount < 5)
			src.visible_message(SPAN_NOTICE("[user] adds an egg to the microwave."))
			src.egg_amount++
			user.u_equip(O)
			O.set_loc(src)
	else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/flour)) // If flour is used, add it
		if(src.flour_amount < 5)
			src.visible_message(SPAN_NOTICE("[user] adds some flour to the microwave."))
			src.flour_amount++
			user.u_equip(O)
			O.set_loc(src)
	else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat))
		if(src.monkeymeat_amount < 5)
			src.visible_message(SPAN_NOTICE("[user] adds some meat to the microwave."))
			src.monkeymeat_amount++
			user.u_equip(O)
			O.set_loc(src)
	else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat))
		if(src.synthmeat_amount < 5)
			src.visible_message(SPAN_NOTICE("[user] adds some meat to the microwave."))
			src.synthmeat_amount++
			user.u_equip(O)
			O.set_loc(src)
	else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/))
		if(src.humanmeat_amount < 5)
			src.visible_message(SPAN_NOTICE("[user] adds some meat to the microwave."))
			src.humanmeat_name = O:subjectname
			src.humanmeat_job = O:subjectjob
			src.humanmeat_amount++
			user.u_equip(O)
			O.set_loc(src)
	else if (istype(O, /obj/item/reagent_containers/food/snacks/donkpocket_w))
		// Band-aid fix. The microwave code could really use an overhaul (Convair880).
		user.show_text("Syndicate donk pockets don't have to be heated.", "red")
		return
	else if(istype(O, /obj/item/reagent_containers/food/snacks/donkpocket))
		if(src.donkpocket_amount < 2)
			src.visible_message(SPAN_NOTICE("[user] adds a donk-pocket to the microwave."))
			src.donkpocket_amount++
			user.u_equip(O)
			O.set_loc(src)
	else
		if(!isitem(extra_item)) //Allow one non food item to be added!
			if(O.w_class <= W_CLASS_NORMAL)
				user.u_equip(O)
				extra_item = O
				user.u_equip(O)
				O.set_loc(src)
				src.visible_message(SPAN_NOTICE("[user] adds [O] to the microwave."))
			else
				boutput(user, "[O] is too large and bulky to be microwaved.")
		else
			boutput(user, "There already seems to be an unusual item inside, so you don't add this one too.") //Let them know it failed for a reason though

/obj/machinery/microwave/blob_act(power)
	if (!src.is_broken())
		src.set_broken()
		return
	..()


/obj/machinery/microwave/bullet_act(obj/projectile/P)
	if(P.proj_data.damage_type & (D_KINETIC | D_PIERCING | D_SLASHING))
		if(prob(P.power * P.proj_data?.ks_ratio))
			src.set_broken()

/obj/machinery/microwave/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if (prob(50))
				qdel(src)
				return
			if (prob(50))
				src.set_broken()
				return
		if(3)
			if (prob(25))
				qdel(src)
				return
			if (prob(25))
				src.set_broken()
				return

/obj/machinery/microwave/overload_act()
	return !src.set_broken()

/obj/machinery/microwave/set_broken()
	. = ..()
	if (.) return
	src.icon_state = "mwb"
	src.microwave_state = MW_STATE_BROKEN_2

/obj/machinery/microwave/proc/repair(mob/user as mob)
	if (src.microwave_state == MW_STATE_BROKEN_2)
		src.visible_message(SPAN_NOTICE("[user] fixes part of the [src]."))
		src.microwave_state = MW_STATE_BROKEN_1 // Fix it a bit
	else if (src.microwave_state == MW_STATE_BROKEN_1)
		src.visible_message(SPAN_NOTICE("[user] fixes the [src]!"))
		src.icon_state = "mw"
		src.microwave_state = MW_STATE_WORKING // Fix it!
		src.status &= ~BROKEN

/obj/machinery/microwave/proc/clean(mob/user as mob)
	if (src.dirty)
		src.visible_message(SPAN_NOTICE("[user] finishes cleaning the [src]."))
		src.dirty = FALSE
		src.icon_state = "mw"

/**
	*  Microwave Menu
	*/


/obj/machinery/microwave/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "Microwave")
		ui.open()

/obj/machinery/microwave/ui_data(mob/user)
	. = list(
		"broken" = src.microwave_state > 0,
		"operating" = src.operating,
		"dirty" = src.dirty,
		"eggs" = src.egg_amount,
		"flour" = src.flour_amount,
		"monkey_meat" = src.monkeymeat_amount,
		"synth_meat" = src.synthmeat_amount,
		"donk_pockets" = src.donkpocket_amount,
		"other_meat" = src.humanmeat_amount,
		"unclassified_item" = src.extra_item
		)

/obj/machinery/microwave/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch (action)
		if ("start_microwave")
			src.try_cook()
			return TRUE
		if ("eject_contents")
			if (length(src.contents))
				for(var/obj/item/I in src.contents)
					I.set_loc(get_turf(src))
				src.clean_up()
				boutput(usr, "You empty the contents out of the microwave.")
				return TRUE

/obj/machinery/microwave/attack_hand(mob/user)
	if (isghostdrone(user))
		boutput(user, SPAN_ALERT("\The [src] refuses to interface with you, as you are not a properly trained chef!"))
		return
	src.ui_interact(user)

/**
	*  Microwave Cooking
	*/

/obj/machinery/microwave/proc/try_cook()
	if(src.operating)
		return
	var/cooked_item = ""

	src.visible_message(SPAN_NOTICE("The microwave turns on."))
	playsound(src.loc, 'sound/machines/microwave_start.ogg', 25, 0)
	var/diceinside = 0
	for(var/obj/item/dice/D in src.contents)
		if(!diceinside)
			diceinside = 1
		D.load()
	if(diceinside)
		src.cook(MW_COOK_BREAK)
		for(var/obj/item/dice/d in src.contents)
			d.set_loc(get_turf(src))
		return
	for(var/datum/recipe/R in src.available_recipes) //Look through the recipe list we made above
		if(src.egg_amount == R.egg_amount && src.flour_amount == R.flour_amount && src.monkeymeat_amount == R.monkeymeat_amount && src.synthmeat_amount == R.synthmeat_amount && src.humanmeat_amount == R.humanmeat_amount && src.donkpocket_amount == R.donkpocket_amount) // Check if it's an accepted recipe
			if(R.extra_item == null || (src.extra_item && src.extra_item.type == R.extra_item)) // Just in case the recipe doesn't have an extra item in it
				src.cooked_recipe = R
				cooked_item = R.creates // Store the item that will be created
	if(cooked_item == "") //Oops that wasn't a recipe dummy!!!
		if(src.flour_amount > 0 || src.water_amount > 0 || src.monkeymeat_amount > 0 || src.synthmeat_amount > 0 || src.humanmeat_amount > 0 || src.donkpocket_amount > 0 && src.extra_item == null) //Make sure there's something inside though to dirty it
			src.cook(MW_COOK_DIRTY)
		else if(src.egg_amount > 0) // egg was inserted alone
			src.cook(MW_COOK_EGG)
		else if(src.extra_item != null) // However if there's a weird item inside we want to break it, not dirty it
			// warm if it can
			if (istype(src.extra_item,/obj/item/organ) || src.extra_item.reagents)
				src.visible_message(SPAN_NOTICE("The microwave begins warming [src.extra_item]!"))
				src.cook(MW_COOK_WARM)
			else
				src.cook(MW_COOK_BREAK)
		else //Otherwise it was empty, so just turn it on then off again with nothing happening
			src.visible_message(SPAN_NOTICE("You're grilling nothing!"))
			src.cook(MW_COOK_EMPTY)
	else
		var/cooking = text2path(cooked_item) // Get the item that needs to be spanwed
		if(!isnull(cooking))
			src.visible_message(SPAN_NOTICE("The microwave begins cooking something!"))
			src.being_cooked = new cooking(src)
			src.cook(MW_COOK_VALID_RECIPE)

/obj/machinery/microwave/proc/cook(var/result)
	src.operating = TRUE
	src.power_usage = 80
	src.icon_state = "mw1"

	switch(result)
		if(MW_COOK_VALID_RECIPE)
			SPAWN(cook_time)
				if(isnull(src))
					return
				src.icon_state = "mw"
				if(!isnull(src.being_cooked))
					playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
					if(istype(src.being_cooked, /obj/item/reagent_containers/food/snacks/burger/humanburger))
						src.being_cooked.name = "[humanmeat_name] [src.being_cooked.name]"
					if(istype(src.being_cooked, /obj/item/reagent_containers/food/snacks/donkpocket))
						src.being_cooked:warm = 1
						src.being_cooked.name = "warm " + src.being_cooked.name
						src.being_cooked:cooltime()
					if (src.emagged)
						src.being_cooked.reagents.add_reagent("radium", 25)
					if((src.extra_item && src.extra_item.type == src.cooked_recipe.extra_item))
						qdel(src.extra_item)
					if(prob(1))
						src.being_cooked.AddComponent(/datum/component/radioactive, 20, TRUE, FALSE, 0)
					src.being_cooked.set_loc(get_turf(src)) // Create the new item
					src.clean_up()
		if(MW_COOK_BREAK)
			SPAWN(6 SECONDS) // Wait a while
				if(isnull(src))
					return
				elecflash(src,power=2)
				src.visible_message(SPAN_ALERT("The microwave breaks!"))
				src.set_broken()
				src.clean_up()
		if(MW_COOK_EGG)
			SPAWN(4 SECONDS)
				if(isnull(src))
					return
				playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
				icon_state = "mweggexplode1"
			SPAWN(8 SECONDS)
				if(isnull(src))
					return
				playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
				src.visible_message(SPAN_ALERT("The microwave gets covered in cooked egg!"))
				src.dirty = TRUE
				src.icon_state = "mweggexplode"
				src.clean_up()
		if(MW_COOK_DIRTY)
			SPAWN(4 SECONDS)
				if(isnull(src))
					return
				playsound(src.loc, 'sound/impact_sounds/Slimy_Splat_1.ogg', 50, 1)
				icon_state = "mwbloody1"
			SPAWN(8	SECONDS)
				if(isnull(src))
					return
				playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
				src.visible_message(SPAN_ALERT("The microwave gets covered in muck!"))
				src.dirty = TRUE
				src.icon_state = "mwbloody"
				src.clean_up()
		if(MW_COOK_EMPTY)
			SPAWN(8 SECONDS)
				if(isnull(src))
					return
				src.icon_state = "mw"
				playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
				src.clean_up()
		if(MW_COOK_WARM)
			SPAWN(3 SECONDS)
				if(isnull(src))
					return
				if (istype(src.extra_item,/obj/item/organ/head))
					var/obj/item/organ/head/head = src.extra_item

					var/mob/living/carbon/human/H = head.linked_human
					if (H && head.head_type == HEAD_SKELETON && isskeleton(H))
						head.linked_human.emote("scream")
						boutput(H, SPAN_ALERT("The microwave burns your skull!"))

						if (!(head.glasses && istype(head.glasses, /obj/item/clothing/glasses/sunglasses))) //Always wear protection
							H.take_eye_damage(1, 2)
							H.change_eye_blurry(2)
							H.changeStatus("stunned", 1 SECOND)
							H.change_misstep_chance(5)

			SPAWN(6 SECONDS)
				if(isnull(src))
					return
				if (src.extra_item.reagents)
					src.extra_item.reagents.temperature_reagents(4000,400)

				if(prob(1))
					src.extra_item.AddComponent(/datum/component/radioactive, 20, TRUE, FALSE, 0)

				playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
				src.icon_state = "mw"
				src.clean_up()

	src.power_usage = 5

/**
	*  Disposing of microwave contents
	*/

/obj/machinery/microwave/proc/clean_up()
	src.egg_amount = 0
	src.flour_amount = 0
	src.water_amount = 0
	src.humanmeat_amount = 0
	src.synthmeat_amount = 0
	src.monkeymeat_amount = 0
	src.donkpocket_amount = 0
	src.humanmeat_name = ""
	src.humanmeat_job = ""
	src.extra_item = null
	if (length(src.contents))
		for(var/obj/item/O in src.contents)
			if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/egg))
				qdel(O)
			else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/flour))
				qdel(O)
			else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/meat/monkeymeat))
				qdel(O)
			else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/meat/synthmeat))
				qdel(O)
			else if(istype(O, /obj/item/reagent_containers/food/snacks/ingredient/meat/humanmeat/))
				qdel(O)
			else if(istype(O, /obj/item/reagent_containers/food/snacks/donkpocket))
				qdel(O)
			else
				O.set_loc(get_turf(src))
	src.operating = FALSE

#undef MW_COOK_VALID_RECIPE
#undef MW_COOK_BREAK
#undef MW_COOK_EGG
#undef MW_COOK_DIRTY
#undef MW_COOK_EMPTY
#undef MW_COOK_WARM
#undef MW_STATE_WORKING
#undef MW_STATE_BROKEN_1
#undef MW_STATE_BROKEN_2
