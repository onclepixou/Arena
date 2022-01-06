require_relative 'actors_loader'

module Arena

	module Loader

		class ArenaLoader

			attr_reader :actors # @return Array[Actor]

			def initialize()

				begin

					actorsLoader = ActorsLoader.new()
					@actors = actorsLoader.actors

				rescue => e

					puts e.message
				end
			end
		end
	end
end