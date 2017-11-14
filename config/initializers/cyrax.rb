Cyrax.strong_parameters = true

# override
# decorator should know accessor to correctly set permissions
Cyrax::Presenters::DecoratedCollection.class_eval do
  private

    def decorate_item(item)
      options[:decorator].new(item, options)
    end
end

Cyrax::Presenter.class_eval do
  def present_with_decoration(resource, options)
    if options[:present] == :collection
      Cyrax::Presenters::DecoratedCollection.new(resource, options)
    else
      options[:decorator].decorate(resource, options)
    end 
  end
end
