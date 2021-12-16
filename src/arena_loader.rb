require_relative 'layout_loader'
require_relative 'actors_loader'

module Arena

	module Loader

		class ArenaLoader

			attr_reader :layout # @return Layout
			attr_reader :actors # @return Array[Actor]

			def initialize()

				begin

					layoutLoader = LayoutLoader.new()
					@layout = layoutLoader.layout

					actorsLoader = ActorsLoader.new()
					@actors = actorsLoader.actors

					@actors.each{ |a|

						puts a
						puts "\n"
					}

				rescue => e

					puts e.message
				end
			end
		end
	end
end