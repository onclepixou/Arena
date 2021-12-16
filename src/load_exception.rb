module Arena

	module Loader

		class 	MissingKeyException < StandardError

			def initialize(file, key)

				msg = "MissingKeyError : " + file + " does not have key " + key + "\nPlease refer to documentation"
				super(msg)
			end
		end

		class VariableTypeException < StandardError

			def initialize(file, variable, type)

				msg = "VariableTypeError : variable " + variable + " declared in " + file + " does not have a supported type " + type + "\nPlease refer to documentation"
				super(msg)
			end
		end

		class OperationTypeException < StandardError

			def initialize(file, operation)

				msg = "OperationTypeError : operation " + operation + " declared in " + file + " is not supported" + "\nPlease refer to documentation"
				super(msg)
			end
		end

	end
end