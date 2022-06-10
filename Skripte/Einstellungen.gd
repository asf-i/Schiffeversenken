extends Button

var min_swipe_distanz : int = 100
var swipe_verlangsamung : int = 240

var richtunganders : int = 1
var sonst_okay : bool = true
var swipe_event_relative

var settings_immer : bool = false #Fürs Testen

func _ready():
	$Rotieren.pressed = Autoload.savegame_data.rotier_mode
	$AudioButton.pressed = Autoload.savegame_data.sound_an
	$Vibration.pressed = Autoload.savegame_data.vibration
	$ScreenshakeSlider.value = Autoload.savegame_data.screenshake_value
	richtunganders = 1

func _on_SwipeDetector_swipe(local_swipe, event_relative, start):
	visible = true
	swipe_event_relative = event_relative
	if settings_immer or (abs(get_parent().get_node("SwipeDetector").start_direction.y) > abs(get_parent().get_node("SwipeDetector").start_direction.x) && (get_parent().get_node("SwipeDetector").start_direction.y * richtunganders < 0 && not get_parent().get_node("SettingWegButton").visible or get_parent().get_node("SwipeDetector").start_direction.y * richtunganders > 0 && get_parent().get_node("SettingWegButton").visible) && get_parent().get_node_or_null("OnlineListe") == null && sonst_okay && start.y < Autoload.actual_screen_height - 100):
		rect_position.y += event_relative.y * richtunganders / (0.5 * abs(local_swipe.y) / swipe_verlangsamung + 1)
	if rect_position.y < Autoload.actual_screen_height - rect_size.y:
		rect_position.y = Autoload.actual_screen_height - rect_size.y
	elif rect_position.y > Autoload.actual_screen_height:
		rect_position.y = Autoload.actual_screen_height + 1
	
	#Fürs Testen
	if settings_immer:
		get_parent().move_child(self, get_parent().get_child_count())

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_SwipeDetector_swipe_done(start, end, local_swipe):
	var start_direction = get_parent().get_node("SwipeDetector").start_direction.y
	if settings_immer or (abs(start_direction) > abs(get_parent().get_node("SwipeDetector").start_direction.x) && get_parent().get_node_or_null("OnlineListe") == null && sonst_okay && swipe_event_relative.y * (start_direction / abs(start_direction)) > 0 && start.y < Autoload.actual_screen_height - 100):
		if get_parent().get_node("SwipeDetector").start_direction.y * richtunganders < 0 && not get_parent().get_node("SettingWegButton").visible:
			get_parent().get_node("SettingWegButton").visible = true
			$Tween.interpolate_property(self, "rect_position:y", rect_position.y, Autoload.actual_screen_height - rect_size.y, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
		elif get_parent().get_node("SwipeDetector").start_direction.y * richtunganders > 0 &&  get_parent().get_node("SettingWegButton").visible:
			get_parent().get_node("SettingWegButton").visible = false
			$Tween.interpolate_property(self, "rect_position:y", rect_position.y, Autoload.actual_screen_height + 1, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			visible = false
	elif not get_parent().get_node("SettingWegButton").visible:
		$Tween.interpolate_property(self, "rect_position:y", rect_position.y, Autoload.actual_screen_height + 1, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		yield($Tween, "tween_all_completed")
		visible = false
	else:
		$Tween.interpolate_property(self, "rect_position:y", rect_position.y, Autoload.actual_screen_height - rect_size.y, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()

func _on_SettingWegButton_pressed():
	get_parent().get_node("SettingWegButton").visible = false
	$Tween.interpolate_property(self, "rect_position:y", Autoload.actual_screen_height - rect_size.y, Autoload.actual_screen_height + 1, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	visible = false

func on_off_switch(button, pressed):
	if pressed:
		button.get_node("OnOff").frame = 1
	else:
		button.get_node("OnOff").frame = 0

func _on_CheckButton_toggled(button_pressed):
	Autoload.savegame_data.rotier_mode = button_pressed
	Autoload.save()
	on_off_switch($Rotieren, button_pressed)

func _on_AudioButton_toggled(button_pressed):
	Autoload.savegame_data.sound_an = button_pressed
	Autoload.save()
	on_off_switch($AudioButton, button_pressed)

func _on_Vibration_toggled(button_pressed):
	Autoload.savegame_data.vibration = button_pressed
	Autoload.save()
	on_off_switch($Vibration, button_pressed)


func _on_LineEdit3_text_entered(new_text):
	var ohh : String = ""
	if new_text.length() > 4:
		for i in 6:
			ohh += new_text[i]
		if ohh == "clear ":
			ohh = ""
			for i in new_text.length() - 6:
				ohh += new_text[i + 6]
			Server.rpc_id(1, "sachen_clearen", ohh)

func _on_SettingsImmer_toggled(button_pressed): #Fürs Testen
	settings_immer = button_pressed
	on_off_switch($SettingsImmer, button_pressed)

func _on_ScreenshakeSlider_value_changed(value):
	Autoload.savegame_data.screenshake_value = value

func _on_SchiffplatzierUknow_pressed():
	for i in Autoload.spieler1_centerfelder.size():
		if $"/root/Welt".spieler2_ist_dran:
			$"/root/Welt/Felder".schiff_in_feld_platzieren(get_node("/root/Welt/Felder/" + Autoload.spieler1_centerfelder.keys()[i]), true, true, $"/root/Welt/Schiffe")
		else:
			$"/root/Welt/Felder".schiff_in_feld_platzieren(get_node("/root/Welt/Felder/" + Autoload.spieler2_centerfelder.keys()[i]), true, true, $"/root/Welt/Schiffe")

func _on_SchiffplatzierUknow2_pressed():
	for i in Autoload.spieler1_centerfelder.size(): #Hier könnte auch spieler2_centerfelder stehen, es geht nur um die Länge
		if $"/root/Welt".spieler2_ist_dran:
			$"/root/Welt/Felder".schiff_in_feld_platzieren(get_node("/root/Welt/Felder/" + Autoload.spieler2_centerfelder.keys()[i]), false, true, $"/root/Welt/Schiffe")
		else:
			$"/root/Welt/Felder".schiff_in_feld_platzieren(get_node("/root/Welt/Felder/" + Autoload.spieler1_centerfelder.keys()[i]), false, true, $"/root/Welt/Schiffe")
