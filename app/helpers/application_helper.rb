module ApplicationHelper
  def conditional_html(options = {}, &block)
    lang = I18n.locale
    html_class = options[:class]
    html = <<-"HTML".gsub( /^\s+/, '' )
      <!--[if lt IE 7 ]>    <html lang="#{lang}" class="#{lang} #{html_class} ie ie6 no-js"> <![endif]-->
      <!--[if IE 7 ]>       <html lang="#{lang}" class="#{lang} #{html_class} ie ie7 no-js"> <![endif]-->
      <!--[if IE 8 ]>       <html lang="#{lang}" class="#{lang} #{html_class} ie ie8 no-js"> <![endif]-->
      <!--[if IE 9 ]>       <html lang="#{lang}" class="#{lang} #{html_class} ie ie9 no-js"> <![endif]-->
      <!--[if (gte IE 9)|!(IE)]><!--> <html lang="#{lang}" class="#{lang} #{html_class} no-js"> <!--<![endif]-->
    HTML
    html += capture( &block ) << "\n</html>".html_safe if block_given?
    html.html_safe
  end

  def restfull_action_name
    case controller.action_name.to_sym
    when :create
      'new'
    when :update
      'edit'
    else
      controller.action_name
    end
  end

  def last_blog_post
    @last_blog_post ||= BlogPost.published.last
  end

  def controller_action_class
    "#{controller.controller_name}-#{restfull_action_name}"
  end

  def controller?(*controllers)
    controllers = controllers.map(&:to_sym)
    controllers.include?(controller.controller_name.to_sym)
  end

  def action?(*actions)
    actions = actions.map(&:to_sym)
    actions.include?(controller.action_name.to_sym)
  end

  def landing?
    controller_name == 'pages' && action_name == 'home'
  end

  def restrict_robot_indexing?
    current_account && !current_account.allow_subdomain_indexing?
  end
end
