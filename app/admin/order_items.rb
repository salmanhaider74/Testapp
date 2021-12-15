ActiveAdmin.register OrderItem do
  menu false
  actions :all, except: [:destroy, :create, :edit, :new, :update]
end
