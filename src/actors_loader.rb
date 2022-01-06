require 'json'
require 'colorize'

require_relative 'load_exception'
require_relative 'actor'
require_relative 'supported'
require "dry-schema"

module Arena

	module Loader

		class ActorsLoader

			include Arena::Datatypes
			include Arena::Keywords

			attr_reader :actors_dir      # @return String
			attr_reader :actors_filename # @return String
			attr_reader :actors_schema   # @return dry-schema
			attr_accessor :actors        # @return Array[Actor]

			def initialize()

				@actors_dir = "Actors"
				@actors_filename = "Actor_*.json"
				@actors_schema = load_schema()
				@actors = Array.new()

				Dir.glob(@actors_dir + "/**/" + actors_filename ).select{ |e|
					
					File.file? e
					load_actor(e)
				}

				validate_actors()
			end

			def load_schema()

				schema = Dry::Schema.JSON do

					required(:ActorId).filled(:string)

					required(:Data).array(:hash) do
						required(:Name).filled(:string)
						required(:Type).filled(:string)
					end

					required(:Events).array(:hash) do
						required(:Name).filled(:string)
						required(:Type).filled(:string)
						required(:Triggers).each(:string)
						required(:Operation).filled(:string)
						required(:Arguments).each(:string)
					end

				end

				return schema
			end

			def load_actor(file)

				begin 

					json = File.read(file)
					obj = JSON.parse(json)

					result = @actors_schema.call(obj)

					if(!result.success?)

						msgError = "FormatError : " + file +  " does not match allowed schema.\nPleasde Refer to documentation"
						raise StandardError.new(msgError)
					end

					parse_actor(obj)
	
				rescue Errno::ENOENT => e

					msgError = "LoadError : " + file +  " does not exist"
					raise StandardError.new(msgError)

				rescue JSON::ParserError

					msgError = "ParserError : " + file +  " is not a valid json"
					raise StandardError.new(msgError)
				end

				puts "Successful loading of actor " + file
			end

			def parse_actor(obj)

				# Object to store actor data

				new_actor = Actor.new();

				# Set actor id
				new_actor.actor_id  = obj['ActorId']
				if(!identifier_name_valid?(new_actor.actor_id))

					msgError = "ContentError : " + new_actor.actor_id + " is not a valid actor name"
					raise StandardError.new(msgError)
				end

				# Set actor data
				data = obj['Data']

				data.each{ |element|
				
					newData = Data.new()
					newData.name = element["Name"]
					newData.type = element["Type"]

					if(!identifier_name_valid?(newData.name))

						msgError = "ContentError : data " + newData.name  + " from actor " + new_actor.actor_id +  " is not a valid data name"
						raise StandardError.new(msgError)
					end

					if(!type_supported?(newData.type))

						msgError = "ContentError : datatype " + newData.type + " of " + newData.name  + " from actor " + new_actor.actor_id +  " is not a valid type"
						raise StandardError.new(msgError)
					end

					new_actor.data.append(newData)
				}

				# Set actor events
				events = obj['Events']

				events.each{ |element|
				
					newEvent = Event.new()
					newEvent.name = element["Name"]
					newEvent.type = element["Type"]
					newEvent.triggers = element["Triggers"]
					newEvent.operation = element["Operation"]
					newEvent.args = element["Arguments"]

					if(!identifier_name_valid?(newEvent.name))

						msgError = "ContentError : event " + newEvent.name  + " from actor " + new_actor.actor_id +  " is not a valid event name"
						raise StandardError.new(msgError)
					end

					if(!type_supported?(newEvent.type))

						msgError = "ContentError : datatype " + newEvent.type + " of " + newEvent.name  + " from actor " + new_actor.actor_id +  " is not a valid type"
						raise StandardError.new(msgError)
					end

					new_actor.events.append(newEvent)
				}

				@actors.append(new_actor)
			end

			def validate_actors()

				# check if there is no duplicate in actor name
				actors_name = Array.new()
		
				@actors.each{ |actor|

					if(actors_name.include?(actor.actor_id))

						msgError = "ContentError : multiple declaration of actor name " + actor.actor_id
						raise StandardError.new(msgError)
					end
					actors_name.append(actor.actor_id)

					data_names = Array.new()
					# iterate through actor data
					actor.data.each{ |data|

						# check if there is no duplicate in actor data
						if(data_names.include?(data.name))

							msgError = "ContentError : data " + data.name + " has been declared several time in actor " + actor.actor_id
							raise StandardError.new(msgError)
						end
						data_names.append(data.name)
					}

					events_names = Array.new()
					# iterate through actor event
					actor.events.each{ |event|

						# check if event name is not a duplicate
						if(events_names.include?(event.name))

							msgError = "ContentError : event " + event.name + " has been declared several time in actor " + actor.actor_id
							raise StandardError.new(msgError)
						end
						events_names.append(event.name)

						event.triggers.each{ |trigger|

							params = trigger.split(".")
							if(!actor_exist?(params[0]))

								msgError = "ContentError : trigger item" + trigger + " from event " + event.name + " of actor " + actor.actor_id + " refers to unknown actor " + params[0]
								raise StandardError.new(msgError)
							end
							
							if(params[1] == "Update")

								if(!data_exist?(params[0], params[2]))

									msgError = "ContentError : trigger item" + trigger + " from event " + event.name + " of actor " + actor.actor_id + " refers to unknown data " + params[2]
									raise StandardError.new(msgError)
								end

							elsif(params[1] == "Event")

								if(!event_exist?(params[0], params[2]))

									msgError = "ContentError : trigger item" + trigger + " from event " + event.name + " of actor " + actor.actor_id + " refers to unknown event " + params[2]
									raise StandardError.new(msgError)
								end

							else 

								msgError = "ContentError : trigger item" + trigger + " from event " + event.name + " of actor " + actor.actor_id + " uses invalid comment " + params[1]
								raise StandardError.new(msgError)
							end
						}

						if(!operation_supported?(event.operation))

							msgError = "ContentError : operation " + event.operation + " from event " + event.name + " of actor " + actor.actor_id + " is invalid"
							raise StandardError.new(msgError)
						end
					}	
				}
			end

			def identifier_name_valid?(name)

				return name =~ /^[_a-zA-Z][a-zA-Z0-9_]+$/
			end

			def actor_exist?(tested_actor)

				@actors.each{ |actor|

					if(actor.actor_id == tested_actor)

						return true
					end
				}

				return false
			end

			def data_exist?(tested_actor, tested_data)

				@actors.each{ |actor|

					if(actor.actor_id == tested_actor)

						actor.data.each{ |data|

							if(data.name == tested_data)

								return true
							end
						}
					end
				}

				return false
			end

			def event_exist?(tested_actor, tested_event)

				@actors.each{ |actor|

					if(actor.actor_id == tested_actor)

						actor.event.each{ |event|

							if(event.name == tested_event)

								return true
							end
						}
					end
				}

				return false
			end

		end
	end
end