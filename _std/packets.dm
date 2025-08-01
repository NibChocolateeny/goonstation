
#define DEFAULT_RADIO_JAMMER_RANGE 6

proc/check_for_radio_jammers(atom/source, datum/signal/signal)
	. = FALSE
	for (var/atom/A as anything in by_cat[TR_CAT_RADIO_JAMMERS])
		var/range = DEFAULT_RADIO_JAMMER_RANGE
		if(istype(A, /obj/item/radiojammer))
			var/obj/item/radiojammer/jammer = A
			range = jammer.range
		if (IN_RANGE(source, A, range))
			SEND_SIGNAL(A, COMSIG_SIGNAL_JAMMED, signal)
			return TRUE

#define MAKE_DEFAULT_RADIO_PACKET_COMPONENT(net_id, conn_id, freq) src._AddComponent(list( \
		/datum/component/packet_connected/radio, \
		conn_id, \
		freq, \
		net_id, \
		hascall(src, "receive_signal") ? "receive_signal" : null, \
		FALSE, \
		null, /*("id_tag" in src.vars) ? "[src.vars["id_tag"]]" : null, */\
		FALSE \
	))

#define MAKE_DEVICE_RADIO_PACKET_COMPONENT(net_id, conn_id, freq) src._AddComponent(list( \
		/datum/component/packet_connected/radio, \
		conn_id, \
		freq, \
		net_id, \
		hascall(src, "receive_signal") ? "receive_signal" : null, \
		FALSE, \
		null, /*("id_tag" in src.vars) ? "[src.vars["id_tag"]]" : null, */\
		FALSE, \
		TRUE \
	))

#define MAKE_SENDER_RADIO_PACKET_COMPONENT(net_id, conn_id, freq) src._AddComponent(list( \
		/datum/component/packet_connected/radio, \
		conn_id, \
		freq, \
		net_id, \
		null, \
		TRUE, \
		null, /*("id_tag" in src.vars) ? "[src.vars["id_tag"]]" : null, */\
		FALSE \
	))

proc/get_packet_connection_by_id(atom/movable/AM, id)
	RETURN_TYPE(/datum/component/packet_connected)
	for(var/datum/component/packet_connected/comp as anything in AM.GetComponents(/datum/component/packet_connected))
		if(comp.connection_id == id)
			return comp
	return null

proc/get_radio_connection_by_id(atom/movable/AM, id)
	RETURN_TYPE(/datum/component/packet_connected/radio)
	for(var/datum/component/packet_connected/radio/comp as anything in AM.GetComponents(/datum/component/packet_connected/radio))
		if(comp.connection_id == id)
			return comp
	return null

/// packet transmission types
#define TRANSMISSION_INVALID -1
#define TRANSMISSION_WIRE	0
#define TRANSMISSION_RADIO	1

//Signal frequencies

#define FREQ_PDA 1149
#define FREQ_CLONER_IMPLANT 1151
#define FREQ_PUMP_CONTROL 1225 //frequency for the control of pumps
#define FREQ_AIRLOCK 1411
#define FREQ_FREE 1419 /// frequency for "free packet communication", default for nerd stuff
#define FREQ_NAVBEACON 1445
#define FREQ_SECURE_STORAGE 1431
#define FREQ_SECBUDDY_NAVBEACON 1431
#define FREQ_ALARM 1437 // fire and air alarms
#define FREQ_HYDRO 1433
#define FREQ_HARMONIC_SIPHON 1455
#define FREQ_TRANSCEPTION_SYS 1465
#define FREQ_STATUS_DISPLAY 1435
#define FREQ_BOT_CONTROL 1447
#define FREQ_AIRLOCK_CONTROL 1449 // seems to be unused nowadays?
#define FREQ_GPS 1453
#define FREQ_RUCK 1467
#define FREQ_AINLEY_BUDDY 1917
#define FREQ_BUDDY 1219
#define FREQ_SECBUDDY 1089
#define FREQ_TOUR_NAVBEACON 1443
#define FREQ_SIGNALER 1457
#define FREQ_DOOR_CONTROL 1143 /// pods open podbay doors with this frequency but in theory more general
#define FREQ_MAIL_CHUTE 1475
#define FREQ_COMM_DISH 0000 // unused for now, supposed to be for communication across comm dishes
#define FREQ_AIR_ALARM_CONTROL 1439
#define FREQ_TRACKING_IMPLANT 1451
#define FREQ_MARIONETTE_IMPLANT 1153
#define FREQ_POWER_SYSTEMS 1473 // for services that interface with power machinery
#define FREQ_ARMORY 1461
// Address Tags
#define ADDRESS_TAG_POWER "POWER_CONTROL" // for syncing variables and data with power_checker
