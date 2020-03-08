const express = require('express')
const app = express()
const port = 3000 || process.env.PORT
const WebSocket = require('ws')
const gdCom = require('@gd-com/utils')
const _ = require('lodash')
const { v4 } = require('uuid')

const wss = new WebSocket.Server({ port: 8080 })

const types = {
  CREATE_ROOM: 'create_room'
}
const rooms = []

wss.on('connection', ws => {
  console.log('connected')
  ws.on('message', (message) => {
    const recieve = new gdCom.GdBuffer(Buffer.from(message))
    handlePayload(recieve.getVar())
    console.log(JSON.stringify(rooms[0], null, 4))
    const buffer = new gdCom.GdBuffer()
    buffer.putVar(Math.random())
    ws.send(buffer.getBuffer())
  })
})

const handlePayload = ({ type, payload }) => {
  if (type === types.CREATE_ROOM) {
    const room_id = v4()
    const player_id = v4()
    const room_data = {
      id: room_id,
      name: `${payload.name}_${room_id}`,
      owner: {
        player_name: payload.name,
        player_id
      },
      players: {
        player_id,
        ...payload
      },
      winner: null,
      active: true
    }

    rooms.push(room_data)
  }
}

// {
//     "type": "create_room",
//     "payload": {
//         "name": player_name,
//         "state": {
//             "last": "STATE_IDLE",
//             "actual": "STATE_IDLE"
//         },
//         "position": Vector2(191, 64),
//         "chickens_captured": 0
//     }
// }

app.get('/', (req, res) => {
  res.send('<h1>Hello world</h1>')
})

app.listen(port, () => {
  console.log('listening on *:3000')
})
