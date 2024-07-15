class PropertyMissingMailer < ApplicationMailer
    require "mailersend-ruby"

    def missing_property_email(property_id)
      # Intialize the email class
      ms_email = Mailersend::Email.new        
      # Add parameters
      ms_email.add_recipients("email" => "about@rentergopay.com", "name" => "RenterGoPay")
      ms_email.add_from("email" => ENV['MAILSEND_FROM'], "name" => "RenterGoPay")
      ms_email.add_subject("Property Not Yet Setup")
      ms_email.add_text("Property with Buzz ID: " + property_id + " is not yet setup in Stripe. Please reach out to ensure it's setup")        
      # Send the email
      puts "EMAIL"
      ms_email.send
    end

    def transfers_not_enabled(property_id)
      # Intialize the email class
      ms_email = Mailersend::Email.new        
      # Add parameters
      ms_email.add_recipients("email" => "about@rentergopay.com", "name" => "RenterGoPay")
      ms_email.add_from("email" => ENV['MAILSEND_FROM'], "name" => "RenterGoPay")
      ms_email.add_subject("Property Not Yet Accepting Transfers")
      ms_email.add_text("Property with Buzz ID: " + property_id + " is not fully setup in Stripe. Please reach out to ensure it's setup and ready to accept transfers")        
      # Send the email
      puts "EMAIL"
      ms_email.send
    end
end
