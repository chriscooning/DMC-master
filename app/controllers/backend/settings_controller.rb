class Backend::SettingsController < Backend::BaseController
  skip_before_filter :check_password_expired!, only: :profile

  def analytics
    set_resource_from(Assets::ReportResource.new(resource_options).read_all)
    set_resource_from(Downloads::MyResource.new(resource_options).read_all)
  end

  def account
    set_resource_from(Announcements::MyResource.new(resource_options).read_all)
    resource = Accounts::MyResource.new(resource_options)
    respond_with resource.edit
  end

  def security
    redirect_to dashboard_path
    #@memberships = Invites::MyMembershipResource.new(resource_options).read_all.result
    #set_resource_from(Accounts::MyResource.new(resource_options).edit)
    #set_resource_from(InvitationRequests::MyResource.new(resource_options).read_all)
  end

  def profile
    resource = Users::ProfileResource.new(as: current_user, params: params)
    respond_with resource.edit
  end

  def events_csv
    set_resource_from(Assets::ReportResource.new(as: current_user, params: params, without_pagination: true).read_all)
    send_data(
      csv_service.export("event_analytics", @assets),
      type: 'text/csv; charset=utf-8; header=present', filename: "event_analytics-#{DateTime.now}.csv"
    )
  end

  def downloads_csv
    set_resource_from(Downloads::MyResource.new(as: current_user, params: params, without_pagination: true).read_all)
    send_data(
      csv_service.export("download_analytics", @downloads),
      type: 'text/csv; charset=utf-8; header=present', filename: "download_analytics-#{DateTime.now}.csv"
    )
  end

  private

    def csv_service
      CsvExporter.new
    end

    def resource_options
      { as: current_user, account: current_account, params: params }
    end
end
