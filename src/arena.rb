#!/usr/bin/env ruby 
require_relative 'arena_loader'
require_relative 'simulation'

if caller.length == 0

	loader = Arena::Loader::ArenaLoader.new()
	Arena::Runtime::Simulation.new(loader.actors)

end