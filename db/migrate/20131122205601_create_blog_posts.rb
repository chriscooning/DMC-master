class CreateBlogPosts < ActiveRecord::Migration
  def change
    create_table :blog_posts do |t|
      t.string      :title
      t.attachment  :image
      t.text        :text
      t.datetime    :publish_at
      t.timestamps
    end
  end
end
