class PropertyCreatedMailer < ApplicationMailer
    require "mailersend-ruby"

    def property_created(stripe_id, name)
      # Intialize the email class
      ms_email = Mailersend::Email.new        
      # Add parameters
      ms_email.add_recipients("email" => "about@rentergopay.com", "name" => "RenterGoPay")
      ms_email.add_from("email" => ENV['MAILSEND_FROM'], "name" => "RenterGoPay")
      ms_email.add_subject("Property Created")
      ms_email.add_text("Property " + name + " with Stripe ID: " + stripe_id + " was just created. Reach out to point of contact to set up fees and send link to finish creation.")        
      # Send the email
      puts "EMAIL"
      ms_email.send
    end
end
