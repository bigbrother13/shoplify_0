class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, Rails.application.credentials[:stripe][:webhook]
      )
    rescue JSON::ParserError => e
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      puts "Signature error"
      p e
      return
    end

    # Logging the received event type and session data
    puts "Received event: #{event.type}"
    puts "Session data: #{event.data.object.inspect}"

    # Handle the event
    case event.type
    when 'checkout.session.completed'
      session = event.data.object

      # Log session data for more clarity
      puts "Checkout session completed for: #{session.inspect}"

      # Example: Change price to another identifier like `product_id`
      @product = Product.find_by(price: session.amount_total) # You might need to change this line
      if @product.present?
        @product.increment!(:sales_count)
        puts "Product found and sales count incremented: #{@product.inspect}"
      else
        puts "Product not found with price: #{session.amount_total}"
      end
    end
    
    render json: { message: 'success' }
  end
end 