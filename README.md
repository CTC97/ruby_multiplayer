## Ruby Multiplayer Functionality

### client.rb
Simple TCPSocket that sends and receives data.
### server.rb
Simple TCPServer that sends and receives data and stores information about server-side or "overworld" entities.
### ui.rb
Gosu UI that allows player to control movement. Each instance of the UI creates an instance of the client and connects to the server. The ui uses the client to send position, "player name" (id), and color data to the server. It also sends data to the server if it has "killed" an overworld entity (triggered by collision). The ui reads data from the server to see if any of the other connected clients have killed an overworld entity.

<img src="other/screenshot_2-9.png" alt="screenshot" width="600"/>

### To Do:
- Pull squares into their own class (to be abstracted as a placeholder for players, entities, overworld items, etc.)