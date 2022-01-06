module Arena

	module Keywords
        
        def type_supported?(type) 

            supported_datatypes = Array.new()
            supported_datatypes.append("Float")
            supported_datatypes.append("Interval")

            return supported_datatypes.include?(type)
        end

        def operation_supported?(op)

            supported_operations = Array.new()
            supported_operations.append("Distance2DNoised")

            return supported_operations.include?(op)
        end
    end
end