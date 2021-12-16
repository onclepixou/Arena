#! /usr/bin/ruby

require_relative 'arena_loader'

if caller.length == 0

	Arena::Loader::ArenaLoader.new()
end