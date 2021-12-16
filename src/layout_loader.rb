require 'json'
require_relative 'load_exception'

module Arena

	module Loader

		class LayoutLoader

			attr_reader :layout_filename # @return Layout filename
			attr_accessor :layout        # @return Layout

			def initialize()

				@layout_filename = "Layout/Layout.json"
				@layout = Layout.new()

				begin 

					json = File.read(@layout_filename)
					obj = JSON.parse(json)
					parse_layout(obj)

				rescue Errno::ENOENT => e

					msgError = "LoadError : " + @layout_filename +  " does not exist"
					raise StandardError.new(msgError)

				rescue JSON::ParserError

					msgError = "ParserError : " + @layout_filename +  " is not a valid json"
					raise StandardError.new(msgError)
				end

				puts "Successful loading of layout " + @layout_filename 
			end

			def parse_layout(obj)

				begin

					hasOriginKey = obj.keys.include? 'Origin'
					hasSizeKey = obj.keys.include? 'Size'

					if(!hasOriginKey)

						raise MissingKeyException.new(@layout_filename, "Origin")
						return
					end

					if(!hasSizeKey)

						raise MissingKeyException.new(@layout_filename, "Size")
						return
					end
				end

				origin = obj['Origin']

				hasOriginXKey = origin.keys.include? 'x'
				hasOriginYKey = origin.keys.include? 'y'

				if(!hasOriginXKey)

					raise MissingKeyException.new(@layout_filename, "Origin/x")
					return
				end

				if(!hasOriginYKey)

					raise MissingKeyException.new(@layout_filename, "Origin/y")
					return
				end

				@layout.origin_x = origin['x']
				@layout.origin_y = origin['y']

				size = obj['Size']

				hasSizeXKey = size.keys.include? 'xdim'
				hasSizeYKey = size.keys.include? 'ydim'

				if(!hasSizeXKey)

					raise MissingKeyException.new(@layout_filename, "Size/xdim")
					return
				end

				if(!hasSizeYKey)

					raise MissingKeyException.new(@layout_filename, "Origin/y")
					return
				end

				@layout.dim_x = size['xdim']
				@layout.dim_y = size['ydim']
			end
		end

		class Layout

			attr_accessor :origin_x # @return float
			attr_accessor :origin_y # @return float
			attr_accessor :dim_x    # @return float
			attr_accessor :dim_y    # @return float

			def initialize(ox=0, oy=0, xdim=0, yDim=0)

				origin_x = ox
				origin_y = oy
				dim_x = xdim
				dim_y = yDim
			end

			def to_s()

				msg = 'Arena Layout :' + "\n"
				msg += '├─ ' + "Origin : {" + origin_x.to_s + ", " + origin_y.to_s + '}' + "\n"
				msg += '└─ ' + "Size : {" + dim_x.to_s + ", " + dim_y.to_s + '}' + "\n"

				return msg
			end
		end
	end
end