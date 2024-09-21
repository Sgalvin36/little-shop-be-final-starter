class ErrorSerializer
    def self.format_errors(messages)
        {
            message: 'Your query could not be completed',
            errors: messages
        }
    end

    def self.format_invalid_search_response
        { 
            message: "your query could not be completed", 
            errors: ["invalid search params"] 
        }
    end

    def self.format_unique(message)
        parts = message.to_s.split("\n")
        parts[0].delete_prefix!("ERROR:  ")
        parts[1].delete_prefix!("DETAIL:  ")
        {
            message: parts[1],
            errors: parts[0]
        }
    end
end