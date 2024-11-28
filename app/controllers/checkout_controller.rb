class CheckoutController < ApplicationController

  def create
    product = Product.find(params[:id])
  
    @session = Stripe::Checkout::Session.create({
      customer: current_user.stripe_customer_id,
      payment_method_types: ['card'],
      line_items: [{
          price: product.stripe_price_id,
            quantity: 1,
      }],
      mode: 'payment',  
      success_url: seccess_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: cancel_url,
    })
        
    respond_to do |format|
      format.html { redirect_to @session.url, allow_other_host: true } # Если запрос обычный HTML
      format.js   # Если запрос через AJAX и ожидается JavaScript
    end
  end

  def success
    session_with_expand = Stripe::Checkout::Session.retrieve({ id: params[:session_id], expand: ["line_items"]})
    session_with_expand.line_items.data.each do |line_item|
      product = Product.find_by(stripe_product_id: line_item.price.product)
      product.increment!(:sales_count)
    end
  end

  def cancel
  end

end
