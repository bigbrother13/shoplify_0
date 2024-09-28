# Stripe.api_key = 'sk_test_51Q2gezDnQ7iOnUAbU7lOAU7drbxPe8ibbq2axns760SneCfdHf1P82Jb7gV8sv7RtKLYWL7kU99ZyV0h3sSlr63j00Cp2knLsJ'
Stripe.api_key = Rails.application.credentials[:stripe][:secret]