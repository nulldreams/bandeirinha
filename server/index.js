const express = require('express')
const app = express()
const port = 3000 || process.env.PORT
const WebSocket = require('ws')
const gdCom = require('@gd-com/utils')
const _ = require('lodash')
const { v4 } = require('uuid')

const wss = new WebSocket.Server({ port: 8080 })
wss.broadcast = function broadcast (msg) {
  wss.clients.forEach(function each (client) {
    client.send(msg)
  })
}

const types = {
  CREATE_ROOM: 'create_room',
  CONNECT_TO_ROOM: 'connect_to_room',
  PLAYERS_INFO: 'players_info',
  UPDATE_PLAYER_POSITION: 'update_player_position'
}
const rooms = []

wss.on('connection', ws => {
  ws.on('message', (message) => {
    const recieve = new gdCom.GdBuffer(Buffer.from(message))
    const response = handlePayload(recieve.getVar())
    const buffer = new gdCom.GdBuffer()
    buffer.putVar(response)

    if (response) {
      // ws.send(buffer.getBuffer())
      return wss.broadcast(buffer.getBuffer())
    }
  })
})

const handlePayload = ({ type, payload }) => {
  if (type === types.CREATE_ROOM) return createRoomHandler(payload)
  if (type === types.CONNECT_TO_ROOM) return connectToRoomHandler(payload)
  if (type === types.PLAYERS_INFO) return playersInfoHandler(payload)
  if (type === types.UPDATE_PLAYER_POSITION) return updatePlayerPositionHandler(payload)
}

const updatePlayerPositionHandler = (payload) => {
  const room = _.find(rooms, { id: payload.room_id })
  const roomIndex = _.findIndex(rooms, { id: payload.room_id })
  console.log(room.players[payload.player_id])
  room.players[payload.player_id].position = payload.player_position
  rooms[roomIndex] = room
}

const playersInfoHandler = (payload) => {
  const room = _.find(rooms, { id: payload.room_id })
  if (room) return { type: 'players_info_response', players: room.players }
}

const connectToRoomHandler = (payload) => {
  const { room_id, ...player } = payload
  const room = _.find(rooms, { id: room_id })
  const player_id = v4().replace(/\D/g, '')
  player.id = player_id
  room.players[player_id] = {
    player_id,
    ...player
  }
  return { type: 'connect_to_room_response', room_id: room.id, player_info: player }
}

const createRoomHandler = (player) => {
  const room_id = 1 // v4()
  const player_id = v4().replace(/\D/g, '')
  const room_data = {
    id: room_id,
    name: `${player.name}_${room_id}`,
    owner: {
      player_name: player.name,
      player_id
    },
    players: {},
    winner: null,
    active: true
  }
  room_data.players[player_id] = {
    player_id,
    ...player
  }

  rooms.push(room_data)
  return { type: 'create_room_response', room_id, player_info: { id: player_id, ...player } }
}

app.get('/', (req, res) => {
  res.send('<h1>Hello world</h1>')
})

app.listen(port, () => {
  console.log('listening on *:3000')
})
