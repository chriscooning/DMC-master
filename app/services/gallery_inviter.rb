class GalleryInviter
  attr_reader :accessor, :params, :errors, :send_email, :results, :notices

  def initialize(options = {})
    @options = options
    @accessor = options[:as]
    @params = options[:params]
    @send_email = options[:send_email].present? ? options[:send_email] : true
    @errors = []
    @notices = []
  end

  def invite
    validate_role!
    validate_gallery_ids!
    validate_email!
    if user = User.where(email: params[:email]).first
      create_gallery_members(user)
    else
      create_invitation_requests
    end
  rescue => e
    add_error(e.message)
    false
  end

  def message
    [errors, notices].join(' ')
  end

  def create_membership
    return unless accessor.invitation_hash.present?
    invitation_requests = InvitationRequest.where(invitation_hash: accessor.invitation_hash)
    invitation_requests.each do |request|
      accessor.gallery_membership.create(gallery_id: request.gallery_id, role: request.role)
    end
    invitation_requests.destroy_all
  end

  def destroy_invitation_by_email
    validate_email_presence!
    user = User.find_by_email(params[:email])
    if user
      ids = gallery_ids.any? ? gallery_ids : my_gallery_ids
      user.gallery_membership.where(gallery_id: ids).destroy_all
    else
      invites = InvitationRequest.where(email: params[:email])
      invites = invites.where(gallery_id: gallery_ids) if params[:gallery_ids].present?
      invites.destroy_all
    end
    add_notice('Invite(s) destroyed!')
  rescue => e
    add_error(e.message)
  end

  def status
    @errors.any? ? 400 : 200
  end

  def result_for_api
    return {} unless @results.any?
    url_helper = Rails.application.routes.url_helpers
    @results.map do |invite|
      {
        gallery_id: invite.gallery_id,
        invitation_link: url_helper.gallery_url(invite.gallery_id, invitation_hash: invite.invitation_hash, host: accessor.host)
      }
    end
  end
  
  private

    def create_invitation_requests
      @results = [*gallery_ids].map do |gallery_id|
        request = InvitationRequest.create(
          gallery_id: gallery_id,
          email: params[:email],
          invitation_hash: invitation_hash,
          role: params[:role]
        )
        add_errors_form(request)
        request
      end.keep_if(&:persisted?)
      send_email_with_link if send_email && results.any?
      results.any?
    end

    def create_gallery_members(user)
      @results = gallery_ids.map do |gallery_id|
        result = user.gallery_membership.create(role: params[:role], gallery_id: gallery_id)
        add_errors_form(result)
        result
      end.keep_if(&:persisted?)
      send_email_with_link(user) if results.any?
      results.any?
    end

    def invitation_hash
      @hash ||= InvitationRequest.find_by_email(params[:email]).try(:invitation_hash) || SecureRandom.hex
    end

    def add_error(message)
      @errors << message
    end

    def add_notice(message)
      @notices << message
    end

    def add_errors_form(model)
      @errors ||= []
      if model && model.errors.messages.present?
        model.errors.messages.each do |key, value|
          add_error value
        end
      end
    end

    def validate_role!
      raise "Wrong role" unless GalleryMember::ROLES.include?(params[:role])
    end

    def validate_gallery_ids!
      unless gallery_ids.any?
        raise "Please select at least one gallery" 
      end
    end

    def validate_email!
      raise "You can't invite yourself" if accessor.email == params[:email]
    end

    def validate_email_presence!
      raise "Email field is mandatory" unless params[:email].present?
    end

    def account
      @account ||= (@options[:account] || accessor.account)
    end

    def gallery_ids
      @gallery_ids ||= [*params[:gallery_ids]].keep_if { |id| my_gallery_ids.include?(id.to_i) }
    end

    def my_gallery_ids
      @my_gallery_ids ||= account.galleries.pluck(:id)
    end

    def send_email_with_link(user = nil)
      mail = (user.present? ? "registered" : "new") + "_#{params[:role]}_welcome_email"
      InvitationMailer.send(mail, results, accessor, user).deliver
    end

end
