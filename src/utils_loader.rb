require_relative 'load_exception'

module Arena

	module Loader

		def Loader.assert_object_key(file, obj, key)

			hasKey = obj.keys.include? key

			if(!hasKey)

				raise MissingKeyException.new(file, key)
				return
			end
		end

		def Loader.object_has_key?(obj, key)

			return obj.keys.include? key
		end

	end
end