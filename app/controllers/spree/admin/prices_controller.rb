module Spree
  module Admin
    class PricesController < ResourceController
      belongs_to 'spree/product', find_by: :slug

      def create
        params[:vp].each do |variant_id, prices|
          variant = Spree::Variant.find(variant_id)
          next unless variant
          supported_currencies.each do |currency|
            price = variant.price_in(currency.iso_code)
            if price.present?
              price.price = (prices[currency.iso_code].blank? ? nil : prices[currency.iso_code].to_money)
            #debugger
              price.save! if price.new_record? && price.price || !price.new_record? && price.changed?
            elsif(prices[currency.iso_code].to_money.present?)
                vari = variant.prices.new(amount: prices[currency.iso_code].to_money, currency: currency.iso_code)
                vari.save!
            end
          end
        end
        flash[:success] = Spree.t('notice.prices_saved')
        redirect_to admin_product_path(parent)
      end
    end
  end
end
