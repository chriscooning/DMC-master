module Subaccount
  module ResourceHelper

    extend ActiveSupport::Concern

    included do
      attr_accessor :parent_account
    end

    def initialize(options = {})
      super
      @parent_account = options[:parent]
    end

    private

      def authorize!
        raise ActionController::RoutingError.new('Not Found') if accessible_gallery_ids.empty?
      end

      def accessible_gallery_ids
        @accessible_gallery_ids ||= accessor.gallery_membership.admin.pluck(:gallery_id)
      end
  end
end