require_relative 'runtime_data'
require_relative 'runtime_event'

module Arena

	module Runtime

		class RuntimeActor

            attr_reader   :actor_id             # @return String
			attr_accessor :runtime_data         # @return Hash [name]-->[RuntimeData]
            attr_accessor :runtime_events       # @return Hash [name]-->[RuntimeEvent]
            attr_accessor :triggered            # @return Hash [trigger]-->[Array[String (event name)]]
            attr_reader   :simulation           # reference to simulation object

			def initialize(sim, actor)

				begin

                    @actor_id = actor.actor_id
                    @simulation = sim
                    @runtime_data = Hash.new()
                    @runtime_events = Hash.new()
                    @triggered = Hash.new()

                    actor.data.each{ |data|

                        if(data.type == "Float")

                            runtime_data[data.name] = FloatData.new(data.name)

                        elsif(data.type == "Interval")

                            runtime_data[data.name] = IntervalData.new(data.name)

                        else

                            msgError = "RuntimeError : datatype " + data.type +  " is not a valid type"
                            raise StandardError.new(msgError)
                        end
                    }

                    actor.events.each{ |event|

                        if(event.operation == "Distance2DNoised")
                            @runtime_events[event.name] = Distance2DEvent.new(event)
                        end

                        event.triggers.each{ |trigger|

                            if(@triggered.key?(trigger))

                                @triggered[trigger].append(actor_id  + "." + event.name)

                            else

                                @triggered[trigger] = [actor_id  + "." + event.name]
                            end
                        }
                    }

				rescue => e

					puts e.message
				end
			end

            def set_data_deactivated(dataname)

                runtime_data[dataname].valid = false
                @simulation.propagate_event(@actor_id + ".Update." + dataname)
            end

            def set_float_data_value(dataname, f)

                runtime_data[dataname].set_value(f)
                runtime_data[dataname].valid = true
                @simulation.propagate_event(actor_id + ".Update." + dataname)
            end

            def set_interval_data_value(dataname, lb, ub)

                runtime_data[dataname].set_value(lb, ub)
                runtime_data[dataname].valid = true
                @simulation.propagate_event(actor_id + ".Update." + dataname)
            end

            def call_event(event_id, args)

                puts @actor_id + " : " + event_id
                val = @runtime_events[event_id].compute(args)
                @simulation.propagate_event(@actor_id + ".Event." + event_id + " " + val.to_s)
            end
		end
	end
end