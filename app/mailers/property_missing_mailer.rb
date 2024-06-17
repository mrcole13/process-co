class PropertyMissingMailer < ApplicationMailer
    require "mailersend-ruby"

    def missing_property_email(property_id)
        # Intialize the email class
        ms_email = Mailersend::Email.new        
        # Add parameters
        ms_email.add_recipients("email" => "about@rentergopay.com", "name" => "RenterGoPay")
        ms_email.add_from("email" => "MS_kAWsmg@trial-pr9084zy2nxgw63d.mlsender.net", "name" => "RenterGoPay")
        ms_email.add_subject("Property Not Yet Setup")
        ms_email.add_text("Property with Buzz ID: " + property_id + " is not yet setup in Stripe. Please reach out to ensure it's setup")        
        # Send the email
        ms_email.send
      end
end
