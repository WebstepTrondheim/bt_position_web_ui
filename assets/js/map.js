// Map channel (websocket)
import socket from "./socket"

let WsMap = function() {

  Mazemap.Config.setApiBaseUrl("https://api.mazemap.com");
  Mazemap.Config.setMMTileBaseUrl("https://tiles.mazemap.com");

  let devices = {}

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
    }
  }

  function parent_id_to_room(parent_id) {
    console.log("get parent", parent_id)
    let parents = {
      "d2608d72b86f": "sofa",
      "fe4fdc9e9a24": "projektor",
      "feb1cd8c6dea": "lunsj"
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


    Mazemap.Data.getPoiAt(lngLat, 2).then( poi => {
      map.highlighter.highlight(poi)
    })
  })

  function add_marker(lngLat) {
    let marker = new Mazemap.MazeMarker(
      {
        zLevel: 2 // The floor zLevel coordinate is given here
      })
        .setLngLat( lngLat ) // Set the LngLat coordinates here
        .addTo(map); // Now add to the map
  }

  function draw_devices() {
    for(let device in devices) {
      console.log("draw:" , device)
      let room = parent_id_to_room(devices[device])
      console.log("ROOM", room)
      if(room) {
        add_marker(rooms[room])
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
    draw_devices: draw_devices
  }

}

let init = function() {
  //// MAP
  let self = this
  let ws_map = WsMap()

  let map = ws_map.get_map()

  map.on("click", (event) => {
    console.log(event.lngLat)
  })

  let lngLat = {
    lat: 63.430953,
    lng: 10.395839
  }



  // websocket
  let channel = socket.channel("map:lobby", {})

  channel.on("update_positions", resp => {
    let device = JSON.parse(resp.device_position)
    console.log(ws_map.devices)
    if(ws_map.devices[device.device_id] != device.parent_id) {
      ws_map.devices[device.device_id] = device.parent_id
    }

    console.log(ws_map.devices)

    ws_map.draw_devices()
  })

  console.log("JS JOINING map:lobby")
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })
}

init()














// let lunsj = {
//   "type": "Feature",
//   "geometry": {
//     "type": "Polygon",
//     "coordinates": [
//       [
//         63.43094014690098,
//         10.395655474599636
//       ],
//       [
//         63.43100051328767,
//         10.395609878440268
//       ],
//       [
//         63.430968698589,
//         10.395708974089303
//       ],
//       [
//         63.43091648976974,
//         10.395701678690756
//       ]
//     ]
//   },
//   "properties": {
//     "title": "Lunsj",
//     "campusId": 324,
//     "zLevel": 2,
//   }
// }
