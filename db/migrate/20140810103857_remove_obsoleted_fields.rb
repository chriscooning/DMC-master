class RemoveObsoletedFields < ActiveRecord::Migration
  def up
    drop_table_if_exists :media_users
    drop_table_if_exists :media_authorizations

    #  we switched to many-to-many relations
    %w{account_id role_id}.each do |field_name|
      remove_column_if_exists :users, field_name
    end

    # we have extracted this data to accounts table
    fields = %w{about subdomain logo_file_name logo_content_type logo_file_size}
    fields += %w{logo_updated_at logo_text logo_url restrictions_message s3_hash copyrights }
    fields += %w{portal_header_image_file_name portal_header_image_content_type} 
    fields += %w{portal_header_image_file_size portal_header_image_updated_at}
    fields += %w{welcome_message landing_title theme allow_subdomain_indexing logo_height logo_width}
    fields += %w{enable_subdomain_password encrypted_subdomain_password}

    fields.each do |field_name|
      remove_user_column field_name
    end

    remove_column_if_exists :users, :role_id
    remove_column_if_exists :users, :subdomain
    remove_column_if_exists :users, :about
  end

  def down
  end

  private

    def remove_column_if_exists(table_name, field_name)
      if ActiveRecord::Base.connection.column_exists?(table_name, field_name)
        remove_column table_name, field_name
      end
    end

    def remove_user_column(field_name)
      if ActiveRecord::Base.connection.column_exists?(:users, field_name)
        if ActiveRecord::Base.connection.column_exists?(:accounts, field_name)
          remove_column :users, field_name
        end
      end
    end

    def drop_table_if_exists(table_name)
      if ActiveRecord::Base.connection.table_exists?(table_name)
        drop_table table_name
      end
    end
end
