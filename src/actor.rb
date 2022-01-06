require 'colorize'

module Arena

    module Datatypes

        class Actor

        	attr_accessor :actor_id  # @return String
        	attr_accessor :data      # @return Array[Data]
        	attr_accessor :events    # @return Array[Event]

        	def initialize()

        		@actor_id = ""
                @data = Array.new()
        		@events = Array.new()
        	end
        end

        class Data

            attr_accessor :name # @return String
            attr_accessor :type # @return String

            def initialize()

            end
        end

        class Event

        	attr_accessor :name        # @return String
            attr_accessor :type        # @return String
        	attr_accessor :triggers    # @return Array[String]       
        	attr_accessor :operation   # @return String
            attr_accessor :args        # @return Array[String]

        	def initialize()

        		@triggers = Array.new()
        		@args = Array.new()
        	end
        end
    end
end