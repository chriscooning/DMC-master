class Accounts::MyResource < Cyrax::Resource
  resource :account, class_name: "Account"
  accessible_attributes :subdomain, :logo_text, :logo_url, :restrictions_message, :logo, 
                        :delete_logo, :copyrights, :welcome_message, :portal_header_image, 
                        :delete_portal_header_image, :landing_title, :allow_subdomain_indexing,
                        :enable_subdomain_password, :subdomain_password,
                        theme: [:body_bg_color, :body_font_color, :body_link_color, :button_color, 
                                :button_font_color, :thumbnail_tile_background_color, :nav_bg_color,
                                :nav_link_color, :dropdown_link_color, :dropdown_link_color_active,
                                :dropdown_bg_link_color_active, :dropdown_toggle_open_bg_color
                        ]

  def find_resource(id)
    id.present? ? Account.find(id) : options[:account]
  end

  def edit
    edit! do |resource|
      authorize_resource!('read', resource)
    end
  end

  def build_resource(id, attributes = {})
    resource = find_resource(id)
    delete_logo = attributes.delete(:delete_logo)
    delete_portal_header_image = attributes.delete(:delete_portal_header_image)

    attributes[:theme] = validate_theme(attributes[:theme]) if attributes[:theme].present?
    if (password = attributes[:subdomain_password]).present?
      resource.encrypted_subdomain_password = ::BCrypt::Password.create("#{password}#{resource.class.pepper}", cost: 1)
    end
    resource.attributes = attributes
    resource.logo = nil if delete_logo.present?
    resource.portal_header_image = nil if delete_portal_header_image.present?
    resource
  end

  private

    def authorize_resource!(action, resource)
      authorization_service.authorize!(action, resource)
    end

    def authorization_service
      Authorizers::Backend.new(account: options[:account], accessor: accessor)
    end

    def validate_theme(theme)
      theme.keep_if { |k, v|  v =~ /^(?:[0-9a-f]{3})(?:[0-9a-f]{3})?$/i }
    end
end
