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
        when 'checkout.session.async_payment_succeeded', 'checkout.session.completed', 'checkout.session.async_payment_failed'
            event_object = event.data.object
            #set payment status, if async failed, update to failed
            payment_status = event_object.payment_status
            if event.type == 'checkout.session.async_payment_failed'
                payment_status = 'failed'
            end            
            payment = Payment.find_by(link_id: event_object.payment_link)
            if payment.present?
                payment.status = payment_status
                payment.save
                #Transfer money to property management connected account, if exists
                #This will happen on a monthly reconciliation basis
                #property = payment.property    
                #if property.property_manager.present?  
                    #transfer_amount = payment.amount.to_i * property.property_manager.fee_percentage.to_i/100
                    #Stripe::Transfer.create({
                        #amount: transfer_amount * 100,
                        #currency: 'usd',
                        #destination: property.property_manager.stripe_id,
                        #transfer_group: 'ORDER_95',#TODO: Do I need this? Perhaps this is just property name or resident id?
                    #})
                    #puts 'Transfer Succeeded!'
                #end

                #Post response to Buzz
                resident = payment.resident
                api_url = ENV['API_URL'].sub '${residentID}', payment.resident.buzz_id
                #get payment type
                payment_intent = Stripe::PaymentIntent.retrieve(event_object.payment_intent)
                payment_method = payment_intent.payment_method_types.first
                begin
                    response = HTTParty.post(api_url, 
                        body: { 
                            unit_occupancy_id: resident.unit_occupancy_id,
                            property_id: payment.property.buzz_id,
                            resident_id: resident.buzz_id,
                            status: payment.status,
                            link_id: payment.link_id,
                            payment_method: payment_method,
                            amount: payment.amount,
                            created_at: payment.created_at
                        }.to_json, 
                        headers: { 'Content-Type' => 'application/json' })
                rescue => e
                    render json: {error: "An unexpected error occurred."}, status: :internal_server_error
                    return
                end
                puts 'Payment Completed!'
            else
                render json: {error: "Payment with this ID does not exist"}, status: :internal_server_error
                return
            end         
        when 'payment_intent.created'
            puts "PAYMENT INTENT PROCESSESING"
            amount = event.data.object.amount/100
            type = event.data.object.payment_method_types
            amount_with_fee = calculate_fee(amount, type.first)           
            #Stripe::PaymentIntent.update(
                #event.data.object.id,
                #{amount: amount_with_fee * 100},
            #)
            puts 'Updated Payment Intent With Fee'
        else
          puts "Unhandled event type: #{event.type}"
        end
    
        render json: { message: :success }
        return
    end

    private 

    def calculate_fee(amount, type)
        if type == 'card'        
            processing_fee = (amount * 0.029) + 0.30
        else
            processing_fee = (amount * 0.008)
            if processing_fee > 5
                processing_fee = 5
            end
        end
        return amount + processing_fee
    end
end
