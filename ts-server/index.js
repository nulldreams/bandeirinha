const express = require('express')
const app = express()
const port = 3000 || process.env.PORT
const WebSocket = require('ws')
const gdCom = require('@gd-com/utils')
const _ = require('lodash')
const { v5 } = require('uuid')

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

    const buffer = new gdCom.GdBuffer()
    buffer.putVar(Math.random())
    ws.send(buffer.getBuffer())
  })
})

const handlePayload = ({ type, payload }) => {
  if (type === types.CREATE_ROOM) {
    const room_data = {

    }
  }
}

app.get('/', (req, res) => {
  res.send('<h1>Hello world</h1>')
})

app.listen(port, () => {
  console.log('listening on *:3000')
})
