/////////////////
// FLOCKTRACE
/////////////////
TYPEINFO(/mob/living/intangible/flock/trace)
	start_listen_modifiers = list(LISTEN_MODIFIER_MOB_MODIFIERS)
	start_listen_inputs = list(LISTEN_INPUT_EARS, LISTEN_INPUT_RADIO_DISTORTED, LISTEN_INPUT_SILICONCHAT_DISTORTED, LISTEN_INPUT_GHOSTLY_WHISPER)
	start_listen_languages = list(LANGUAGE_ALL)
	start_speech_modifiers = null
	start_speech_outputs = null

/mob/living/intangible/flock/trace
	name = "Flocktrace"
	real_name = "Flocktrace"
	desc = "The representation of a partition of the will of the flockmind."
	icon = 'icons/misc/featherzone.dmi'
	icon_state = "flocktrace"
	compute = -FLOCKTRACE_COMPUTE_COST //it is expensive to run more threads
	default_speech_output_channel = SAY_CHANNEL_FLOCK
	say_language = LANGUAGE_FEATHER

	var/creation_time = 0

	var/dying = FALSE

/mob/living/intangible/flock/trace/New(atom/loc, datum/flock/F, free = FALSE)
	src.creation_time = TIME

	if (free)
		src.compute = 0
	..(loc)
	src.abilityHolder = new /datum/abilityHolder/flockmind(src)

	if(istype(F))
		src.flock = F
		src.flock.addTrace(src)
		src.flock.stats.partitions_made++
		if (free)
			src.flock.free_traces++
	else
		src.death()

	src.real_name = src.flock ? src.flock.pick_name("flocktrace") : name
	src.name = src.real_name
	src.update_name_tag()
	if (src.flock.relay_in_progress)
		var/obj/flock_structure/relay/relay = locate() in src.flock.structures
		if (relay)
			src.AddComponent(/datum/component/tracker_hud/flock, relay)

	src.addAbility(/datum/targetable/flockmindAbility/designateTile)
	src.addAbility(/datum/targetable/flockmindAbility/designateEnemy)
	src.addAbility(/datum/targetable/flockmindAbility/designateIgnore)
	src.addAbility(/datum/targetable/flockmindAbility/directSay)
	src.addAbility(/datum/targetable/flockmindAbility/ping)

/mob/living/intangible/flock/trace/proc/describe_state()
	var/state = list()
	state["update"] = "partition"
	state["ref"] = "\ref[src]"
	state["name"] = src.real_name
	var/mob/living/critter/flock/host = src.loc
	if(istype(host))
		state["host"] = host.real_name
		state["health"] = round(host.get_health_percentage()*100)
	else
		state["host"] = null
		state["health"] = 100
	. = state


/mob/living/intangible/flock/trace/special_desc(dist, mob/user)
	if (!isflockmob(user))
		return
	return {"[SPAN_FLOCKSAY("[SPAN_BOLD("###=- Ident confirmed, data packet received.")]<br>\
			[SPAN_BOLD("ID:")] [src.real_name]<br>\
			[SPAN_BOLD("Flock:")] [src.flock ? src.flock.name : "none, somehow"]<br>\
			[SPAN_BOLD("Resources:")] [src.flock.total_resources()]<br>\
			[SPAN_BOLD("System Integrity:")] [round(src.flock.total_health_percentage()*100)]<br>\
			[SPAN_BOLD("Cognition:")] SYNAPTIC PROCESS<br>\
			[SPAN_BOLD("###=-")]")]"}

/mob/living/intangible/flock/trace/select_drone(mob/living/critter/flock/drone/drone)
	if (src.flock?.flockmind.tutorial)
		return
	..()

