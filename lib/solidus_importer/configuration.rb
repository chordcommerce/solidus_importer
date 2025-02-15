# frozen_string_literal: true

module SolidusImporter
  class Configuration < Spree::Preferences::Configuration
    attr_writer :processing_queue

    preference :solidus_importer, :hash, default: {
      customers: {
        importer: SolidusImporter::BaseImporter,
        processors: [
          SolidusImporter::Processors::Customer,
          SolidusImporter::Processors::CustomerAddress,
          SolidusImporter::Processors::Log
        ]
      },
      orders: {
        importer: SolidusImporter::OrderImporter,
        processors: [
          SolidusImporter::Processors::Order,
          SolidusImporter::Processors::BillAddress,
          SolidusImporter::Processors::ShipAddress,
          SolidusImporter::Processors::LineItem,
          SolidusImporter::Processors::Shipment,
          SolidusImporter::Processors::Payment,
          SolidusImporter::Processors::Log
        ]
      },
      products: {
        importer: SolidusImporter::BaseImporter,
        processors: [
          SolidusImporter::Processors::Product,
          SolidusImporter::Processors::Variant,
          SolidusImporter::Processors::OptionTypes,
          SolidusImporter::Processors::OptionValues,
          SolidusImporter::Processors::ProductImages,
          SolidusImporter::Processors::VariantImages,
          SolidusImporter::Processors::Log
        ]
      }
    }

    preference :after_group_import_error_reporter, :string, default: ''

    def available_types
      solidus_importer.keys
    end

    def processing_queue
      @processing_queue ||= :default
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration

    def configure
      yield configuration
    end
  end
end
