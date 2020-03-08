extends Node

var ws = null
var connected = false
var SERVER_URL = "ws://localhost:8080"

func connect_to_server():
	ws = WebSocketClient.new()
	ws.connect("connection_established", self, "_connection_established")
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")
	
	var status = ws.connect_to_url(SERVER_URL)
	print("a", " ", status)
	connected = true

func create_server_room(player_name):
	var create_server_room_payload = {
		"type": "create_room",
		"payload": {
			"name": player_name,
			"state": {
				"last": "STATE_IDLE",
				"actual": "STATE_IDLE"
			},
			"position": Vector2(191, 64),
			"chickens_captured": 0
		}
	}
	
	send_to_server(create_server_room_payload)

func send_to_server(variable):
	if ws.get_peer(1).is_connected_to_host():
		ws.get_peer(1).put_var(variable)
		if ws.get_peer(1).get_available_packet_count() > 0 :
			var test = ws.get_peer(1).get_var()
			print('recieve %s' % test)

func _connection_established(protocol):
	print("Connection established with protocol: ", protocol)
	
func _connection_closed():
	print("Connection closed")

func _connection_error():
	print("Connection error")

func _process(delta):
	if connected:
		if ws.get_connection_status() == ws.CONNECTION_CONNECTING || ws.get_connection_status() == ws.CONNECTION_CONNECTED:
			ws.poll()
#		if ws.get_peer(1).is_connected_to_host():
#			ws.get_peer(1).put_var({ "teste": 123 })
#			if ws.get_peer(1).get_available_packet_count() > 0 :
#				var test = ws.get_peer(1).get_var()
#				print('recieve %s' % test)