/mob/living/intangible/flock/trace/proc/promoteToFlockmind(remove_flockmind_from_flock)
	var/was_in_drone = FALSE
	var/mob/living/critter/flock/drone/controlled = src.loc
	if (istype(controlled))
		was_in_drone = TRUE
		controlled.release_control(FALSE)

	src.flock.system_say_source.say("New functions detected. Control of Flock assumed.", atom_listeners_override = list(src))
	src.flock.system_say_source.say("Flocktrace [src.real_name] has been promoted to Flockmind.")

	var/mob/living/intangible/flock/flockmind/original = src.flock.flockmind
	original.tutorial?.Finish()
	if (remove_flockmind_from_flock)
		var/mob/living/intangible/flock/flockmind/F = new (get_turf(src), src.flock)
		src.mind.transfer_to(F)
		F.flock.flockmind_mind = src.mind
		if (was_in_drone)
			controlled.take_control(F, FALSE)
		src.flock.removeTrace(src)
		src.flock.hideAnnotations(original)
		original.ghostize()
		qdel(original)
		qdel(src)
	else
		src.mind.swap_with(original)
		if (was_in_drone)
			src.set_loc(get_turf(original))
			controlled.take_control(original, FALSE)

/mob/living/intangible/flock/trace/Life(datum/controller/process/mobs/parent)
	if (..(parent))
		return TRUE
	if (src.flock && src.compute != 0 && length(src.flock.traces) > src.flock.max_trace_count + src.flock.queued_trace_deaths && !src.dying)
		src.dying = TRUE
		src.flock.queued_trace_deaths++
		boutput(src, SPAN_ALERT("The Flock has insufficient compute to sustain your consciousness! You will die soon!"))
		src.addOverlayComposition(/datum/overlayComposition/flockmindcircuit/flocktrace_death)
		src.updateOverlaysClient(src.client)
		if (istype(src.loc, /mob/living/critter/flock/drone))
			var/mob/living/critter/flock/drone/flockdrone = src.loc
			flockdrone.addOverlayComposition(/datum/overlayComposition/flockmindcircuit/flocktrace_death)
			flockdrone.updateOverlaysClient(src.client)
		SPAWN(5 SECONDS)
			if (src?.flock)
				if (length(src.flock.traces) > src.flock.max_trace_count)
					src.death()
				else
					src.dying = FALSE
					boutput(src, SPAN_ALERT("The Flock has gained enough compute to keep you alive!"))
					src.removeOverlayComposition(/datum/overlayComposition/flockmindcircuit/flocktrace_death)
					src.updateOverlaysClient(src.client)
				src.flock.queued_trace_deaths--

/mob/living/intangible/flock/trace/death(gibbed, suicide = FALSE)
	. = ..()
	if (istype(src.loc, /mob/living/critter/flock/drone))
		var/mob/living/critter/flock/drone/F = src.loc
		F.release_control_abrupt(FALSE)
		if (F.z == Z_LEVEL_STATION)
			src.flock.system_say_source.say("Control of drone [F.real_name] surrendered.", atom_listeners_override = list(src))
	if(src.client)
		if (suicide)
			src.flock.system_say_source.say("Flocktrace [src.real_name] relinquishes their computational designation and reintegrates themselves back into the Flock.")
		boutput(src, SPAN_ALERT("You cease to exist abruptly."))
	src.flock?.removeTrace(src)
	REMOVE_ATOM_PROPERTY(src, PROP_MOB_INVISIBILITY, src)
	src.icon_state = "blank"
	src.canmove = FALSE
	FLICK("flocktrace-death", src)
	src.ghostize()
	spawn(2 SECONDS) // wait for the animation to finish
		qdel(src)

/mob/living/intangible/flock/trace/ghostize()
	var/mob/dead/observer/O = ..()
	if (!O)
		return null

	O.icon = src.icon
	O.icon_state = "flocktrace-ghost"
	O.pixel_y = initial(O.pixel_y) // WHY DO I NEED TO DO THIS TOO I DON'T EVEN ANIMATE THE PIXEL_Y
	animate_bumble(O)
	O.alpha = 160
	return O


