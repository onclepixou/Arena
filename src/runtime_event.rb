require_relative 'runtime_data'

module Arena

	module Runtime

        class RuntimeEvent

            attr_reader   :name    # @return String
            attr_accessor :data    # @return RuntimeInterval
            attr_reader   :op_type # @return String
            attr_reader   :args    # @return Array[String]

            def initialize(event)

                @name = event.name
                @op_type = event.operation
                @args = event.args
            end 
        end

        class Distance2DEvent < RuntimeEvent
        
            # constructor of deriver class
            def initialize(event)
            
                super(event)
                @data = IntervalData.new(event.name)
            end

            def compute(args)

                val = Math.sqrt((args[2] - args[0])**2 + (args[3] - args[1])**2)
                data.set_value(val, val)
                data.valid = true

                return val
            end
        end
    end
end