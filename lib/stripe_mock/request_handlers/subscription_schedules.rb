module StripeMock
  module RequestHandlers
    module SubscriptionSchedule
      ALLOWED_PARAMS = [
        :current_phase,
        :customer,
        :metadata,
        :phases,
        :status,
        :subscription,
        :object,
        :canceled_at,
        :completed_at,
        :created,
        :default_settings,
        :end_behavior,
        :livemode,
        :released_at,
        :released_subscription
      ]

      def SubscriptionSchedule.included(klass)
        klass.add_handler 'post /v1/subscription_schedules',      :new_subscription_schedule
        klass.add_handler 'get /v1/subscription_schedules',       :get_subscription_schedules
        klass.add_handler 'get /v1/subscription_schedules/(.*)',  :get_subscription_schedule
        klass.add_handler 'post /v1/subscription_schedules/(.*)/cancel', :cancel_subscription_schedule
      end

      def new_subscription_schedule(route, method_url, params, headers)
        id = new_id('sub_sched')

        subscription_schedules[id] = Data.mock_subscription_schedule(
          params.merge(id: id)
        )

        subscription_schedules[id].clone
      end

      def get_subscription_schedules(route, method_url, params, headers)
        params[:offset] ||= 0
        params[:limit] ||= 10

        clone = subscription_schedules.clone

        if params[:customer]
          clone.delete_if { |k,v| v[:customer] != params[:customer] }
        end

        Data.mock_list_object(clone.values, params)
      end

      def get_subscription_schedule(route, method_url, params, headers)
        route =~ method_url
        subscription_schedule_id = $1 || params[:subscription_schedule]
        subscription_schedule = assert_existence :subscription_schedule, subscription_schedule_id, subscription_schedules[subscription_schedule_id]

        subscription_schedule = subscription_schedule.clone
        subscription_schedule
      end

      def cancel_subscription_schedule(route, method_url, params, headers)
        route =~ method_url
        subscription_schedule = assert_existence :subscription_schedule, $1, subscription_schedules[$1]

        subscription_schedule[:status] = 'canceled'
        subscription_schedule[:canceled_at] = Time.now.to_i
        subscription_schedule
      end
    end
  end
end
