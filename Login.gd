extends Node2D

func _ready():
	pass

func _process(delta):
	if WebSocket.payload != null:
		var payload = WebSocket.payload.split('#')
		if payload[0] == "sweg":
			print("yes")
		else:
			print("no")
		WebSocket.payload = null

func _on_Button_pressed():
	WebSocket._send("swag")
	get_tree().change_scene("res://Menu.tscn")
