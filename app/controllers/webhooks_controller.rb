class WebhooksController < ApplicationController
    include ActionView::Helpers::NumberHelper
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
            #Transfer money to property management connected account, if exists
            property = payment.property    
            if property.property_manager.present?  
                transfer_amount = payment.amount.to_i * property.property_manager.fee_percentage.to_i/100
                Stripe::Transfer.create({
                    amount: transfer_amount * 100,
                    currency: 'usd',
                    destination: property.property_manager.stripe_id,
                    transfer_group: 'ORDER_95',#TODO: Do I need this? Perhaps this is just property name or resident id?
                })
                puts 'Transfer Succeeded!'
            end
            #TODO: CALL BUZZ ENDPOINT HERE
            puts 'Payment Succeeded!'
        when 'account.application.authorized'
            stripe_id = event.account
            property = Property.find_by(stripe_id: stripe_id)
            if !property.present?
                stripe_account = Stripe::Account.retrieve(stripe_id)
                property = Property.new(stripe_id: stripe_id)
                property.name = stripe_account.business_profile.name
                property.save
            end  
            puts 'Property Connected Successfully'
        else
          puts "Unhandled event type: #{event.type}"
        end
    
        render json: { message: :success }
    end
end
