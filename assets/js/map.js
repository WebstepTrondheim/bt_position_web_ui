// Map channel (websocket)
import socket from './socket';

let WsMap = function() {

  Mazemap.Config.setApiBaseUrl('https://api.mazemap.com');
  Mazemap.Config.setMMTileBaseUrl('https://tiles.mazemap.com');

  let devices = {};

  let rooms = {
    sofa: {
      lat: 63.43100698589018,
      lng: 10.395959028836984
    },
    projektor: {
      lat: 63.43110176088089,
      lng: 10.39576725088341
    },
    lunsj: {
      lat: 63.4309541996827,
      lng: 10.395609000540617
    },
    small_meeting_room: {
      lng: 10.39574847543227,
      lat: 63.43093440483068
    },
    big_meeting_room: {
      lng: 10.395959028836984,
      lat: 63.431113157850604
    },
    iot_lab: {
      lng: 10.395804801815814,
      lat: 63.431121555617295
    }
  }

  function parent_id_to_room(parent_id) {
    let parents = {
      d2608d72b86f: 'sofa',
      fe4fdc9e9a24: 'iot_lab',
      feb1cd8c6dea: 'big_meeting_room',
      ffa24f409c3a: 'small_meeting_room'
    }
    return parents[parent_id]
  }

  let lngLat = {
    lat: 63.430953,
    lng: 10.395839
  }

  let map = new Mazemap.Map({
    container: 'mazemap-container',
    campuses: 324,
    zoom: 19,
    center: lngLat,
    zLevel: 2
  });

  map.alarm_markers = []

  map.addControl(new Mazemap.mapboxgl.NavigationControl());

  map.on('load', () => {
    // Initialize a Highlighter for POIs
    // Storing the object on the map just makes it easy to access for other things
    map.highlighter = new Mazemap.Highlighter( map, {
      showOutline: true, // optional
      showFill: true, // optional
      outlineColor: Mazemap.Util.Colors.MazeColors.MazeRed, // optional
      fillColor: Mazemap.Util.Colors.MazeColors.MazeRed  // optional
    } );

  })

  function highlight_room(lngLat) {
    Mazemap.Data.getPoiAt(lngLat, 2).then( poi => {
      map.highlighter.highlight(poi)
    })
  }

  function add_marker(lngLat, device_id, alarm_status) {
    let color = alarm_status ? '#C3746C': 'MazeBlue'
    let marker = new Mazemap.MazeMarker(
      {
        zLevel: 2, // The floor zLevel coordinate is given here
        color: color
      })
        .setLngLat( lngLat ) // Set the LngLat coordinates here
        .addTo(map); // Now add to the map

  }

  function draw_devices() {
    for(let device in devices) {
      let room = parent_id_to_room(devices[device])
      if(room) {
        let alarm_status = map.alarm_markers.includes(device)
        add_marker(rooms[room], device, alarm_status)
      }
    }
  }

  function get_map() {
    return map
  }

  function get_devices() {
    return devices
  }

  function get_rooms() {
    return rooms
  }

  return {
    add_marker: add_marker,
    devices: devices,
    get_rooms: get_rooms,
    get_devices: get_devices,
    get_map: get_map,
    add_marker: add_marker,
    parent_id_to_room: parent_id_to_room,
    draw_devices: draw_devices,
    highlight_room: highlight_room
  }

}

let init = function() {
  //// MAP
  let self = this
  let ws_map = WsMap()

  let map = ws_map.get_map()

  map.on('click', (event) => {
    console.log(event.lngLat)
  })

  let lngLat = {
    lat: 63.430953,
    lng: 10.395839
  }

  // websocket
  let channel = socket.channel('map:lobby', {})

  channel.on('update_positions', resp => {
    let device = JSON.parse(resp.device_position)
    if(ws_map.devices[device.device_id] != device.parent_id) {
      ws_map.devices[device.device_id] = device.parent_id
    }
  })

  channel.on('update_alarm', resp => {
    let payload = JSON.parse(resp.device_alarm)
    if(payload.alarm_status) {
      map.alarm_markers.push(payload.device_id)
    } else {
      map.alarm_markers.pop(payload.device_id)
    }
    ws_map.draw_devices();
  })

  channel.join()
    .receive('ok', resp => { console.log('Joined successfully', resp) })
    .receive('error', resp => { console.log('Unable to join', resp) })
}

init();
