extends Node2D

var SOCKET_URL = "ws://192.168.65.27:4000"
var client = WebSocketClient.new()
var payload

func _ready():
	print("Start")
	client.connect("connection_closed", self, "_on_connection_closed")
	client.connect("connection_error", self, "_on_connection_closed")
	client.connect("connection_established", self, "_on_connected")
	client.connect("data_received", self, "_on_data")
	if client.connect_to_url(SOCKET_URL) != OK:
		print("Unable to connect")
		set_process(false)

func _process(delta):
	client.poll()

func _on_connected(proto = ""):
	print("Connected to Server")

func _on_connection_closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)

func _on_data():
	payload = client.get_peer(1).get_packet().get_string_from_utf8()
	print("Received: " + payload)

func _send(text):
	print("Sending: " + text)
	var packet: PoolByteArray = text.to_utf8()
	client.get_peer(1).put_packet(packet)
