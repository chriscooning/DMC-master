# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150403144451) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_users", force: true do |t|
    t.integer "account_id"
    t.integer "user_id"
    t.boolean "primary",    default: false
    t.boolean "owner",      default: false
    t.boolean "invited",    default: false
  end

  create_table "accounts", force: true do |t|
    t.integer  "owner_id"
    t.text     "about"
    t.string   "subdomain"
    t.boolean  "allow_subdomain_indexing",         default: true
    t.text     "theme"
    t.text     "welcome_message"
    t.text     "restrictions_message"
    t.string   "landing_title"
    t.string   "copyrights"
    t.string   "authentication_token"
    t.datetime "authentication_token_expires_at"
    t.string   "s3_hash"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "logo_text"
    t.string   "logo_url"
    t.integer  "logo_height"
    t.integer  "logo_width"
    t.string   "portal_header_image_file_name"
    t.string   "portal_header_image_content_type"
    t.integer  "portal_header_image_file_size"
    t.datetime "portal_header_image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enable_subdomain_password",        default: false
    t.string   "encrypted_subdomain_password",     default: "f"
    t.integer  "account_users_count",              default: 0,     null: false
  end

  create_table "active_admin_comments", force: true do |t|
    t.integer  "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.string   "namespace"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_user_passwords", force: true do |t|
    t.integer  "admin_user_id"
    t.string   "encrypted_password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_users", force: true do |t|
    t.string   "email",                               default: "",    null: false
    t.string   "encrypted_password",                  default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.string   "favorite_user_ids",      limit: 1024
    t.boolean  "can_create_users",                    default: false
    t.datetime "password_expire_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "announcements", force: true do |t|
    t.string   "title"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  create_table "assets", force: true do |t|
    t.integer  "folder_id"
    t.string   "title"
    t.text     "description"
    t.string   "type"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size",                limit: 8
    t.datetime "file_updated_at"
    t.text     "video_urls"
    t.boolean  "downloadable",                            default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "cached_tag_list"
    t.string   "secret"
    t.text     "video_thumbnail"
    t.boolean  "processed",                               default: true
    t.datetime "deleted_at"
    t.integer  "position",                                default: 0
    t.string   "m3u8_url"
    t.string   "custom_thumbnail_file_name"
    t.string   "custom_thumbnail_content_type"
    t.integer  "custom_thumbnail_file_size"
    t.datetime "custom_thumbnail_updated_at"
    t.string   "quicklink_hash"
    t.string   "quicklink_url"
    t.datetime "quicklink_valid_to"
    t.boolean  "quicklink_downloadable",                  default: false
    t.string   "embedding_hash"
    t.integer  "account_id"
    t.text     "video_thumbnails"
  end

  add_index "assets", ["embedding_hash"], name: "index_assets_on_embedding_hash", using: :btree
  add_index "assets", ["folder_id"], name: "index_assets_on_folder_id", using: :btree
  add_index "assets", ["quicklink_hash"], name: "index_assets_on_quicklink_hash", using: :btree
  add_index "assets", ["secret"], name: "index_assets_on_secret", using: :btree

  create_table "blog_posts", force: true do |t|
    t.string   "title"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "text"
    t.datetime "publish_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "downloads", force: true do |t|
    t.integer  "subject_id"
    t.string   "subject_type"
    t.integer  "asset_id"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: true do |t|
    t.integer  "subject_id"
    t.string   "subject_type"
    t.string   "name"
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "target_owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "folder_authorized_keys", force: true do |t|
    t.integer  "folder_id"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "folders", force: true do |t|
    t.integer  "gallery_id"
    t.string   "name"
    t.boolean  "hide_folder",        default: false
    t.boolean  "enable_credentials", default: false
    t.integer  "position",           default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "encrypted_password"
    t.boolean  "hide_title",         default: false
    t.boolean  "hide_description",   default: false
    t.datetime "deleted_at"
    t.boolean  "enable_password",    default: false
    t.integer  "default_per_page",   default: 16
    t.string   "assets_sort_order"
  end

  add_index "folders", ["gallery_id", "hide_folder"], name: "index_folders_on_gallery_id_and_hide_folder", using: :btree

  create_table "galleries", force: true do |t|
    t.string   "name"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "logo_url"
    t.text     "gallery_message"
    t.text     "restrictions_message"
    t.text     "help_message"
    t.boolean  "visible",                       default: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_text"
    t.string   "encrypted_password"
    t.boolean  "enable_credentials",            default: false
    t.datetime "deleted_at"
    t.boolean  "show_first",                    default: false
    t.integer  "position",                      default: 0
    t.boolean  "enable_password",               default: false
    t.boolean  "enable_invitation_credentials", default: false
    t.boolean  "featured",                      default: false
    t.string   "featured_image_file_name"
    t.string   "featured_image_content_type"
    t.integer  "featured_image_file_size"
    t.datetime "featured_image_updated_at"
    t.integer  "account_id"
  end

  create_table "gallery_authorized_keys", force: true do |t|
    t.integer  "gallery_id"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gallery_members", force: true do |t|
    t.integer  "user_id"
    t.integer  "gallery_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitation_requests", force: true do |t|
    t.integer  "gallery_id"
    t.string   "email"
    t.string   "invitation_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.integer  "user_id"
  end

  create_table "menu_links", force: true do |t|
    t.integer "gallery_id"
    t.string  "link"
    t.string  "content"
    t.integer "position",   default: 0
  end

  add_index "menu_links", ["gallery_id"], name: "index_menu_links_on_gallery_id", using: :btree

  create_table "permissions", force: true do |t|
    t.integer  "account_id"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.string   "action",        limit: 50
    t.datetime "deleted_at"
  end

  create_table "roles", force: true do |t|
    t.integer "account_id"
    t.string  "name"
    t.string  "description"
  end

  create_table "roles_permissions", id: false, force: true do |t|
    t.integer "role_id"
    t.integer "permission_id"
  end

  create_table "subdomain_authorized_keys", force: true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: true do |t|
    t.string "name"
  end

  create_table "user_roles", force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  create_table "user_tokens", force: true do |t|
    t.integer  "account_id"
    t.integer  "user_id"
    t.string   "token"
    t.datetime "enable_at"
    t.datetime "expire_at"
    t.string   "application"
    t.integer  "times_used",  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                           default: "",    null: false
    t.string   "encrypted_password",              default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "full_name"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "authentication_token"
    t.datetime "authentication_token_expires_at"
    t.boolean  "password_expired",                default: false
    t.string   "location"
    t.string   "organization"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_permissions", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "permission_id"
  end

end
