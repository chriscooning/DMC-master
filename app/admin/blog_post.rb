ActiveAdmin.register BlogPost do
  filter :title
  filter :publish_at

  index do
    column :id
    column :title
    column :publish_at
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :image do |post|
        image_tag post.image.url(:small) if post.image?
      end
      row :text
      row :publish_at
    end
  end

  form partial: 'form'

  controller do
    def permitted_params
      params.permit blog_post: [:title, :image, :text, :publish_at, :delete_image]
    end
  end
end