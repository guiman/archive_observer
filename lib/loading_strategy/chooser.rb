require 'loading_strategy/pr_strategy/handler'
require 'loading_strategy/push_strategy/handler'
require 'loading_strategy/null_strategy/handler'

module LoadingStrategy
  class Chooser
    BINDINGS = {
      "PullRequestEvent" => LoadingStrategy::PRStrategy::Handler,
      "PushEvent" => LoadingStrategy::PushStrategy::Handler
    }

    def self.can_be_parsed?(event)
      (event.fetch("type") == "PullRequestEvent" &&
        event.fetch("payload").fetch("action") == "opened") ||
      (event.fetch("type") == "PushEvent")
    end

    def self.from_event(event)
      BINDINGS.fetch(event.fetch("type"), LoadingStrategy::NullStrategy::Handler).new(event)
    end
  end
end
