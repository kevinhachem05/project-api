module Motor
  class Ability
    include CanCan::Ability

    def initialize(_admin_user)
      can :manage, :all

      # CanCan excludes primary keys from permitted_attributes by default.
      # Motor needs the key in JSON to render row IDs and build record links.
      can :read, :all, :id
    end
  end
end
