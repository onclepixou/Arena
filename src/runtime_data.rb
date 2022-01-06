
module Arena

	module Runtime

        class RuntimeData

            attr_reader :name    # @return String
            attr_reader :type    # @return String
            attr_accessor :valid   # @return bool
            attr_accessor :value   # NIL or type depending of RuntimeData

            def initialize(name)

                @name = name
                @valid = false
            end 
        end

        class FloatData < RuntimeData
        
            # constructor of deriver class
            def initialize(name)
            
                super(name)
                @type = "Float"
            end

            def set_value(v)

                raise TypeError unless v.is_a? Float
                @value = v
            end
        end

        class IntervalData < RuntimeData
        
            # constructor of deriver class
            def initialize(name)
            
                super(name)
                @type = "Interval"
            end

            def set_value(lb, ub)

                raise TypeError unless lb.is_a? Float
                raise TypeError unless ub.is_a? Float
                @value = [lb, ub]
            end
        end
    end
end