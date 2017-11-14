class Authorizers::Frontend < Authorizers::Base
  # user should be authorized to have access to backend
  def accessor_required?
    false
  end

  def show_visible_items_for_all?
    true
  end
end
