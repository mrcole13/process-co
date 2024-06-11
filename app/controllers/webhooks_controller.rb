class WebhooksController < ApplicationController

    def create
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']
        event = nil
        begin
          event = Stripe::Webhook.construct_event(
            payload, sig_header, ENV['STRIPE_ENDPOINT_SECRET']
          )
        rescue JSON::ParserError => e
          # Invalid payload
          render json: { error: { message: e.message }}, status: :bad_request
          return
        rescue Stripe::SignatureVerificationError => e
          # Invalid signature
          render json: { error: { message: e.message, extra: "Sig verification failed" }}, status: :bad_request
          return
        end
        # Handle the event
        case event.type
        when 'checkout.session.async_payment_succeeded'
            event_object = event.data.object
            payment = Payment.find_by(link_id: event_object.payment_link)
            if payment.present?
                payment.status = event_object.payment_status
                payment.save
            end
            #TODO: Transfer money to property management connected account, optional
            Stripe::Transfer.create({
                amount: 400,
                currency: 'usd',
                destination: 'acct_1MTfjCQ9PRzxEwkZ',#TODO: Where to grab prop mgmnt id?
                transfer_group: 'ORDER_95',#TODO: Do I need this? Perhaps this is just property name or resident id?
            })
            #TODO: CALL BUZZ ENDPOINT HERE
            puts 'Payment Succeeded!'
        else
          puts "Unhandled event type: #{event.type}"
        end
    
        render json: { message: :success }
    end
end
