class PagesController < ApplicationController

  # Invoice configuration
  INSURANCE_VAT_RATE = 0
  VAT_RATE = 20
  INSURANCE_RATE = 1.30
  GARANTME_VARIABLE_RATE = 3.50
  GARANTME_FIXED_RATE = 365
  GARANTME_FIXED_RENT_LIMIT = 870
  LEASE_DURATION = 12
  BROKER_FEE = 70
  USER_DISCOUNT = 50
  DEFAULT_MONTHLY_RATE = 1000
  
  def home
    @invoice = invoice_generator params[:contract_monthly_rent].to_f

    respond_to do |format|
      format.html
      format.js
    end
  end

  def invoice_generator contract_monthly_rent
    contract_annual_rent = contract_monthly_rent * LEASE_DURATION
    
    if contract_monthly_rent > GARANTME_FIXED_RENT_LIMIT
      guarantor_pack_base_price = contract_annual_rent * GARANTME_VARIABLE_RATE / 100
    else
      guarantor_pack_base_price = GARANTME_FIXED_RATE
    end

    insurance_premium = contract_annual_rent * INSURANCE_RATE / 100
    total_insurance_fees = insurance_premium + BROKER_FEE
    garantme_services_TTC = guarantor_pack_base_price - (total_insurance_fees * (1 + INSURANCE_VAT_RATE))
    garantme_services_VAT = garantme_services_TTC * VAT_RATE / (100 + VAT_RATE)
    garantme_services_HT = garantme_services_TTC - garantme_services_VAT
    user_discount_VAT = USER_DISCOUNT * VAT_RATE / (100 + VAT_RATE)
    user_discount_HT = USER_DISCOUNT - user_discount_VAT
    sub_total_HT = garantme_services_HT + total_insurance_fees
    sub_total_ttc = garantme_services_TTC + total_insurance_fees

    {
      contract_monthly_rent: contract_monthly_rent,
      insurance_premium: insurance_premium,
      broker_fee: BROKER_FEE,
      services: {
        ht: garantme_services_HT,
        vat: garantme_services_VAT,
        ttc: garantme_services_TTC,
      },
      sub_total: {
        ht: sub_total_HT,
        vat: garantme_services_VAT,
        ttc: sub_total_ttc,
      },
      discount: {
        ht: user_discount_HT,
        vat: user_discount_VAT,
        ttc: USER_DISCOUNT,
      },
      total: {
        ht: (sub_total_HT - user_discount_HT),
        vat: (garantme_services_VAT - user_discount_VAT),
        ttc: (sub_total_ttc - USER_DISCOUNT),
      }
    }
  end

end