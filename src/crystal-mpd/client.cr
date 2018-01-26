module MPD
  class Client
    alias Object = Hash(String, String)
    alias Objects = Array(Object)
    alias Pair = Array(String)
    alias Pairs = Array(Pair)

    @version : String?

    HELLO_PREFIX = "OK MPD "
    ERROR_PREFIX = "ACK "
    SUCCESS      = "OK"
    NEXT         = "list_OK"

    getter host, port, version

    # Creates a new MPD client. Parses the *host*, *port*.
    #
    # ```
    # client = MPD::Client.new("localhost", 6600)
    # puts client.version
    # puts client.status
    # puts client.stats
    # client.disconnect
    # ```
    #
    # This constructor will raise an exception if could not connect to MPD
    def initialize(
      @host : String = "localhost",
      @port : Int32 = 6600
    )
      connect
    end

    def connect
      reconnect unless connected?
    end

    def disconnect
      @socket.try do |socket|
        socket.close
      end

      reset
    end

    def connected?
      @socket.is_a?(Socket)
    end

    def reconnect
      @socket = TCPSocket.new(host.not_nil!, port)
      hello
    end

    def hello
      @socket.try do |socket|
        response = socket.gets(chomp: false)
        if response
          raise MPD::Error.new("Connection lost while reading MPD hello") unless response.ends_with?("\n")
          response = response.chomp
          raise MPD::Error.new("Got invalid MPD hello: #{response}") unless response.starts_with?(HELLO_PREFIX)
          @version = response[/#{HELLO_PREFIX}(.*)/, 1]
        end
      end
    end

    UNIMPLEMENTED_METHODS = [
      "add", "addid", "addtagid",
      "channels", "clear", "clearerror", "cleartagid", "close",
      "config", "count", "crossfade", "currentsong",
      "decoders", "delete", "deleteid", "disableoutput",
      "enableoutput",
      "find", "findadd",
      "idle",
      "kill",
      "list", "listallinfo", "listfiles", "listmounts", "listplaylist",
      "listplaylistinfo", "listplaylists", "load", "lsinfo",
      "mixrampdb", "mixrampdelay", "mount", "move", "moveid",
      "next", "notcommands",
      "outputs",
      "password", "pause", "ping", "play", "playid", "playlist", "playlistadd",
      "playlistclear", "playlistdelete", "playlistfind", "playlistid",
      "playlistmove", "playlistsearch", "plchanges", "plchangesposid",
      "previous", "prio", "prioid",
      "rangeid", "readcomments", "readmessages", "rename",
      "replay_gain_mode", "rescan", "rm",
      "save", "searchadd", "searchaddpl", "seek", "seekcur", "seekid",
      "sendmessage", "setvol", "shuffle",
      "sticker", "stop", "subscribe", "swap", "swapid",
      "tagtypes", "toggleoutput",
      "unmount", "unsubscribe", "urlhandlers",
      "volume",
    ]

    {% for method in UNIMPLEMENTED_METHODS %}
      def {{method.id}}
        raise  "Method not yet implemented."
      end
    {% end %}

    def commands
      @socket.try do |socket|
        socket.puts("commands")

        return fetch_list
      end
    end

    def listall
      @socket.try do |socket|
        socket.puts("listall")

        return fetch_objects(["file", "directory", "playlist"])
      end
    end

    def playlistinfo
      @socket.try do |socket|
        socket.puts("playlistinfo")

        return fetch_objects(["file"])
      end
    end

    def search(type : String, query : String) : Objects
      @socket.try do |socket|
        socket.puts("search \"#{type}\" \"#{query}\"")

        return fetch_objects(["file"])
      end

      return Objects.new
    end

    def replay_gain_status
      @socket.try do |socket|
        socket.puts("replay_gain_status")

        return fetch_item
      end
    end

    # Updates the music database: find new files, remove deleted files, update modified files.
    #
    # Options:
    # * **uri**: a particular directory or song/file to update. If you do not specify it, everything is updated.
    def update(uri : String? = nil)
      @socket.try do |socket|
        if uri
          uri = escape(uri)
          command = "update \"#{uri}\""
        else
          command = "update"
        end

        socket.puts(command)

        return fetch_item
      end
    end

    {% for method in ["status", "stats"] %}
      def {{method.id}}
        @socket.try do |socket|
          socket.puts({{method}})

          return fetch_object
        end
      end
    {% end %}

    {% for method in ["consume", "random", "repeat", "single"] %}
      def {{method.id}}(state : Bool)
        @socket.try do |socket|
          socket.puts("{{method.id}} #{boolean(state)}")

          return fetch_nothing
        end
      end
    {% end %}

    private def fetch_nothing
      line = read_line
      raise MPD::Error.new("Got unexpected return value: #{line}") unless line.nil?
    end

    private def fetch_list
      result = [] of String
      seen = nil
      read_pairs.each do |item|
        key = item[0]
        value = item[1]

        if key != seen
          if seen != nil
            raise MPD::Error.new("Expected key '#{seen}', got '#{key}'")
          end
          seen = key
        end
        result << value
      end

      return result
    end

    private def fetch_object : Object
      fetch_objects.first
    end

    private def fetch_objects(delimiters = [] of String) : Objects
      result = Objects.new
      obj = Object.new

      read_pairs.each do |item|
        key = item[0]
        value = item[1]

        if delimiters.includes?(key)
          result << obj unless obj.empty?
          obj = Object.new
        end

        obj[key] = value
      end

      result << obj unless obj.empty?

      return result
    end

    private def read_pairs : Pairs
      pairs = Pairs.new

      pair = read_pair
      unless pair.empty?
        pairs << pair
        pair = read_pair
      end

      return pairs
    end

    private def read_pair : Pair
      line = read_line
      return Pair.new if line.nil?
      pair = line.split(": ", 2)
      return pair
    end

    private def fetch_item : String
      pairs = read_pairs
      return "" if pairs.size != 1
      return pairs[0][1]
    end

    private def read_line : String?
      @socket.try do |socket|
        line = socket.gets(chomp: true)

        if line.not_nil!.starts_with?(ERROR_PREFIX)
          error = line.not_nil![/#{ERROR_PREFIX}(.*)/, 1].strip
          raise MPD::Error.new(error)
        end

        return if line == SUCCESS

        return line
      end
    end

    private def reset
      @socket = nil
      @version = nil
    end

    private def boolean(value : Bool)
      value ? "1" : "0"
    end

    private def escape(str : String)
      str.gsub(%(\\), %(\\\\)).gsub(%("), %{\\"})
    end
  end
end
