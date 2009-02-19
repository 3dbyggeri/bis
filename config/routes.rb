ActionController::Routing::Routes.draw do |map|
  map.connect 'search', :controller => 'bis_codes', :action => 'search'
  map.resources :jobs
  map.resources :bis_codes, :only => [:index, :show], :has_many => :children, :has_one => :parent, :shallow => true
  map.root :bis_codes
  
end
