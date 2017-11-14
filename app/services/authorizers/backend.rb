class Authorizers::Backend < Authorizers::Base
  # user should be authorized to have access to backend
  def accessor_required?
    true
  end

  def show_visible_items_for_all?
    false
  end
end
