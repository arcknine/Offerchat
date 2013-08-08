Fabricator(:stripe_message) do
  response '{
              "id": "evt_2LTxifbbbAsc8h",
              "created": 1375943646,
              "livemode": false,
              "type": "customer.subscription.updated",
              "data": {
                "object": {
                  "plan": {
                    "interval": "month",
                    "name": "Business",
                    "amount": 5900,
                    "currency": "usd",
                    "id": "BUSINESS",
                    "object": "plan",
                    "livemode": false,
                    "interval_count": 1,
                    "trial_period_days": null
                  },
                  "object": "subscription",
                  "start": 1375943646,
                  "status": "active",
                  "customer": "cus_2KkYjZN5dYuAcx",
                  "cancel_at_period_end": false,
                  "current_period_start": 1375774731,
                  "current_period_end": 1378453131,
                  "ended_at": null,
                  "trial_start": null,
                  "trial_end": null,
                  "canceled_at": null,
                  "quantity": 1
                },
                "previous_attributes": {
                  "plan": {
                    "interval": "month",
                    "name": "Personal",
                    "amount": 2900,
                    "currency": "usd",
                    "id": "PERSONAL",
                    "object": "plan",
                    "livemode": false,
                    "interval_count": 1,
                    "trial_period_days": null
                  },
                  "start": 1375943613
                }
              },
              "object": "event",
              "pending_webhooks": 0,
              "request": "iar_2LTxWXlGIEqBnI"
            }'
end
