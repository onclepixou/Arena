require_relative 'runtime_actor'
require 'thread'
require 'colorize'

module Arena

	module Runtime

		class Simulation

            attr_reader :runtime_actors # @return Hash [actorId]-->[RuntimeActor]

			def initialize(actor_array)

				begin

                    @runtime_actors = Hash.new()
                    actor_array.each{ |actor|

                        @runtime_actors[actor.actor_id] = Arena::Runtime::RuntimeActor.new(self, actor)
                    }

					@thread_queue = Queue.new()
					@service_thread = Thread.new{catch_input}
					simulate()
					@service_thread.join()

				rescue TypeError => e

					puts e.message
				end
			end

			def catch_input()

				while(true)

					print ">> "
					cmd = gets
					obj = interpreter(cmd)

					if(obj != nil)

						@thread_queue << obj
					end			
				end
			end

			def simulate()

				while(true)

					while(!@thread_queue.empty?)

						command = @thread_queue.pop
						interpreter(command)
					end
				end
			end

			def propagate_event(event)

				puts "Caught event ".light_blue.bold + event.light_blue.bold 

				events_list= Set.new()

				@runtime_actors.each do |name, actor|

					if(actor.triggered.key?(event))

						actor.triggered[event].each{ |scheduled_event|

							events_list.add(scheduled_event)
						}
					end
				end

				events_list.each{|event|
				
					data = event.split(".")
					actor_id = data[0]
					event_id = data[1]
					
					call_event(actor_id, event_id)
				}
			end

			def interpreter(command)

				allowed_command = ["deactivate", "update"]

				if( command == "\n")

					return nil
				end

				tokens = command.split
				if(!allowed_command.include?(tokens[0]))

					puts "└─ Error : invalid command ".light_red.bold + tokens[0].light_red.bold
					return nil
				end

				if(tokens[0] == "deactivate")

					return parse_deactivate(tokens.slice(1, tokens.length))
				end

				if(tokens[0] == "update")

					return parse_update(tokens.slice(1, tokens.length))
				end

			end

			def call_event(actor_id, event_id)

				event = @runtime_actors[actor_id].runtime_events[event_id]
				args = event.args
				data_args = Array.new()
				args.each{|arg| 

					data = arg.split(".")
					obj = @runtime_actors[data[0]].runtime_data[data[1]]

					if(!obj.valid)

						puts "Event " + actor_id + "." + event_id + " cannot be evaluated because " +  arg + " is not valid currently"
						return nil					
					end

					res = data_args.append(obj.value)

				}
				
				event.compute(data_args)
				@runtime_actors[actor_id].call_event(event_id, data_args)
			end

			def parse_deactivate(args)

				if(args.length <=0)

					puts "└─ Error : bad arguments provided for command deactivate".light_red.bold
				end

				
				if(data_exist?(args[0]))

					data = args[0].split(".")
					@runtime_actors[data[0]].set_data_deactivated(data[1])
					puts "└─ OK".light_green.bold
					return nil

				elsif 

					puts "└─ Error : unknown data ".light_red.bold + args[0].light_red.bold
				end
			end

			def parse_update(args)

				
				if(!data_exist?(args[0]))

					puts "└─ Error : unknown data ".light_red.bold + args[0].light_red.bold
					return nil
				end

				datatype = data_type(args[0])

				if(datatype == "Float")

					if(args.length != 2)

						puts "└─ Error : bad arguments provided for update of float data".light_red.bold
						return nil
					end

					if(valid_float?(args[1]))

						data = args[0].split(".")
						val = Float(args[1])
						@runtime_actors[data[0]].set_float_data_value(data[1], val)
						puts "└─ OK".light_green.bold

					else

						puts "└─ Error : ".light_red.bold + args[1].light_red.bold + " is not a valid float".light_red.bold
						return nil
					end
	
				elsif(datatype == "Interval")

					if(args.length != 3)

						puts "└─ Error : bad arguments provided for update of interval data".light_red.bold
						return nil
					end

					if(valid_float?(args[1]) && valid_float?(args[2]))

						lb = Float(args[1])
						ub = Float(args[2])

						if(lb <= ub)

							data = args[0].split(".")
							@runtime_actors[data[0]].set_interval_data_value(data[1], lb, ub)
							puts "└─ OK".light_green.bold
							return nil
						else

							puts "└─ Error : lower bound must be inferior to upper bound".light_red.bold
							return nil
						end
						
					else

						puts "└─ Error : ".light_red.bold + args[1].light_red.bold + "and" + args[2].light_red.bold + " are not valid interval bounds".light_red.bold
						return nil
					end

				else

					puts "Unknown data"
				end
			end

			def data_exist?(dataname)

				data = dataname.split(".")
				return (@runtime_actors.key?(data[0]) && (@runtime_actors[data[0]].runtime_data.key?(data[1])))
			end

			def data_type(dataname)

				if(!data_exist?(dataname))

					return nil
				end

				data = dataname.split(".")

				return @runtime_actors[data[0]].runtime_data[data[1]].type
			end

			def valid_float?(str)

				!!Float(str) rescue false
			end
		end
	end
end