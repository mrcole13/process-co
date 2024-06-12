class Api::V1::PaymentsController < ApplicationController
  before_action :payment_params#, only [:payment_link]
  include ActionView::Helpers::NumberHelper

  def index
  end

  def show
  end

  def payment_link
    resident_id = params[:resident_id]
    property_id = params[:property_id]
    amount = params[:amount]

    #find Property with the id passed in, return error if not created
    property = Property.find_by(buzz_id: property_id)
    if !property.present?
      return render json: {error: 'Property has not been connected yet'}, status: :internal_server_error
    end

    #find or create Resident with the id passed in
    resident = Resident.find_by(buzz_id: resident_id)
    if !resident.present?
      resident = Resident.new(buzz_id: resident_id)
      resident.property = property
      resident.save!
    end    
    #TODO: Decide what to name the product
    product_name = "Payment of " + amount + " to " + property.id.to_s + " for " + resident.id.to_s#Stripe::Product.create({name: resident_id})
    #Create Stripe price object
    begin
      price = Stripe::Price.create({
          currency: 'usd',
          unit_amount: amount.to_i * 100,
          product_data: {name: product_name},
        })
      #Create PaymentLink via Stripe w/ property as destination
      fee = amount.to_i * property.fee_percentage.to_i/100
      if property.property_manager.present?
        fee = fee + (amount.to_i * property.property_manager.fee_percentage.to_i/100)
      end
      response = Stripe::PaymentLink.create({
        line_items: [
          {
            price: price.id,
            quantity: 1,
          },
        ],
        application_fee_amount: fee * 100,
        transfer_data: {destination: property.stripe_id},
      })
      #Save payment object to DB
      payment = Payment.new
      payment.property = property
      payment.resident = resident
      payment.amount = amount
      payment.status = "pending"
      payment.payment_link = response.url
      payment.link_id = response.id
      payment.is_full_payment = params[:is_full_payment] 
      payment.fee = fee
      payment.save
    rescue Stripe::StripeError => e
      # Handle other Stripe errors
      return render json: {error: e.message}, status: :unprocessable_entity
    rescue => e
      # Handle other unexpected errors
      return render json: {error: "An unexpected error occurred."}, status: :internal_server_error
    end
    #return json
    return render json: {payment_link: response.url}, status: 200
  end

  private

  def payment_params
    params.permit(:resident_id, :amount, :property_id, :is_full_payment)
  end
end
