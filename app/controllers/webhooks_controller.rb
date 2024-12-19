class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    # Чтение данных Webhook-а
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, Rails.application.credentials[:stripe][:webhook]
      )
    rescue JSON::ParserError => e
      render json: { error: 'Invalid payload' }, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      render json: { error: 'Invalid signature' }, status: 400
      return
    end

    # Логируем тип события
    Rails.logger.info("Stripe Webhook получено: #{event.type}")

    case event.type
    when 'checkout.session.completed'
      process_checkout_session_completed(event.data.object)
    else
      Rails.logger.info("Необработанный тип события: #{event.type}")
    end

    render json: { message: 'success' }
  end

  private

  def process_checkout_session_completed(session)
    Rails.logger.info("Обработка checkout.session.completed: #{session.inspect}")

    # Расширяем сессию, чтобы получить line_items
    session_with_expand = Stripe::Checkout::Session.retrieve(
      id: session.id,
      expand: ["line_items"]
    )

    # Перебираем товары в заказе
    session_with_expand.line_items.data.each do |line_item|
      Rails.logger.info("Обработка line_item: #{line_item.inspect}")

      # Находим продукт по stripe_product_id
      product = Product.find_by(stripe_product_id: line_item.price.product)

      if product.present?
        product.increment!(:sales_count)
        Rails.logger.info("Обновлён продукт: #{product.inspect}")
      else
        Rails.logger.error("Продукт не найден для stripe_product_id: #{line_item.price.product}")
      end
    end
  end
end