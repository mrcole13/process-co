class Connect::WebhooksController < ApplicationController
    include ActionView::Helpers::NumberHelper
    def create
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE']
        event = nil
        begin
          event = Stripe::Webhook.construct_event(
            payload, sig_header, ENV['STRIPE_CONNECT_ENDPOINT_SECRET']
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
        when 'account.application.authorized'
            stripe_id = event.account
            property = Property.find_by(stripe_id: stripe_id)
            if !property.present?
                property = Property.new(stripe_id: stripe_id)
                property.transfers = event.data.object.capabilities.transfers
                property.name = event.data.object.business_profile.name
                property.save
            end  
            puts 'Property Connected Successfully'
        when 'account.updated', 'account.external_account.updated'
            stripe_id = event.account
            property = Property.find_by(stripe_id: stripe_id)
            if property.present?
              property.name = event.data.object.business_profile.name
              property.transfers = event.data.object.capabilities.transfers
              property.save
            end
            puts 'Property Updated Successfully'
        end
    
        render json: { message: :success }
    end
end
