module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @user = current_user || User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def link_to_current body, url
    link_to(body, url, :class => (current_page?(url) ? "active" : ''))
  end

  def nav_link_to_current body, url
    ((current_page?(url) ? '<li class="current">' : "<li>") + link_to(("<span>"+body+"</span>").html_safe, url) + "<li>").html_safe
  end

end
