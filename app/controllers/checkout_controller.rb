class CheckoutController < ApplicationController

  def create
    product = Product.find(params[:id])
  
    @session = Stripe::Checkout::Session.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: product.name,
          },
          unit_amount: product.price, # Цена уже в центах
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: root_url,
      cancel_url: root_url,
    })
        
    respond_to do |format|
      format.html { redirect_to @session.url, allow_other_host: true } # Если запрос обычный HTML
      format.js   # Если запрос через AJAX и ожидается JavaScript
    end
  end

end
