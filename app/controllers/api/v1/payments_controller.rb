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

    #find or create Property with the id passed in
    property = Property.find_by(buzz_id: property_id)
    if !property.present?
      property = Property.create!(buzz_id: property_id)
    end

    #find or create Resident with the id passed in
    resident = Resident.find_by(buzz_id: resident_id)
    if !resident.present?
      resident = Resident.new(buzz_id: resident_id)
      resident.property = property
      resident.save!
    end    
    amount_string = number_to_currency(amount.to_f / 100, :unit => "$")
    product_name = "Payment of " + amount_string.to_s + " to " + property.id.to_s + " for " + resident.id.to_s#Stripe::Product.create({name: resident_id})

    #Create Stripe price object
    begin
      price = Stripe::Price.create({
          currency: 'usd',
          unit_amount: amount,
          product_data: {name: product_name},
        })
      #Create PaymentLink via Stripe w/ property as destination
      fee = amount.to_i * 0.05    
      response = Stripe::PaymentLink.create({
        line_items: [
          {
            price: price.id,
            quantity: 1,
          },
        ],
        application_fee_amount: fee.to_i,
        transfer_data: {destination: 'acct_1PP6ohLK314QslDW'},
      })
      #Save payment object to DB
      payment = Payment.new
      payment.property = property
      payment.resident = resident
      payment.amount = amount
      payment.status = "paymentLink"
      payment.payment_link = response.url
      payment.link_id = response.id
      payment.is_full_payment = params[:is_full_payment] 
      payment.save

      #return json
      render json: {payment_link: response.url}, status: 200
    rescue Stripe::StripeError => e
      # Handle other Stripe errors
      render json: {error: e.message}, status: :unprocessable_entity
    rescue => e
      # Handle other unexpected errors
      render json: {error: "An unexpected error occurred."}, status: :internal_server_error
    end
  end

  private

  def payment_params
    params.permit(:resident_id, :amount, :property_id, :is_full_payment)
  end
end
