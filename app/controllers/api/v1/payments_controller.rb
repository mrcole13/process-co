class Api::V1::PaymentsController < ApplicationController
  #before_action :verify_token
  before_action :payment_params
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
      #send email letting team know to get this property setup
      email = PropertyMissingMailer.missing_property_email(property_id)
      return render json: {error: 'Property has not been connected yet'}, status: :internal_server_error
    end

    #find or create Resident with the id passed in
    resident = Resident.find_by(buzz_id: resident_id)
    if !resident.present?
      resident = Resident.new(buzz_id: resident_id)
      resident.email = params[:email]
      resident.first_name = params[:first_name]
      resident.last_name = params[:first_name]
      resident.unit_occupancy_id = params[:unit_occupancy_id]
      resident.property = property
      resident.save!
    end    
    #TODO: Decide what to name the product
    payment_to = "Payment to "
    if params[:is_full_payment] == 'false'
      payment_to = "Partial payment to "
    end
    product_name = payment_to + property.name
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
      #TODO: add processesing/transaction fee amount
      response = Stripe::PaymentLink.create({
        line_items: [
          {
            price: price.id,
            quantity: 1,
          },
        ],
        metadata: { 
          is_full_payment: params[:is_full_payment],
          resident_first_name: params[:first_name],
          resident_last_name: params[:last_name],
          resident_email: params[:email],          
        },
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
    params.permit(:resident_id, :amount, :property_id, :is_full_payment, :first_name, :last_name, :auth_token)
  end

  def verify_token
    if !params[:auth_token].present? || params[:auth_token] != ENV['AUTH_TOKEN']
      return render json: {error: "An unexpected error occurred."}, status: :internal_server_error
    end
  end
end
