require "../src/crystal-mpd"

client = MPD::Client.new

puts "MPD host: #{client.host}"
puts "MPD port: #{client.port}"
puts "MPD version: #{client.version}"

# puts client.status
# puts client.stats
# puts client.playlistinfo(1)
# puts client.playlistinfo([10,])
# puts client.listall("world/z")
# puts client.update("world/z")
# puts client.listall
# puts client.commands
# puts client.search("artist", "Linkin Park").size
# puts client.add
# puts client.repeat(false)
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

client.disconnect
puts "MPD client status: " + (client.connected? ? "connected" : "disconnected")
puts "MPD version: #{client.version}"
