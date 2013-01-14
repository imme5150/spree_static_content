module StaticPage
  def self.remove_spree_mount_point(path)
    spree_path = Rails.application.routes.url_helpers.spree_path
    if spree_path == '/' # Spree is mounted as root
      path.sub!( '//', '/') # this fixes a Rails bug
    else
      path.sub!( Regexp.new(spree_path), '')
    end
    path.split('?')[0]  end
end

class Spree::StaticPage
  def self.matches?(request)
    path = StaticPage::remove_spree_mount_point(request.fullpath)
    count = Spree::Page.visible.where(:slug => path).count
    0 < count
  end
end

class Spree::StaticRoot
  def self.matches?(request)
    path = StaticPage::remove_spree_mount_point(request.fullpath)
    (path == '/') && Spree::Page.visible.find_by_slug(path)
  end
end

Spree::Core::Engine.routes.prepend do

  namespace :admin do
    resources :pages
  end

  constraints(Spree::StaticRoot) do
    match '/', :to => 'static_content#show', :via => :get, :as => 'static'
  end

  constraints(Spree::StaticPage) do
    match '/*path', :to => 'static_content#show', :via => :get, :as => 'static'
  end
end
