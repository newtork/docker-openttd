# docker-openttd
Dedicated OpenTTD game server, full automatic Docker build


# Notice
Before build, feel free to change your local config patches file.


# Usage
newtork/ottd [save [config [name]]]
	

# Explanation

	docker run -dit -p 3979:3979/tcp -p 3979:3979/udp newtork/openttd [savegame] [settings] [servername]

	\_____________/ \_______________________________/ \_____________/  \______/  \________/  \_________/
          |                        |                      |              |           |            |
     interactive       required port forwarding      maintainer     save game   config string   public game
      detached          destination port can be        build          name      \n-seperated    server name
      terminal           changed as required                           


# Example
	docker run -dit -p 3979:3979/tcp -p 3979:3979/udp newtork/openttd
	docker run -dit -p 3979:3979/tcp -p 3979:3979/udp newtork/openttd save1
	docker run -dit -p 3979:3979/tcp -p 3979:3979/udp newtork/openttd save2 "$(</local/openttd.cfg)"
	docker run -dit -p 3979:3979/tcp -p 3979:3979/udp newtork/openttd save3 "map_x=4 \n map_y=5" "My Favorit Server"

