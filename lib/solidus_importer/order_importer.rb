# frozen_string_literal: true

require 'set'

module SolidusImporter
  class OrderImporter < BaseImporter
    attr_accessor :orders

    def initialize(options)
      super
      self.orders = {}
    end

    def handle_row_import(context)
      number = context.dig(:order, :number)

      return unless number

      orders[number] ||= {}

      order_params = context[:order].to_h.reject { |_k, v| v.blank? }
      payments_attributes = order_params[:payments_attributes]
      orders[number][:payments_attributes] ||= []
      orders[number][:payments_attributes] << payments_attributes if payments_attributes.present?
      orders[number].merge!(order_params)
    end

    def after_import(context)
      orders.each do |_, params|
        user = params.delete(:user)
        SolidusImporter::SpreeCoreImporterOrder.import(user, params)
      rescue StandardError => e
        context[:_messages] ||= []
        context[:_messages] << e.message
        context[:success] = false
      end

      context[:messages] = context[:_messages].try(:join, ', ')
      context
    end
  end
end
