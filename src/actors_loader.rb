require 'json'
require 'colorize'

require_relative 'load_exception'
require_relative 'utils_loader'

module Arena

	module Loader

		class ActorsLoader

			attr_reader :actors_dir      # @return String
			attr_reader :actors_filename # @return String
			attr_accessor :actors        # @return Array[Actor]

			def initialize()

				@actors_dir = "Actors"
				@actors_filename = "Actor_*.json"
				@actors = Array.new()

				Dir.glob(@actors_dir + "/**/" + actors_filename ).select{ |e|
					
					File.file? e
					load_actor(e)				
				}
			end

			def load_actor(file)

				begin 

					json = File.read(file)
					obj = JSON.parse(json)
					parse_actor(file, obj)

				rescue Errno::ENOENT => e

					msgError = "LoadError : " + file +  " does not exist"
					raise StandardError.new(msgError)

				rescue JSON::ParserError

					msgError = "ParserError : " + file +  " is not a valid json"
					raise StandardError.new(msgError)
				end

				puts "Successful loading of actor " + file
			end

			def parse_actor(file, obj)

				# Object to store actor data
				new_actor = Actor.new();

				Arena::Loader.assert_object_key(file, obj, 'ActorId')
				Arena::Loader.assert_object_key(file, obj, 'Events')

				# Set actor id
				new_actor.actor_id  = obj['ActorId']

				# Load events
				events = obj['Events']
				event_list = events.keys

				event_list.each{ |event_name|

					actor_event = parse_event(file, events[event_name], event_name)
					new_actor.events.append(actor_event)
				}

				@actors.append(new_actor)
			end

			def parse_event(file, obj, name)

					actor_event = Event.new()

					actor_event.name = name

					Arena::Loader.assert_object_key(file, obj, 'SignalInformation')
					Arena::Loader.assert_object_key(file, obj, 'TriggeredOnSignals')

					info = obj['SignalInformation']
					signal_info = parse_signal_information(file, info)
					actor_event.signal_information = signal_info

					update_triggers = obj['TriggeredOnSignals']
					update_triggers.each{ |trigger|

						actor_event.updated_on_signals.append(trigger)
					}

					if(Arena::Loader.object_has_key?(obj, 'Rule'))

						rule = obj['Rule']
						event_rule = parse_rule(file, rule)
						actor_event.rule = event_rule
					end

					return actor_event
			end

			def parse_signal_information(file, obj)

				Arena::Loader.assert_object_key(file, obj, 'type')
				Arena::Loader.assert_object_key(file, obj, 'datatype')
				Arena::Loader.assert_object_key(file, obj, 'dimension')

				variable = SignalInformation.new()
				variable.type = obj['type']
				variable.datatype = obj['datatype']
				variable.dimension = obj['dimension']

				return variable
			end

			def parse_rule(file, obj)

				Arena::Loader.assert_object_key(file, obj, 'Operation')
				Arena::Loader.assert_object_key(file, obj, 'Argument')

				rule = Rule.new()
				rule.operation = obj['Operation']

				args = obj['Argument']
				args.each{ |arg|

					rule.arguments.append(arg)
				}

				return rule
			end
		end

		class Actor

			attr_accessor :actor_id  # @return String
			attr_accessor :events    # @return Array[Event]

			def initialize()

				@actor_id = ""
				@events = Array.new()
			end

			def to_s()

				str = ""
				str = "Actor".light_blue.bold + " ID : " + @actor_id.to_s.light_green.bold + "\n"
				str += "├─ " + "EventList ".light_blue.bold + "\n"

				@events.each_with_index do |element, index|

					link1 = (index != (@events.size() -1 )) ? "├─ " : "└─ "
					link2 = (index != (@events.size() -1 )) ? "│  " : "   "
					has_rule = (element.rule != nil)
					
					str += "│  " + link1 + "Event : ".light_blue.bold + element.name.light_green.bold + "\n"
					str += "│  " + link2 + "├─ " + "SignalInformation ".light_blue.bold + "\n"
					str += "│  " + link2 + "│  " + "├─ " + "Type : ".light_blue.bold + element.signal_information.type.to_s.light_green.bold  + "\n"
					str += "│  " + link2 + "│  " + "├─ " + "Datatype : ".light_blue.bold + element.signal_information.datatype.to_s.light_green.bold  + "\n"
					str += "│  " + link2 + "│  " + "└─ " + "Dimension : ".light_blue.bold + element.signal_information.dimension.to_s.light_green.bold + "\n"
					str += "│  " + link2 + "├─ " + "TriggeredOnSignals : ".light_blue.bold + "\n"
					str += "│  " + link2 + "│  " + "├─ " + "this.x".light_green.bold + "\n"
					str += "│  " + link2 + "│  " + "├─ " + "this.y".light_green.bold + "\n"
					str += "│  " + link2 + "│  " + "├─ " + "LM1.x".light_green.bold + "\n"
					str += "│  " + link2 + "│  " + "└─ " + "LM1.y".light_green.bold + "\n"

					if(!has_rule)

						str += "│  " + link2 + "└─ " + "Rule ".light_blue.bold + "(None)".light_red.bold + "\n"
					
					else

						str += "│  " + link2 + "└─ " + "Rule".light_blue.bold + "\n"
						str += "│  " + link2 + "   " + "├─ " + "Operation : ".light_blue.bold + element.rule.operation.to_s.light_green.bold  + "\n"
						str += "│  " + link2 + "   " + "└─ " + "Argument ".light_blue.bold + "\n"
						
						element.rule.arguments.each_with_index do |arg, i|

							link3 = (i != (element.rule.arguments.size() -1 )) ? "├─ " : "└─ "
							str += "│  " + link2 + "   " + "   " + link3 + arg.to_s.light_green.bold + "\n"
						end
					end
					
				end

				return str
			end
		end

		class SignalInformation

			attr_accessor :type      # @return String
			attr_accessor :datatype  # @return String
			attr_accessor :dimension # @return String

			def initialize()

			end
		end

		class Event

			attr_accessor :name                      # @return String
			attr_accessor :signal_information        # @return SignalInformation
			attr_accessor :updated_on_signals        # @return Array[String]
			attr_accessor :rule                      # @return Rule


			def initialize()

				@updated_on_signals = Array.new()
				@rule = nil
			end
			
			def has_rule?

				return @rule.nil?
			end
		end

		class Rule

			attr_accessor :operation # @return String
			attr_accessor :arguments # @return Array[String]

			def initialize()

				@arguments = Array.new()
			end
		end

	end
end