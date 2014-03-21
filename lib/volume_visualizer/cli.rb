require "json"
require "thor"
require "fileutils"
require "webrick"
require "socket"

module VolumeVisualizer
  class Cli < Thor
    default_task :instaweb

    no_commands do 
      def html_source
        File.expand_path(
          File.join( "..", "..", "assets", "index.html" ),
          File.dirname(__FILE__)
        )
      end

      def volume_data
        if options[:parse_file]
          if options[:parse_file] == "-"
            STDIN.readlines
          else
            unless File.exists? options[:parse_file]
              STDERR.puts "ERROR: file for parsing \"#{options[:parse_file]}\" not found"
              STDERR.puts "       Did you specify an option to --parse-file?"
              STDERR.puts "       Ex: vv --parse-file /tmp/data.txt"
              exit 1
            end
            File.open(options[:parse_file]).readlines
          end
        else
          ZFS::Pool.new(options[:volume]).data
        end
      end

      def zfs
        VolumeVisualizer::ZFS::Base.new(options[:volume], volume_data)
      end
    end



    desc "show-command", "print out the volume manager interrogation command"
    long_desc <<-EOF
      If you don't want Volviz to run as root, you can interrogate your volume
      manager directly with the same command Volviz would use, and then supply
      that output to the parse command.

      EXAMPLE:
      \x5   > `vv show-command` > /tmp/saved-output
      \x5   > vv parse < /tmp/saved-output

    EOF

    method_option :volume, :default => "tank"
    def show_command
      puts ZFS::Pool.query_command options[:volume]
    end

    desc "generate", "generate static output in the specified path"
    long_desc <<-EOF
      By default, Volviz starts up a simple webserver so you can look at the
      visualization right away. If you prefer to generate static output and
      serve it from your own web server, use this command.

      EXAMPLE:
      \x5   > vv generate --output_path /var/www/volviz 

      This will generate two files: index.html and volviz.json. You can 
      optionally use the --data-name parameter to name the volviz file 
      something else. If you use a non-default name, simply append
      ?data=YOURNAME to the URL to index.html.

      EXAMPLE
      \x5 > vv generate --output-path /var/www/volviz --data-name foo
      \x5 # http://your-host/volviz/index.html?data=foo

      You can also specify a different volume to interrogate if you like.

      EXAMPLE
      \x5 > vv generate --output-path /var/www/volviz --volume backup2
      
    EOF
    method_option :volume, :default => "tank"
    method_option :output_path, :required => true
    method_option :data_name, :default => "volviz"
    method_option :parse_file, :type => :string
    def generate
      json_filename = File.join( options[:output_path], options[:data_name] + ".json" )
      File.open(json_filename, "w") do |json|
        json.puts zfs.to_json
      end
      STDERR.puts "generated data file #{json_filename}"

      html_filename = File.join( options[:output_path], "index.html" )
      FileUtils.cp html_source, html_filename
      STDERR.puts "installed #{html_filename}"
    end


    desc "instaweb", "start a simple webserver to serve the visualizer"
    long_desc <<-EOF
      Inspired by git's instaweb command, this will start a simple web server
      on a random port, serving only the Volviz HTML interface and the JSON
      data for your volume. Volviz will generate this data automatically by
      default, or you can provide data using the --parse-file option.

      This web server is meant as a convenience only. It's not a daemon.

    EOF
    method_option :volume, :default => "tank"
    method_option :parse_file, :type => :string
    def instaweb
      port = nil
      begin
        port = rand(20000) + 20000
        server = WEBrick::HTTPServer.new(
          :AccessLog => [],
          :Port => port,
          :Logger => WEBrick::Log::new("/dev/null", 7)
        )
      rescue Errno::EADDRINUSE
        puts "ERROR: port #{port} already in use -- retrying"
        retry
      end

      server.mount_proc "/" do |req, res|
        res.body = File.open(html_source).read
      end

      zfs_data = zfs.to_json
      server.mount_proc "/volviz.json" do |req, res|
        res.body = zfs_data
      end

      trap 'INT' do 
        server.shutdown 
      end

      STDERR.puts "server running on http://#{Socket.gethostname}:#{port}"

      server.start
    end
  end
end



