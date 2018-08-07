require "../src/crystal_mpd"

client = MPD::Client.new

puts "MPD host: #{client.host}"
puts "MPD port: #{client.port}"
puts "MPD version: #{client.version}"

# puts client.status
# puts client.stats
# puts client.config
# puts client.delete([0, 2])
# puts client.playlistinfo(1)
# puts client.playlistsearch("title", "All Around Me")
# puts client.playlistfind("title", "All Around Me")
# puts client.playlistinfo([10,])
# puts client.playlistinfo(1)
# puts client.listall("world/z")
# puts client.update("world/z")
# puts client.listall
# puts client.commands
# puts client.outputs
# puts client.tagtypes
# puts client.search("artist", "Linkin Park").size
# puts client.find("artist", "Порнофильмы")
# puts client.clear
# puts client.findadd("genre", "Alternative Rock")
# puts client.add
# puts client.repeat(false)
# puts client.random(true)
# puts client.replay_gain_status
# puts client.update
# puts client.next
# puts client.previous
# puts client.pause(false)
# puts client.stop
# puts client.play
# puts client.play(2)
# puts client.playid(13)
# puts client.seekcur(20)
# puts client.seekcur("+10")
# puts client.seekid(13, 45)
# puts client.seek(3, 45)
# puts client.list("album", "Linkin Park")
# puts client.list("Genre")

puts "MPD client status: " + (client.connected? ? "connected" : "disconnected")
puts "MPD version: #{client.version}"

client.disconnect
