class Api::V1::PropertiesController < ApplicationController
  before_action :property_params, :verify_token

  def index
  end

  def show
  end

  def create_property
    property_id = params[:property_id]
    name = params[:name]

    property = Property.find_by(buzz_id: property_id)
    if !property.present?
      begin
        stripe_account = Stripe::Account.create({
          country: 'US',
          business_profile: {
            name: name,
          },
          controller: {
            fees: {payer: 'application'},
            losses: {payments: 'application'},
            stripe_dashboard: {type: 'express'},
          },
        })
        stripe_id = stripe_account.id
        property = Property.new
        property.name = name
        property.buzz_id = property_id
        property.stripe_id = stripe_id
        property.transfers = 'inactive'
        property.save
        #send email
        email = PropertyCreatedMailer.property_created(stripe_id, name)
        puts email
        #return json
        return render json: { message: :success }
      rescue Stripe::StripeError => e
        # Handle other Stripe errors
        return render json: {error: e.message}, status: :unprocessable_entity
      rescue => e
        # Handle other unexpected errors
        return render json: {error: "An unexpected error occurred."}, status: :internal_server_error
      end      
    else
      #handle property existing
      return render json: {error: "This property already exists."}, status: :internal_server_error      
    end
  end

  private

  def property_params
    params.permit(:property_id, :name, :auth_token)
  end

  def verify_token
    if !params[:auth_token].present? || params[:auth_token] != ENV['AUTH_TOKEN']
      return render json: {error: "An unexpected error occurred."}, status: :internal_server_error
    end
  end
end
