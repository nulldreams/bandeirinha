extends Node

var ws = null
var connected = false
var SERVER_URL = "ws://localhost:8080"
export var room_id = ""
export var players = {}
export var master = ""

func connect_to_server():
	ws = WebSocketClient.new()
	ws.connect("connection_established", self, "_connection_established")
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")
	ws.connect("data_received", self, "_data_received")
	
	var status = ws.connect_to_url(SERVER_URL)
	connected = true

func create_server_room(player_name):
	var create_server_room_payload = {
		"type": "create_room",
		"payload": {
			"name": player_name,
			"state": 0,
			"position": Vector2(191, 64),
			"chickens_captured": 0
		}
	}
	
	send_to_server(create_server_room_payload)

func connect_to_server_room(player_name, room_id):
	var connect_to_server_room_payload = {
		"type": "connect_to_room",
		"payload": {
			"room_id": room_id,
			"name": player_name,
			"state": 0,
			"position": Vector2(180, 80),
			"chickens_captured": 0
		}
	}
	
	send_to_server(connect_to_server_room_payload)

func retrieve_player_info(room_id, player_id):
	var retrieve_player_info_payload = {
		"type": "player_info",
		"payload": {
			"room_id": room_id,
			"player": {
				"id": player_id
			}
		}
	}
	
	send_to_server(retrieve_player_info_payload)
	
func update_player_info(room_id, player_id, player):
	var update_player_info_payload = {
		"type": "update_player_info",
		"payload": {
			"room_id": room_id,
			"player": {
				"id": player_id,
				"position": player.position,
				"state": player.state
			}
		}
	}
	
	send_to_server(update_player_info_payload)

func send_to_server(variable):
	if ws.get_peer(1).is_connected_to_host():
		ws.get_peer(1).put_var(variable)
#		if ws.get_peer(1).get_available_packet_count() > 0 :
#			var test = ws.get_peer(1).get_var()
#			print('recieve %s' % test)

func _connection_established(protocol):
	print("Connection established with protocol: ", protocol)
	
func _connection_closed():
	print("Connection closed")

func _connection_error():
	print("Connection error")

func _data_received():
	pass

func _process(delta):
	if connected:
		if ws.get_connection_status() == ws.CONNECTION_CONNECTING || ws.get_connection_status() == ws.CONNECTION_CONNECTED:
			ws.poll()
		if ws.get_peer(1).is_connected_to_host():
			ws.get_peer(1).put_var({ "type": "players_info", "payload": { "room_id": room_id } })
		if ws.get_peer(1).get_available_packet_count() > 0 :
			handle_server_responses(ws.get_peer(1).get_var())

func handle_server_responses(response):
	if response:
		if response.type == "create_room_response":
			room_id = response.room_id
			players[response.player_info.id] = response.player_info
			master = response.player_info.id
			initiate_player(players[response.player_info.id])
		if response.type == "connect_to_room_response":
			room_id = response.room_id
			players[response.player_info.id] = response.player_info
			players = response.players
			master = response.player_info.id
			initiate_player(players[response.player_info.id])
		if response.type == "players_info_response":
			players = response.players
		
func initiate_player(player):
	var new_player = load('res://Entities/Player/Player.tscn').instance()
	new_player.name = str(player.name)
	new_player.set_network_master(int(player.id))
	$'/root/Main/World/Objects'.add_child(new_player)
	new_player.init(player.name, player.position, player.id)
